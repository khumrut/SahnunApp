import 'package:flutter/material.dart';

import '../../core/models/app_bootstrap.dart';
import 'attendance_page.dart';
import 'link_student_page.dart';
import 'parent_service.dart';
import 'parent_student.dart';

class ParentHomePage extends StatefulWidget {
  final AppBootstrap bootstrap;

  const ParentHomePage({super.key, required this.bootstrap});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  bool _loading = true;
  String _error = '';
  List<ParentStudent> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final students = await ParentService.getStudents();
      if (!mounted) return;
      setState(() => _students = students);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLinkStudent() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LinkStudentPage(bootstrap: widget.bootstrap),
      ),
    );
    if (!mounted) return;
    if (changed == true) await _loadStudents();
  }

  Future<void> _openStudent(ParentStudent student) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _StudentDetailPage(student: student),
      ),
    );
    if (!mounted) return;
    if (changed == true) await _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final orgName =
        '${widget.bootstrap.activeWorkspace['organization_name'] ?? 'Sahnun'}';
    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        actions: [
          IconButton(
            tooltip: 'รีเฟรช',
            onPressed: _loading ? null : _loadStudents,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'เพิ่มนักเรียน',
            onPressed: _openLinkStudent,
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 16),
              Text(_error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadStudents,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'นักเรียนที่เชื่อมโยง',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text('เลือกนักเรียนเพื่อดูรายละเอียด (${_students.length} คน)'),
          const SizedBox(height: 16),
          if (_students.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('ยังไม่มีนักเรียนที่เชื่อมโยง')),
            ),
          for (final student in _students)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _openStudent(student),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _StudentPhoto(url: student.photoUrl, size: 76),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name.isEmpty
                                  ? 'นักเรียน ${student.studentId}'
                                  : student.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('รหัสนักเรียน ${student.studentId}'),
                            if (student.classroom.isNotEmpty)
                              Text('ห้อง ${student.classroom}'),
                            const SizedBox(height: 6),
                            Text(
                              'ยอดเงิน ${student.balance.toStringAsFixed(2)} บาท',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openLinkStudent,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('เพิ่มนักเรียน'),
          ),
        ],
      ),
    );
  }
}

class _StudentDetailPage extends StatefulWidget {
  final ParentStudent student;
  const _StudentDetailPage({required this.student});

  @override
  State<_StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<_StudentDetailPage> {
  bool _unlinking = false;

  Future<void> _unlinkStudent() async {
    final student = widget.student;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยกเลิกการเชื่อมโยงนักเรียน?'),
        content: Text(
          'ต้องการนำ ${student.name.isEmpty ? student.studentId : student.name} '
          'ออกจากบัญชีผู้ปกครองนี้ใช่หรือไม่?\n\n'
          'ข้อมูลนักเรียนและประวัติที่โรงเรียนจะไม่ถูกลบ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _unlinking = true);
    try {
      await ParentService.unlinkStudent(
        organizationId: student.organizationId,
        studentId: student.studentId,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยกเลิกการเชื่อมโยงไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _unlinking = false);
    }
  }

  void _openMenu(String title) {
    if (title == 'เวลาเข้า-ออก') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendancePage(student: widget.student),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title • ${widget.student.name}\nกำลังพัฒนาระบบส่วนนี้')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดนักเรียน'),
        actions: [
          IconButton(
            tooltip: 'ยกเลิกการเชื่อมโยง',
            onPressed: _unlinking ? null : _unlinkStudent,
            icon: const Icon(Icons.person_remove_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _StudentPhoto(url: student.photoUrl, size: 96),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name.isEmpty
                                    ? 'นักเรียน ${student.studentId}'
                                    : student.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('รหัสนักเรียน ${student.studentId}'),
                              if (student.classroom.isNotEmpty)
                                Text('ห้อง ${student.classroom}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: Column(
                        children: [
                          const Text('ยอดเงินคงเหลือ'),
                          const SizedBox(height: 6),
                          Text(
                            '${student.balance.toStringAsFixed(2)} บาท',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'บริการสำหรับนักเรียน',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  crossAxisCount: constraints.maxWidth >= 700 ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth >= 700 ? 2.3 : 1.55,
                  children: [
                    _ParentMenu(icon: Icons.access_time, title: 'เวลาเข้า-ออก', subtitle: 'ตรวจสอบเวลาเรียน', onTap: () => _openMenu('เวลาเข้า-ออก')),
                    _ParentMenu(icon: Icons.receipt_long, title: 'รายการใช้จ่าย', subtitle: 'ดูประวัติการใช้เงิน', onTap: () => _openMenu('รายการใช้จ่าย')),
                    _ParentMenu(icon: Icons.account_balance_wallet, title: 'เติมเงิน', subtitle: 'เติมเงินให้นักเรียน', onTap: () => _openMenu('เติมเงิน')),
                    _ParentMenu(icon: Icons.school, title: 'ค่าเล่าเรียน', subtitle: 'ตรวจสอบยอดชำระ', onTap: () => _openMenu('ค่าเล่าเรียน')),
                    _ParentMenu(icon: Icons.badge, title: 'ข้อมูลนักเรียน', subtitle: 'ข้อมูลส่วนตัวและห้องเรียน', onTap: () => _openMenu('ข้อมูลนักเรียน')),
                    _ParentMenu(icon: Icons.notifications, title: 'แจ้งเตือน', subtitle: 'ข่าวสารและข้อความ', onTap: () => _openMenu('แจ้งเตือน')),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _unlinking ? null : _unlinkStudent,
              icon: const Icon(Icons.person_remove_outlined),
              label: Text(_unlinking ? 'กำลังดำเนินการ...' : 'ยกเลิกการเชื่อมโยงนักเรียน'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ParentMenu({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentPhoto extends StatelessWidget {
  final String url;
  final double size;

  const _StudentPhoto({required this.url, this.size = 96});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person, size: size * 0.54),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('PHOTO ERROR: $error');
          return SizedBox(
            width: size,
            height: size,
            child: Icon(Icons.person, size: size * 0.54),
          );
        },
      ),
    );
  }
}