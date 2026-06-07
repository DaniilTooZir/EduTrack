import 'package:edu_track/data/repositories/lesson_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _LessonSort { dateDesc, dateAsc, subjectAsc }

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({super.key});

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen> {
  LessonRepository get _lessonRepository => Provider.of<LessonRepository>(context, listen: false);
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);

  bool _loading = true;
  List<Lesson> _lessons = [];
  Map<String, Schedule> _scheduleCache = {};
  _LessonSort _sortOrder = _LessonSort.dateDesc;

  String? get studentId => Provider.of<UserProvider>(context, listen: false).userId;

  List<Lesson> get _displayedLessons {
    final list = List<Lesson>.from(_lessons);
    list.sort((a, b) {
      final sa = _scheduleCache[a.scheduleId];
      final sb = _scheduleCache[b.scheduleId];
      switch (_sortOrder) {
        case _LessonSort.dateDesc:
          final dateA = sa?.date;
          final dateB = sb?.date;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          final cmp = dateB.compareTo(dateA);
          if (cmp != 0) return cmp;
          return (sb?.startTime ?? '').compareTo(sa?.startTime ?? '');
        case _LessonSort.dateAsc:
          final dateA = sa?.date;
          final dateB = sb?.date;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          final cmp = dateA.compareTo(dateB);
          if (cmp != 0) return cmp;
          return (sa?.startTime ?? '').compareTo(sb?.startTime ?? '');
        case _LessonSort.subjectAsc:
          final na = (sa?.subject?.name ?? '').toLowerCase();
          final nb = (sb?.subject?.name ?? '').toLowerCase();
          return na.compareTo(nb);
      }
    });
    return list;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLessons());
  }

  Future<void> _loadLessons() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sid = userProvider.userId;
    final groupId = userProvider.groupId;
    if (sid == null) return;
    setState(() => _loading = true);
    final schedulesResult = await _scheduleService.getScheduleForStudent(sid, groupId);
    if (schedulesResult.isFailure) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final cache = {for (final s in schedulesResult.data) s.id: s};
    final lessonsResult = await _lessonRepository.getLessonsByScheduleIds(cache.keys.toList());
    if (mounted) {
      setState(() {
        _lessons = lessonsResult.isSuccess ? lessonsResult.data : [];
        _scheduleCache = cache;
        _loading = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[month - 1];
  }

  Widget _buildLessonCard(Lesson lesson, Schedule schedule, ColorScheme colors) {
    final subjectName = schedule.subject?.name ?? 'Предмет';
    final date = schedule.date;
    final day = date != null ? date.day.toString().padLeft(2, '0') : '--';
    final month = date != null ? _getMonthName(date.month) : '';
    final timeStr = '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(AppRoutes.studentLessonComments, extra: lesson.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onPrimaryContainer),
                      ),
                      Text(
                        month,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.topic ?? 'Без темы',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: colors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(timeStr, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.secondaryContainer),
                  child: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    color: colors.onSecondaryContainer,
                    tooltip: 'Открыть чат',
                    onPressed: () => context.push(AppRoutes.studentLessonComments, extra: lesson.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _sortLabels = {
    _LessonSort.dateDesc: 'Новые сначала',
    _LessonSort.dateAsc: 'Старые сначала',
    _LessonSort.subjectAsc: 'По предмету А–Я',
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _loading
                  ? _buildLessonsSkeleton()
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                        child: Row(
                          children: [
                            Icon(Icons.sort, size: 18, color: colors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text('Сортировка:', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                            const Spacer(),
                            PopupMenuButton<_LessonSort>(
                              initialValue: _sortOrder,
                              onSelected: (v) => setState(() => _sortOrder = v),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _sortLabels[_sortOrder]!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: colors.primary),
                                  ],
                                ),
                              ),
                              itemBuilder:
                                  (_) =>
                                      _LessonSort.values
                                          .map((v) => PopupMenuItem(value: v, child: Text(_sortLabels[v]!)))
                                          .toList(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadLessons,
                          child:
                              _lessons.isEmpty
                                  ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.55,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.class_outlined,
                                                size: 64,
                                                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Пока нет проведенных уроков',
                                                style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 6, bottom: 20),
                                    itemCount: _displayedLessons.length,
                                    itemBuilder: (context, index) {
                                      final lesson = _displayedLessons[index];
                                      final schedule = _scheduleCache[lesson.scheduleId];
                                      if (schedule == null) return const SizedBox.shrink();
                                      return _buildLessonCard(lesson, schedule, colors);
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildLessonsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Skeleton(height: 60, width: 60),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(height: 14, width: 80),
                      SizedBox(height: 8),
                      Skeleton(height: 18, width: double.infinity),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
