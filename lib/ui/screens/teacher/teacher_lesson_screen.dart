import 'package:edu_track/data/repositories/lesson_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _LessonSort { dateDesc, dateAsc, subjectAsc }

class TeacherLessonScreen extends StatefulWidget {
  const TeacherLessonScreen({super.key});

  @override
  State<TeacherLessonScreen> createState() => _TeacherLessonScreenState();
}

class _TeacherLessonScreenState extends State<TeacherLessonScreen> with SingleTickerProviderStateMixin {
  LessonRepository get _lessonRepository => Provider.of<LessonRepository>(context, listen: false);
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  final SubjectService _subjectService = SubjectService();
  final GroupService _groupService = GroupService();

  late final TabController _tabController;

  List<Lesson> _lessons = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  Map<String, Schedule> _scheduleCache = {};

  bool _isLoading = true;
  String? _filterSubjectId;
  String? _filterGroupId;
  _LessonSort _sortOrder = _LessonSort.dateDesc;

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

  String? get teacherId => Provider.of<UserProvider>(context, listen: false).userId;
  String? get institutionId => Provider.of<UserProvider>(context, listen: false).institutionId;

  List<Group> get _relevantGroups {
    final groupIds = _scheduleCache.values.map((s) => s.groupId).toSet();
    return _groups.where((g) => groupIds.contains(g.id)).toList();
  }

  List<Lesson> get _displayedLessons {
    final list =
        _lessons.where((l) {
          final s = _scheduleCache[l.scheduleId];
          if (_filterSubjectId != null && s?.subjectId != _filterSubjectId) return false;
          if (_filterGroupId != null && s?.groupId != _filterGroupId) return false;
          return true;
        }).toList();
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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (teacherId == null || institutionId == null) return;
    setState(() => _isLoading = true);
    final groupsFuture = _groupService.getGroups(institutionId!);
    final subjectsFuture = _subjectService.getSubjectsByTeacherId(teacherId!);
    final schedulesFuture = _scheduleService.getScheduleForTeacher(teacherId!);
    final groupsResult = await groupsFuture;
    final subjectsResult = await subjectsFuture;
    final schedulesResult = await schedulesFuture;
    if (!mounted) return;
    if (schedulesResult.isFailure) {
      setState(() => _isLoading = false);
      return;
    }
    final cache = {for (final s in schedulesResult.data) s.id: s};
    final lessonsResult = await _lessonRepository.getLessonsByScheduleIds(cache.keys.toList());
    if (mounted) {
      setState(() {
        if (groupsResult.isSuccess) _groups = groupsResult.data;
        if (subjectsResult.isSuccess) _subjects = subjectsResult.data;
        _lessons = lessonsResult.isSuccess ? lessonsResult.data : [];
        _scheduleCache = cache;
        _isLoading = false;
      });
    }
  }

  Future<void> _editTopic(Lesson lesson) async {
    if (lesson.id == null) return;
    final controller = TextEditingController(text: lesson.topic ?? '');
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Тема урока',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Введите тему урока',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: ListenableBuilder(
                      listenable: controller,
                      builder:
                          (_, __) =>
                              controller.text.isNotEmpty
                                  ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: controller.clear)
                                  : const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(controller.text),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    final newTopic = result.trim().isEmpty ? null : result.trim();
    final res = await _lessonRepository.updateLessonTopic(lesson.id!, lesson.scheduleId, newTopic);
    if (!mounted) return;
    if (res.isFailure) {
      MessengerHelper.showError(res.errorMessage);
      return;
    }
    setState(() {
      final idx = _lessons.indexWhere((l) => l.id == lesson.id);
      if (idx >= 0) _lessons[idx] = _lessons[idx].copyWith(topic: newTopic);
    });
    MessengerHelper.showSuccess(newTopic == null ? 'Тема удалена' : 'Тема сохранена');
  }

