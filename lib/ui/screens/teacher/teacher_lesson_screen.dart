import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TeacherLessonScreen extends StatefulWidget {
  const TeacherLessonScreen({super.key});

  @override
  State<TeacherLessonScreen> createState() => _TeacherLessonScreenState();
}

class _TeacherLessonScreenState extends State<TeacherLessonScreen> {
  final LessonService _lessonService = LessonService();
  final ScheduleService _scheduleService = ScheduleService();
  final SubjectService _subjectService = SubjectService();
  final GroupService _groupService = GroupService();
  List<Lesson> _lessons = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  bool _isLoading = true;
  String? get teacherId => Provider.of<UserProvider>(context, listen: false).userId;
  String? get institutionId => Provider.of<UserProvider>(context, listen: false).institutionId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (teacherId == null || institutionId == null) return;
    setState(() => _isLoading = true);
    try {
      _groups = await _groupService.getGroups(institutionId!);
      _subjects = await _subjectService.getSubjectsByTeacherId(teacherId!);
      final schedules = await _scheduleService.getScheduleForTeacher(teacherId!);
      final List<Lesson> allLessons = [];
      for (final schedule in schedules) {
        final lessons = await _lessonService.getLessonsByScheduleId(schedule.id);
        allLessons.addAll(lessons);
      }
      //allLessons.sort((a, b) => (b.id ?? '').compareTo(a.id ?? '')); пока не будет сортироваться, т.к. id теперь uuid
      if (mounted) {
        setState(() {
          _lessons = allLessons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  Widget _buildLessonTile(Lesson lesson, ColorScheme colors) {
    return FutureBuilder<Schedule?>(
      future: _scheduleService.getScheduleById(lesson.scheduleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: LinearProgressIndicator()));
        }
        final schedule = snapshot.data!;
        final subjectName = schedule.subject?.name ?? 'Предмет';
        final groupName = schedule.group?.name ?? 'Группа';
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
                      onPressed: () => context.push('/teacher/lesson_comments', extra: lesson.id),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Чат'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => context.push('/teacher/grades', extra: lesson),
                      icon: const Icon(Icons.grade, size: 18),
                      label: const Text('Оценки'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
              try {
                final teacherSchedules = await _scheduleService.getScheduleForTeacher(teacherId!);
                final filtered =
                    teacherSchedules
                        .where((s) => s.groupId == selectedGroup!.id && s.subjectId == selectedSubject!.id)
                        .toList();
                setStateDialog(() {
                  availableSchedules = filtered;
                  selectedSchedule = null;
                  isDialogLoading = false;
                });
              } catch (e) {
                setStateDialog(() => isDialogLoading = false);
              }
            }

            return AlertDialog(
              title: const Text('Добавить занятие'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
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
                        value: selectedGroup,
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
                    try {
                      final lesson = Lesson(
                        scheduleId: selectedSchedule!.id,
                        topic: topicController.text.trim(),
                        attendanceStatus: 'pending',
                      );
                      await _lessonService.addLesson(lesson);
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Занятие добавлено'), backgroundColor: Colors.green));
                      _loadData();
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
                    }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Провести занятие', onPressed: _showAddLessonDialog),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lessons.isEmpty
                  ? Center(
                    child: Text('Проведенных занятий пока нет', style: TextStyle(color: colors.onSurfaceVariant)),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _lessons.length,
                    itemBuilder: (context, index) => _buildLessonTile(_lessons[index], colors),
                  ),
        ),
      ),
    );
  }
}
