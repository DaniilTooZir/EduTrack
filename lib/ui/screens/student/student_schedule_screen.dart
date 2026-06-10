import 'dart:async';

import 'package:edu_track/data/repositories/lesson_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  LessonRepository get _lessonRepository => Provider.of<LessonRepository>(context, listen: false);
  bool _isLoading = true;
  bool _initialized = false;
  String? _error;
  List<Schedule> _scheduleList = [];
  Map<String, List<Schedule>> _groupedSchedule = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadSchedule();
    }
  }

  Future<void> _loadSchedule() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.userId;
    final groupId = userProvider.groupId;
    if (studentId == null) return;
    final result = await _scheduleService.getScheduleForStudent(studentId, groupId);
    if (result.isFailure) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = result.errorMessage;
        });
      }
      return;
    }
    _error = null;
    final now = DateTime.now();
    final mondayThisWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final endDate = DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 13, 23, 59, 59);

    final list =
        result.data.where((s) {
          if (s.date == null) return true;
          return !s.date!.isBefore(mondayThisWeek) && !s.date!.isAfter(endDate);
        }).toList();
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
        header += ', ${formatDate(s.date!)}';
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
  }

  String _getWeekdayName(int weekday) {
    const days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    if (weekday >= 1 && weekday <= 7) return days[weekday - 1];
    return 'День $weekday';
  }

  Future<void> _navigateToLesson(Schedule schedule) async {
    final result = await _lessonRepository.getLessonsByScheduleIds([schedule.id]);
    if (!mounted) return;
    if (result.isFailure || result.data.isEmpty) {
      MessengerHelper.showWarning('Урок по этому занятию ещё не проведён');
      return;
    }
    unawaited(context.push(AppRoutes.studentLessonCommentsPath(result.data.first.id!)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) return _buildLoadingSkeleton();
    if (_error != null) return AppErrorView(message: _error!, onRetry: _loadSchedule);
    if (_scheduleList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSchedule,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text('Расписание отсутствует.', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: _loadSchedule,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToLesson(s),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
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
                        Icon(Icons.person, size: 20, color: colors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.teacherName, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
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
