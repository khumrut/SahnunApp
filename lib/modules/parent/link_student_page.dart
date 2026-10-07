import 'package:flutter/material.dart';

import '../../core/models/app_bootstrap.dart';
import 'parent_service.dart';

class LinkStudentPage extends StatefulWidget {
  final AppBootstrap bootstrap;

  const LinkStudentPage({super.key, required this.bootstrap});

  @override
  State<LinkStudentPage> createState() => _LinkStudentPageState();
}

class _LinkStudentPageState extends State<LinkStudentPage> {
  final _controller = TextEditingController();

  bool _loading = false;
  String _error = '';

  Future<void> _link() async {
    final studentId = _controller.text.trim();

    if (studentId.isEmpty) {
      setState(() {
        _error = 'กรุณากรอกรหัสนักเรียน';
      });
      return;
    }

    final organizationId =
        int.tryParse(
          '${widget.bootstrap.activeWorkspace['organization_id'] ?? 0}',
        ) ??
        0;

    if (organizationId <= 0) {
      setState(() {
        _error = 'ไม่พบข้อมูลองค์กร';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await ParentService.linkStudent(
        organizationId: organizationId,
        studentId: studentId,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เชื่อมโยงนักเรียน')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.family_restroom, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'เพิ่มนักเรียนในบัญชีผู้ปกครอง',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _link();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'รหัสนักเรียน',
                      hintText: 'เช่น 8198',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        _error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _link,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link),
                      label: Text(
                        _loading ? 'กำลังตรวจสอบ...' : 'ยืนยันนักเรียน',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
