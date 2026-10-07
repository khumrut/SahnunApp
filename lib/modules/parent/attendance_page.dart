import 'package:flutter/material.dart';

import 'parent_service.dart';
import 'parent_student.dart';

class AttendancePage extends StatefulWidget {
  final ParentStudent student;

  const AttendancePage({super.key, required this.student});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _loading = true;
  String _error = '';

  Map<String, dynamic>? _today;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ParentService.getAttendance(
        organizationId: widget.student.organizationId,
        studentId: widget.student.studentId,
      );

      final todayRaw = data['today'];

      final historyRaw = List<dynamic>.from(data['history'] ?? []);

      if (!mounted) return;

      setState(() {
        _today = todayRaw is Map ? Map<String, dynamic>.from(todayRaw) : null;

        _history = historyRaw
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
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

  String _time(dynamic value) {
    if (value == null) return '-';

    final text = value.toString().trim();

    if (text.isEmpty) return '-';

    final dateTime = DateTime.tryParse(text);

    if (dateTime == null) return text;

    final hour = dateTime.hour.toString().padLeft(2, '0');

    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute น.';
  }

  String _date(dynamic value) {
    if (value == null) return '-';

    final text = value.toString();

    final parts = text.split('-');

    if (parts.length != 3) return text;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return text;
    }

    return '$day/${month.toString().padLeft(2, '0')}/${year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เวลาเข้า-ออก'),
        actions: [
          IconButton(
            tooltip: 'รีเฟรช',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
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
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 16),
              Text(_error, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _studentHeader(),

          const SizedBox(height: 16),

          Text(
            'วันนี้',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _todayCard(),

          const SizedBox(height: 26),

          Text(
            'ประวัติการเข้า-ออก',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          if (_history.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('ยังไม่มีประวัติการเข้า-ออก')),
              ),
            )
          else
            ..._history.map(_historyCard),
        ],
      ),
    );
  }

  Widget _studentHeader() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.school)),
        title: Text(
          widget.student.name.isEmpty
              ? 'นักเรียน ${widget.student.studentId}'
              : widget.student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'รหัส ${widget.student.studentId}'
          '${widget.student.classroom.isNotEmpty ? ' • ห้อง ${widget.student.classroom}' : ''}',
        ),
      ),
    );
  }

  Widget _todayCard() {
    if (_today == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48),
                SizedBox(height: 12),
                Text('วันนี้ยังไม่มีข้อมูลการสแกน'),
              ],
            ),
          ),
        ),
      );
    }

    return _attendanceCard(_today!, showDate: false);
  }

  Widget _historyCard(Map<String, dynamic> row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _attendanceCard(row, showDate: true),
    );
  }

  Widget _attendanceCard(Map<String, dynamic> row, {required bool showDate}) {
    final status = '${row['late_status'] ?? ''}'.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDate) ...[
              Text(
                _date(row['date']),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
            ],

            Row(
              children: [
                Expanded(
                  child: _timeBox(
                    icon: Icons.login,
                    title: 'เข้า',
                    value: _time(row['workin']),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _timeBox(
                    icon: Icons.logout,
                    title: 'ออก',
                    value: _time(row['workout']),
                  ),
                ),
              ],
            ),

            if (status.isNotEmpty) ...[
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 6),
                  Text('สถานะ: $status'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(title),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
