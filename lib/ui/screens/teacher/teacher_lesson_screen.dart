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

class _TeacherLessonScreenState extends State<TeacherLessonScreen> {
  LessonRepository get _lessonRepository => Provider.of<LessonRepository>(context, listen: false);
  ScheduleRepository get _scheduleService => Provider.of<ScheduleRepository>(context, listen: false);
  final SubjectService _subjectService = SubjectService();
  final GroupService _groupService = GroupService();

  List<Lesson> _lessons = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  Map<String, Schedule> _scheduleCache = {};

  bool _isLoading = true;
  String? _filterSubjectId;
  String? _filterGroupId;
  _LessonSort _sortOrder = _LessonSort.dateDesc;

  String? get teacherId => Provider.of<UserProvider>(context, listen: false).userId;
  String? get institutionId => Provider.of<UserProvider>(context, listen: false).institutionId;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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

  Widget _buildLessonTile(Lesson lesson, Schedule schedule, ColorScheme colors) {
    final subjectName =
        schedule.subject?.name ?? _subjects.where((s) => s.id == schedule.subjectId).firstOrNull?.name ?? 'Предмет';
    final groupName =
        schedule.group?.name ?? _groups.where((g) => g.id == schedule.groupId).firstOrNull?.name ?? 'Группа';
    final dateStr =
        schedule.date != null
            ? '${schedule.date!.day.toString().padLeft(2, '0')}.${schedule.date!.month.toString().padLeft(2, '0')}'
            : 'Без даты';
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
            subtitle: Text(
              '$dateStr • $groupName • ${schedule.startTime}',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRoutes.teacherLessonComments, extra: lesson.id),
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
    bool isDialogLoading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> updateSchedules() async {
              if (selectedGroup == null || selectedSubject == null) return;
              setStateDialog(() => isDialogLoading = true);
              final result = await _scheduleService.getScheduleForTeacher(teacherId!);
              final filtered =
                  result.data
                      .where((s) => s.groupId == selectedGroup!.id && s.subjectId == selectedSubject!.id)
                      .toList();
              setStateDialog(() {
                availableSchedules = filtered;
                selectedSchedule = null;
                isDialogLoading = false;
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Group>(
                        decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                        initialValue: selectedGroup,
                        items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
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
                      const SizedBox(height: 12),
                      if (isDialogLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (availableSchedules.isNotEmpty)
                        DropdownButtonFormField<Schedule>(
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Время урока', border: OutlineInputBorder()),
                          items:
                              availableSchedules.map((s) {
                                final dateStr =
                                    s.date != null
                                        ? '${s.date!.day.toString().padLeft(2, '0')}.${s.date!.month.toString().padLeft(2, '0')}'
                                        : 'Еженедельно';
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
                      const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final hasFilter = _filterSubjectId != null || _filterGroupId != null;
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
                                  ..._groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
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
                          child:
                              _lessons.isEmpty
                                  ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.55,
                                        child: Center(
                                          child: Text(
                                            'Проведенных занятий пока нет',
                                            style: TextStyle(color: colors.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : _displayedLessons.isEmpty
                                  ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        child: Center(
                                          child: Text(
                                            'Ничего не найдено',
                                            style: TextStyle(color: colors.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(12),
                                    itemCount: _displayedLessons.length,
                                    itemBuilder: (context, index) {
                                      final lesson = _displayedLessons[index];
                                      final schedule = _scheduleCache[lesson.scheduleId];
                                      if (schedule == null) return const SizedBox.shrink();
                                      return _buildLessonTile(lesson, schedule, colors);
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

  Widget _buildTeacherLessonsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Skeleton(height: 48, width: 48, borderRadius: 24),
                      SizedBox(width: 12),
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
                  SizedBox(height: 16),
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
