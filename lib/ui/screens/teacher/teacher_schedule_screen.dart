import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  Future<void> _loadSchedule() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final teacherId = userProvider.userId;
    final db = Provider.of<AppDatabase>(context, listen: false);
    if (teacherId == null) return;
    try {
      final list = await _scheduleService.getScheduleForTeacher(teacherId, db);
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
      if (mounted) {
        setState(() {
          _scheduleList = list;
          _groupedSchedule = grouped;
          _isLoading = false;
        });
      }
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_scheduleList.isEmpty) {
      return Center(
        child: Text('Расписание отсутствует.', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
      );
    }
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map((s) => _buildScheduleCard(s, colors)),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule s, ColorScheme colors) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: colors.surface.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  '${s.startTime.substring(0, 5)} – ${s.endTime.substring(0, 5)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.book, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.subjectName ?? 'Предмет',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.group, size: 20, color: colors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Группа: ${s.groupName}', style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
