import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = true;
  List<Schedule> _schedule = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    try {
      final data = await _scheduleService.getScheduleForStudent(studentId);
      setState(() {
        _schedule = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки расписания: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_schedule.isEmpty) {
      return const Center(child: Text('Расписание отсутствует.'));
    }

    final grouped = <int, List<Schedule>>{};
    for (final s in _schedule) {
      grouped.putIfAbsent(s.weekday, () => []).add(s);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final dayName = _weekdayName(entry.key);
        final lessons = entry.value..sort((a, b) => a.startTime.compareTo(b.startTime));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...lessons.map((s) => Card(
              child: ListTile(
                title: Text('Время: ${s.startTime} – ${s.endTime}'),
                subtitle: Text('Предмет: ${s.subjectName ?? 'неизвестно'}'),
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _weekdayName(int weekday) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return (weekday >= 1 && weekday <= 7) ? days[weekday - 1] : 'Неизвестный день';
  }
}