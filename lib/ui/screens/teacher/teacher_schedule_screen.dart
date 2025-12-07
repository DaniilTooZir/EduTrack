import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});
  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
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
    final teacherId = context.read<UserProvider>().userId;
    if (teacherId == null) return;
    try {
      final list = await _scheduleService.getScheduleForTeacher(teacherId);
      list.sort((a, b) {
        if (a.date == null && b.date != null) return -1;
        if (a.date != null && b.date == null) return 1;
        if (a.date != null && b.date != null) {
          final int d = a.date!.compareTo(b.date!);
          if (d != 0) return d;
        }
        final int w = a.weekday.compareTo(b.weekday);
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

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';

  String _getWeekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return '';
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
      child: Text(
        'Расписание не найдено.',
        style: theme.textTheme.headlineSmall?.copyWith(color: const Color(0xFF5E35B1)),
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
              children:
                  _groupedSchedule.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            entry.key, // Заголовок с датой
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF512DA8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...entry.value.map((e) => _buildLessonCard(e, theme)),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonCard(Schedule entry, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.subjectName ?? 'Предмет',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5E35B1),
                  ),
                ),
                Text(
                  '${entry.startTime.substring(0, 5)} - ${entry.endTime.substring(0, 5)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Группа: ${entry.groupName}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
