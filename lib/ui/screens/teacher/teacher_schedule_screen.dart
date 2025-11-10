import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = true;
  List<Schedule> _scheduleList = [];

  final List<String> _weekdays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;

    final schedule = await _scheduleService.getScheduleForTeacher(teacherId);
    setState(() {
      _scheduleList = schedule;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_scheduleList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Расписание не найдено.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF5E35B1),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Center(
                child: Container(
                  width: maxWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ListView.builder(
                    itemCount: _scheduleList.length,
                    itemBuilder: (context, index) {
                      final entry = _scheduleList[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shadowColor: const Color(0xFF9575CD).withOpacity(0.4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('Предмет: ${entry.subjectName ?? '—'}')));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.subjectName ?? 'Предмет',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5E35B1),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Группа: ${entry.groupName}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7E57C2)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'День: ${_weekdays[entry.weekday - 1]}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7E57C2)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Время: ${entry.startTime} — ${entry.endTime}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7E57C2)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
