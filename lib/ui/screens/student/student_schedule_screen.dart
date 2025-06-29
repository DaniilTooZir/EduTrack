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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки расписания: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_schedule.isEmpty) {
      return Center(
        child: Text(
          'Расписание отсутствует.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
      );
    }
    final grouped = <int, List<Schedule>>{};
    for (final s in _schedule) {
      grouped.putIfAbsent(s.weekday, () => []).add(s);
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
                grouped.entries.map((entry) {
                  final dayName = _weekdayName(entry.key);
                  final lessons =
                      entry.value
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...lessons.map(
                        (s) => Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: Colors.white.withOpacity(0.85),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${s.startTime} – ${s.endTime}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.book,
                                      size: 20,
                                      color: Colors.deepPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        s.subjectName ?? 'неизвестно',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
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
    return (weekday >= 1 && weekday <= 7)
        ? days[weekday - 1]
        : 'Неизвестный день';
  }
}
