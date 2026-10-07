import 'package:flutter/material.dart';

import '../../core/models/app_bootstrap.dart';
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

      setState(() {
        _students = students;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openLinkStudent() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LinkStudentPage(bootstrap: widget.bootstrap),
      ),
    );

    if (changed == true) {
      await _loadStudents();
    }
  }

  void _comingSoon(String title, ParentStudent student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title • ${student.name}\nกำลังพัฒนาระบบส่วนนี้'),
      ),
    );
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 72),
              const SizedBox(height: 16),
              Text(_error, textAlign: TextAlign.center),
              const SizedBox(height: 20),
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

    if (_students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.family_restroom, size: 90),
              const SizedBox(height: 20),
              const Text(
                'ยังไม่มีนักเรียนที่เชื่อมโยง',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openLinkStudent,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('เพิ่มนักเรียน'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];

          return _StudentSection(
            student: student,
            onMenuTap: (title) {
              _comingSoon(title, student);
            },
          );
        },
      ),
    );
  }
}

class _StudentSection extends StatelessWidget {
  final ParentStudent student;
  final void Function(String title) onMenuTap;

  const _StudentSection({required this.student, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _StudentPhoto(url: student.photoUrl),
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
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Column(
                    children: [
                      const Text('ยอดเงินคงเหลือ'),
                      const SizedBox(height: 6),
                      Text(
                        '${student.balance.toStringAsFixed(0)} บาท',
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

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'บริการสำหรับนักเรียน',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _ParentMenu(
              icon: Icons.access_time,
              title: 'เวลาเข้า-ออก',
              subtitle: 'ตรวจสอบเวลาเรียน',
              onTap: () => onMenuTap('เวลาเข้า-ออก'),
            ),
            _ParentMenu(
              icon: Icons.receipt_long,
              title: 'รายการใช้จ่าย',
              subtitle: 'ดูประวัติการใช้เงิน',
              onTap: () => onMenuTap('รายการใช้จ่าย'),
            ),
            _ParentMenu(
              icon: Icons.account_balance_wallet,
              title: 'เติมเงิน',
              subtitle: 'เติมเงินให้นักเรียน',
              onTap: () => onMenuTap('เติมเงิน'),
            ),
            _ParentMenu(
              icon: Icons.school,
              title: 'ค่าเล่าเรียน',
              subtitle: 'ตรวจสอบยอดชำระ',
              onTap: () => onMenuTap('ค่าเล่าเรียน'),
            ),
            _ParentMenu(
              icon: Icons.badge,
              title: 'ข้อมูลนักเรียน',
              subtitle: 'ข้อมูลส่วนตัวและห้องเรียน',
              onTap: () => onMenuTap('ข้อมูลนักเรียน'),
            ),
            _ParentMenu(
              icon: Icons.notifications,
              title: 'แจ้งเตือน',
              subtitle: 'ข่าวสารและข้อความ',
              onTap: () => onMenuTap('แจ้งเตือน'),
            ),
          ],
        ),

        const SizedBox(height: 28),
      ],
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  const _StudentPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 96.0;

    if (url.isEmpty) {
      return const CircleAvatar(
        radius: size / 2,
        child: Icon(Icons.person, size: 52),
      );
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 52),
          );
        },
      ),
    );
  }
}
