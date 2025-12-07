import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});
  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = true;
  List<Schedule> _scheduleList = [];
  Map<String, List<Schedule>> _groupedSchedule = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    try {
      final list = await _scheduleService.getScheduleForStudent(studentId);
      list.sort((a, b) {
        if (a.date == null && b.date != null) return -1;
        if (a.date != null && b.date == null) return 1;
        if (a.date != null && b.date != null) {
          final d = a.date!.compareTo(b.date!);
          if (d != 0) return d;
        }
        final w = a.weekday.compareTo(b.weekday);
        if (w != 0) return w;
        return a.startTime.compareTo(b.startTime);
      });

      final Map<String, List<Schedule>> grouped = {};
      for (final s in list) {
        String header = _getWeekdayName(s.weekday);
        if (s.date != null) {
          header += ', ${_formatDate(s.date!)}';
        }
        grouped.putIfAbsent(header, () => []).add(s);
      }

      setState(() {
        _scheduleList = list;
        _groupedSchedule = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  String _getWeekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return 'День $weekday';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_scheduleList.isEmpty) {
      return Center(
        child: Text('Расписание отсутствует.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children:
                _groupedSchedule.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map(_buildScheduleCard),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule s) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '${s.startTime.substring(0, 5)} – ${s.endTime.substring(0, 5)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.book, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.subjectName ?? 'Предмет',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(s.teacherName, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
