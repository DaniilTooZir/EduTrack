import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';

class TeacherLessonScreen extends StatefulWidget {
  const TeacherLessonScreen({super.key});

  @override
  State<TeacherLessonScreen> createState() => _TeacherLessonScreenState();
}

class _TeacherLessonScreenState extends State<TeacherLessonScreen> {
  final LessonService _lessonService = LessonService();
  final GroupService _groupService = GroupService();
  final SubjectService _subjectService = SubjectService();

  List<Lesson> _lessons = [];
  List<Group> _groups = [];
  List<Subject> _subjects = [];
  bool _isLoading = false;

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
      _subjects = await _subjectService.getSubjectsForInstitution(institutionId!);
      final schedules = await ScheduleService().getScheduleForInstitution(institutionId!);
      _lessons = [];

      for (var schedule in schedules) {
        final lessons = await _lessonService.getLessonsByScheduleId(schedule.id);
        _lessons.addAll(lessons);
      }
      _lessons.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
    }
    setState(() => _isLoading = false);
  }

  Widget _buildLessonTile(Lesson lesson) {
    final scheduleService = ScheduleService();
    return FutureBuilder<Schedule?>(
      future: scheduleService.getScheduleById(lesson.scheduleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator());
        }
        final schedule = snapshot.data;
        if (schedule == null) {
          return const ListTile(title: Text('Ошибка: расписание не найдено'));
        }
        final subject = _subjects.firstWhere(
          (s) => s.id == schedule.subjectId,
          orElse:
              () => Subject(id: '', name: 'Неизвестно', institutionId: '', teacherId: '', createdAt: DateTime.now()),
        );
        final group = _groups.firstWhere(
          (g) => g.id == schedule.groupId,
          orElse: () => Group(id: '', name: 'Неизвестно', institutionId: ''),
        );
        final formattedDate =
            schedule.date != null
                ? '${schedule.date!.day.toString().padLeft(2, '0')}.${schedule.date!.month.toString().padLeft(2, '0')}.${schedule.date!.year}'
                : 'Без даты';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            title: Text(lesson.topic ?? 'Без темы', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📘 Предмет: ${subject.name}'),
                Text('👥 Группа: ${group.name}'),
                Text('📅 $formattedDate  🕐 ${schedule.startTime} - ${schedule.endTime}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/teacher/lesson_comments', extra: lesson.id),
                ),
                IconButton(
                  icon: const Icon(Icons.grade_outlined),
                  onPressed: () => context.push('/teacher/grades', extra: lesson),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => context.push('/teacher/attendance', extra: lesson),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddLessonDialog() async {
    final formKey = GlobalKey<FormState>();
    Subject? selectedSubject;
    Group? selectedGroup;
    Schedule? selectedSchedule;
    List<Schedule> availableSchedules = [];
    final topicController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить занятие'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Subject>(
                        decoration: const InputDecoration(labelText: 'Предмет'),
                        items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedSubject = val;
                            selectedSchedule = null;
                            availableSchedules = [];
                          });
                        },
                        validator: (val) => val == null ? 'Выберите предмет' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Group>(
                        decoration: const InputDecoration(labelText: 'Группа'),
                        items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                        onChanged: (val) async {
                          setState(() {
                            selectedGroup = val;
                            selectedSchedule = null;
                            availableSchedules = [];
                          });
                          if (selectedGroup != null && selectedSubject != null) {
                            final allSchedules = await ScheduleService().getScheduleForInstitution(institutionId!);
                            final filtered =
                                allSchedules
                                    .where((s) => s.groupId == selectedGroup!.id && s.subjectId == selectedSubject!.id)
                                    .toList();
                            setState(() => availableSchedules = filtered);
                          }
                        },
                        validator: (val) => val == null ? 'Выберите группу' : null,
                      ),
                      const SizedBox(height: 12),
                      if (availableSchedules.isNotEmpty)
                        DropdownButtonFormField<Schedule>(
                          decoration: const InputDecoration(labelText: 'Расписание'),
                          items:
                              availableSchedules
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        '${s.date != null ? s.date!.toLocal().toString().split(" ")[0] : "Без даты"} '
                                        '${s.startTime} - ${s.endTime}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => setState(() => selectedSchedule = val),
                          validator: (val) => val == null ? 'Выберите расписание' : null,
                        )
                      else if (selectedGroup != null && selectedSubject != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Нет подходящих расписаний для выбранных предмета и группы',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: topicController,
                        decoration: const InputDecoration(labelText: 'Тема занятия'),
                        validator: (val) => val == null || val.isEmpty ? 'Введите тему' : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (selectedSchedule == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите расписание')));
                  return;
                }
                final lesson = Lesson(scheduleId: selectedSchedule!.id, topic: topicController.text.trim());
                try {
                  await _lessonService.addLesson(lesson);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Занятие добавлено')));
                  await _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои занятия'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddLessonDialog)],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _lessons.isEmpty
              ? const Center(child: Text('У вас пока нет занятий'))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _lessons.length,
                itemBuilder: (context, index) => _buildLessonTile(_lessons[index]),
              ),
    );
  }
}