  Widget _buildLessonTile(Lesson lesson, Schedule schedule, ColorScheme colors) {
    final subjectName =
        schedule.subject?.name ?? _subjects.where((s) => s.id == schedule.subjectId).firstOrNull?.name ?? 'Предмет';
    final groupName =
        schedule.group?.name ?? _groups.where((g) => g.id == schedule.groupId).firstOrNull?.name ?? 'Группа';
    final dateStr = schedule.date != null ? formatShortDate(schedule.date!) : 'Без даты';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.surface,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Text(
                subjectName[0],
                style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              lesson.topic ?? 'Без темы',
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subjectName, style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                Text(
                  '$dateStr • $groupName • ${schedule.startTime.substring(0, 5)}',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit_outlined, size: 20, color: colors.onSurfaceVariant),
              tooltip: 'Изменить тему',
              onPressed: () => _editTopic(lesson),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRoutes.teacherLessonCommentsPath(lesson.id!)),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Чат'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.teacherGrades, extra: lesson),
                  icon: const Icon(Icons.grade, size: 18),
                  label: const Text('Оценки'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLessonDialog() async {
    final formKey = GlobalKey<FormState>();
    final topicController = TextEditingController();
    Subject? selectedSubject;
    Group? selectedGroup;
    Schedule? selectedSchedule;
    List<Schedule> availableSchedules = [];
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateSchedules() {
              if (selectedGroup == null || selectedSubject == null) return;
              final filtered =
                  _scheduleCache.values
                      .where((s) => s.groupId == selectedGroup!.id && s.subjectId == selectedSubject!.id)
                      .toList();
              setStateDialog(() {
                availableSchedules = filtered;
                selectedSchedule = null;
              });
            }

            return AlertDialog(
              title: const Text('Добавить занятие'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Subject>(
                        decoration: const InputDecoration(labelText: 'Предмет', border: OutlineInputBorder()),
                        items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedSubject = val;
                            selectedGroup = null;
                            availableSchedules = [];
                          });
                        },
                        validator: (val) => val == null ? 'Выберите предмет' : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      DropdownButtonFormField<Group>(
                        decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                        initialValue: selectedGroup,
                        items: _relevantGroups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                        onChanged:
                            selectedSubject == null
                                ? null
                                : (val) {
                                  setStateDialog(() => selectedGroup = val);
                                  updateSchedules();
                                },
                        validator: (val) => val == null ? 'Выберите группу' : null,
                        hint: selectedSubject == null ? const Text('Сначала выберите предмет') : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      if (availableSchedules.isNotEmpty)
                        DropdownButtonFormField<Schedule>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Время урока', border: OutlineInputBorder()),
                          items:
                              availableSchedules.map((s) {
                                final dateStr = s.date != null ? formatShortDate(s.date!) : 'Еженедельно';
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    '$dateStr ${s.startTime}-${s.endTime}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) => setStateDialog(() => selectedSchedule = val),
                          validator: (val) => val == null ? 'Выберите время' : null,
                        )
                      else if (selectedGroup != null && selectedSubject != null)
                        const Text('В расписании нет занятий.', style: TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: AppSpacing.m),
                      TextFormField(
                        controller: topicController,
                        decoration: const InputDecoration(labelText: 'Тема занятия', border: OutlineInputBorder()),
                        validator: (val) => Validators.requiredField(val, fieldName: 'Тема'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    if (selectedSchedule == null) return;
                    final lesson = Lesson(
                      scheduleId: selectedSchedule!.id,
                      topic: topicController.text.trim(),
                      attendanceStatus: 'pending',
                    );
                    final navigator = Navigator.of(context);
                    final result = await _lessonRepository.addLesson(lesson);
                    if (!mounted) return;
                    if (result.isFailure) {
                      MessengerHelper.showError(result.errorMessage);
                      return;
                    }
                    navigator.pop();
                    MessengerHelper.showSuccess('Занятие добавлено');
                    await _loadData();
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const _sortLabels = {
    _LessonSort.dateDesc: 'Новые сначала',
    _LessonSort.dateAsc: 'Старые сначала',
    _LessonSort.subjectAsc: 'По предмету А–Я',
  };

  Widget _buildTabLessonList(List<Lesson> lessons, ColorScheme colors, {bool showHiddenFuture = false}) {
    final hiddenCount = showHiddenFuture ? _hiddenFutureCount : 0;
    if (_lessons.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Text('Проведенных занятий пока нет', style: TextStyle(color: colors.onSurfaceVariant)),
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
            child: Center(child: Text('Нет занятий', style: TextStyle(color: colors.onSurfaceVariant))),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12, 4, 12, hiddenCount > 0 ? 4 : 16),
      itemCount: lessons.length + (hiddenCount > 0 ? 1 : 0),
      itemBuilder: (context, index) {
        if (hiddenCount > 0 && index == lessons.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
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
        return _buildLessonTile(lesson, schedule, colors);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final hasFilter = _filterSubjectId != null || _filterGroupId != null;
    final pastCount = _pastLessons.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Занятия'),
        actions: [
          PopupMenuButton<_LessonSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            initialValue: _sortOrder,
            onSelected: (v) => setState(() => _sortOrder = v),
            itemBuilder:
                (_) => _LessonSort.values.map((v) => PopupMenuItem(value: v, child: Text(_sortLabels[v]!))).toList(),
          ),
          IconButton(icon: const Icon(Icons.add), tooltip: 'Провести занятие', onPressed: _showAddLessonDialog),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.onPrimary.withValues(alpha: 0.6),
          indicatorColor: colors.onPrimary,
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
                        color: colors.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$pastCount', style: TextStyle(fontSize: 11, color: colors.onPrimary)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _isLoading
                  ? _buildTeacherLessonsSkeleton()
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _filterSubjectId,
                                decoration: InputDecoration(
                                  labelText: 'Предмет',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(child: Text('Все')),
                                  ..._subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                                ],
                                onChanged: (v) => setState(() => _filterSubjectId = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _filterGroupId,
                                decoration: InputDecoration(
                                  labelText: 'Группа',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(child: Text('Все')),
                                  ..._relevantGroups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                                ],
                                onChanged: (v) => setState(() => _filterGroupId = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasFilter)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                'Найдено: ${_displayedLessons.length} из ${_lessons.length}',
                                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed:
                                    () => setState(() {
                                      _filterSubjectId = null;
                                      _filterGroupId = null;
                                    }),
                                child: const Text('Сбросить'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTabLessonList(_currentLessons, colors, showHiddenFuture: true),
                              _buildTabLessonList(_pastLessons, colors),
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

  Widget _buildTeacherLessonsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Skeleton(height: 48, width: 48, borderRadius: 24),
                      SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(height: 16, width: 120),
                            SizedBox(height: 8),
                            Skeleton(height: 12, width: 200),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Skeleton(height: 36, width: 80, borderRadius: 18),
                      SizedBox(width: 8),
                      Skeleton(height: 36, width: 100, borderRadius: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
