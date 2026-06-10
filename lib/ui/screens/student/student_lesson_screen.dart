import 'package:edu_track/data/repositories/lesson_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/services/lesson_comment_service.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _LessonSort { dateDesc, dateAsc, subjectAsc }

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({super.key});

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen> with SingleTickerProviderStateMixin {
  LessonRepository get _lessonRepository => Provider.of<LessonRepository>(context, listen: false);
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  final _commentService = LessonCommentService();

  late final TabController _tabController;

  bool _loading = true;
  List<Lesson> _lessons = [];
  Map<String, Schedule> _scheduleCache = {};
  Map<String, int> _teacherCommentCounts = {};
  _LessonSort _sortOrder = _LessonSort.dateDesc;
  String? _filterSubject;

  String? get studentId => Provider.of<UserProvider>(context, listen: false).userId;

  List<String> get _subjectNames {
    final names =
        _scheduleCache.values.map((s) => s.subject?.name).where((n) => n != null).cast<String>().toSet().toList()
          ..sort();
    return names;
  }

  List<Lesson> get _displayedLessons {
    var list = List<Lesson>.from(_lessons);
    if (_filterSubject != null) {
      list = list.where((l) => _scheduleCache[l.scheduleId]?.subject?.name == _filterSubject).toList();
    }
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

  static const _futureDays = 14;

  DateTime get _todayDate {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  List<Lesson> get _currentLessons {
    final today = _todayDate;
    final futureCutoff = today.add(const Duration(days: _futureDays));
    return _displayedLessons.where((l) {
      final d = _scheduleCache[l.scheduleId]?.date;
      if (d == null) return true;
      return !d.isBefore(today) && !d.isAfter(futureCutoff);
    }).toList();
  }

  List<Lesson> get _pastLessons {
    final today = _todayDate;
    return _displayedLessons.where((l) {
      final d = _scheduleCache[l.scheduleId]?.date;
      return d != null && d.isBefore(today);
    }).toList();
  }

  int get _hiddenFutureCount {
    final futureCutoff = _todayDate.add(const Duration(days: _futureDays));
    return _displayedLessons.where((l) {
      final d = _scheduleCache[l.scheduleId]?.date;
      return d != null && d.isAfter(futureCutoff);
    }).length;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLessons());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (!mounted) return;
    final lessonsList = lessonsResult.isSuccess ? lessonsResult.data : <Lesson>[];
    final lessonIds = lessonsList.map((l) => l.id).whereType<String>().toList();
    final countsResult = await _commentService.getTeacherCommentCountsForLessons(lessonIds);
    if (mounted) {
      setState(() {
        _lessons = lessonsList;
        _scheduleCache = cache;
        _teacherCommentCounts = countsResult.isSuccess ? countsResult.data : {};
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
    final timeStr = '${schedule.startTime.substring(0, 5)} - ${schedule.endTime.substring(0, 5)}';
    final hasTeacherComments = (lesson.id != null) && (_teacherCommentCounts[lesson.id] ?? 0) > 0;

    final dateBadge =
        date != null
            ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onPrimaryContainer),
                  ),
                  Text(
                    _getMonthName(date.month),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            )
            : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat, size: 20, color: colors.onSecondaryContainer),
                  const SizedBox(height: 2),
                  Text(
                    'еженед.',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.onSecondaryContainer),
                  ),
                ],
              ),
            );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: AppRadius.card,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: () => context.push(AppRoutes.studentLessonCommentsPath(lesson.id!)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                dateBadge,
                const SizedBox(width: AppSpacing.l),
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.secondaryContainer),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        color: colors.onSecondaryContainer,
                        tooltip: 'Открыть чат урока',
                        onPressed: () => context.push(AppRoutes.studentLessonCommentsPath(lesson.id!)),
                      ),
                    ),
                    if (hasTeacherComments)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                        ),
                      ),
                  ],
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

  Widget _buildLessonListView(List<Lesson> lessons, ColorScheme colors, {bool showHiddenFuture = false}) {
    final hiddenCount = showHiddenFuture ? _hiddenFutureCount : 0;
    if (_lessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.class_outlined, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: AppSpacing.l),
                  Text('Пока нет проведенных уроков', style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (lessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 200,
            child: Center(child: Text('Нет уроков', style: TextStyle(color: colors.onSurfaceVariant))),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 6, bottom: hiddenCount > 0 ? 4 : 20),
      itemCount: lessons.length + (hiddenCount > 0 ? 1 : 0),
      itemBuilder: (context, index) {
        if (hiddenCount > 0 && index == lessons.length) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility_off_outlined, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Скрыто $hiddenCount занятий (дальше $_futureDays дней)',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          );
        }
        final lesson = lessons[index];
        final schedule = _scheduleCache[lesson.scheduleId];
        if (schedule == null) return const SizedBox.shrink();
        return _buildLessonCard(lesson, schedule, colors);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final pastCount = _pastLessons.length;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _loading
                  ? _buildLessonsSkeleton()
                  : Column(
                    children: [
                      Material(
                        color: colors.surface,
                        elevation: 1,
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            const Tab(text: 'Актуальные'),
                            Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Прошедшие'),
                                  if (pastCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$pastCount',
                                        style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
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
                      if (_subjectNames.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: const Text('Все'),
                                  selected: _filterSubject == null,
                                  onSelected: (_) => setState(() => _filterSubject = null),
                                ),
                              ),
                              ..._subjectNames.map(
                                (name) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: Text(name),
                                    selected: _filterSubject == name,
                                    onSelected:
                                        (_) => setState(() => _filterSubject = _filterSubject == name ? null : name),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadLessons,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLessonListView(_currentLessons, colors, showHiddenFuture: true),
                              _buildLessonListView(_pastLessons, colors),
                            ],
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
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: 5,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Skeleton(height: 60, width: 60),
                const SizedBox(width: AppSpacing.l),
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
