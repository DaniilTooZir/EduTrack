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
  Map<int, List<Schedule>> _groupedByDay = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final teacherId = context.read<UserProvider>().userId;
    if (teacherId == null) return;
    final list = await _scheduleService.getScheduleForTeacher(teacherId);
    list.sort((a, b) {
      final weekday = a.weekday.compareTo(b.weekday);
      if (weekday != 0) return weekday;
      return a.startTime.compareTo(b.startTime);
    });

    final grouped = <int, List<Schedule>>{};
    for (var entry in list) {
      grouped.putIfAbsent(entry.weekday, () => []);
      grouped[entry.weekday]!.add(entry);
    }

    setState(() {
      _scheduleList = list;
      _groupedByDay = grouped;
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
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _scheduleList.isEmpty
                  ? _buildEmpty(theme)
                  : _buildGroupedList(theme),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Расписание не найдено.',
          style: theme.textTheme.headlineSmall?.copyWith(color: const Color(0xFF5E35B1), fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGroupedList(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
        return Center(
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView(
              children: [
                for (int weekday in _groupedByDay.keys) ...[
                  _buildDayHeader(weekday, theme),
                  ..._groupedByDay[weekday]!.map((e) => _buildLessonCard(e, theme)).toList(),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(int weekday, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        _weekdays[weekday - 1],
        style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFF512DA8), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLessonCard(Schedule entry, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shadowColor: const Color(0xFF9575CD).withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Предмет: ${entry.subjectName ?? "—"}')));
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
                'Время: ${entry.startTime} — ${entry.endTime}',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7E57C2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
