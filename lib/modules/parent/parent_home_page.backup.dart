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

  @override
  Widget build(BuildContext context) {
    final orgName =
        '${widget.bootstrap.activeWorkspace['organization_name'] ?? 'Sahnun'}';

    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadStudents,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
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

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
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
          );
        },
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
