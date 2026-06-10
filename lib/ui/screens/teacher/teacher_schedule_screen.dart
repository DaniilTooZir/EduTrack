import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/data_loading_mixin.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> with DataLoadingMixin {
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
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
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    await loadAsync(
      _scheduleService.getScheduleForTeacher(teacherId),
      onSuccess: (list) {
        final now = DateTime.now();
        final mondayThisWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final endDate = DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 13, 23, 59, 59);
        list.removeWhere((s) => s.date != null && (s.date!.isBefore(mondayThisWeek) || s.date!.isAfter(endDate)));
        final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
        final isPeriodActive = period == null || period.isCurrent();
        if (!isPeriodActive) list.removeWhere((s) => s.date == null);
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
          if (s.date != null) header += ', ${formatDate(s.date!)}';
          grouped.putIfAbsent(header, () => []).add(s);
        }
        _scheduleList = list;
        _groupedSchedule = grouped;
      },
    );
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
    if (isLoading) return _buildLoadingSkeleton();
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: _loadSchedule,
            child:
                _scheduleList.isEmpty
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              'Расписание отсутствует.',
                              style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ],
                    )
                    : ListView(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildScheduleCard(Schedule s, ColorScheme colors) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: colors.surface.withValues(alpha: 0.9),
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

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(AppSpacing.l),
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: AppRadius.card,
              ),
              child: const Row(
                children: [
                  Skeleton(height: 50, width: 50),
                  SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 18, width: 150),
                        SizedBox(height: 8),
                        Skeleton(height: 14, width: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
