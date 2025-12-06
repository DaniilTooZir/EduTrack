import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
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
      allLessons.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
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

  Widget _buildLessonTile(Lesson lesson) {
    return FutureBuilder<Schedule?>(
      future: _scheduleService.getScheduleById(lesson.scheduleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: LinearProgressIndicator()));
        }
        final schedule = snapshot.data!;
        final subjectName = schedule.subject?.name ?? 'Неизвестный предмет';
        final groupName = schedule.group?.name ?? 'Неизвестная группа';
        final dateStr =
            schedule.date != null
                ? '${schedule.date!.day.toString().padLeft(2, '0')}.${schedule.date!.month.toString().padLeft(2, '0')}'
                : 'Без даты';
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF9575CD),
              child: Text(subjectName[0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(lesson.topic ?? 'Без темы', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$dateStr • $groupName • ${schedule.startTime}'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionButton(
                      icon: Icons.chat,
                      label: 'Чат',
                      onTap: () => context.push('/teacher/lesson_comments', extra: lesson.id),
                    ),
                    _ActionButton(
                      icon: Icons.grade,
                      label: 'Оценки',
                      onTap: () => context.push('/teacher/grades', extra: lesson),
                    ),
                    _ActionButton(
                      icon: Icons.check_circle,
                      label: 'Посещ.',
                      onTap: () => context.push('/teacher/attendance', extra: lesson),
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
                                final weekday = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][s.weekday - 1];
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    '$dateStr ($weekday) ${s.startTime}-${s.endTime}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) => setStateDialog(() => selectedSchedule = val),
                          validator: (val) => val == null ? 'Выберите время' : null,
                        )
                      else if (selectedGroup != null && selectedSubject != null)
                        const Text(
                          'В расписании нет занятий по этому предмету для этой группы.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 12),
                      // 4. Тема занятия
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
                      final lesson = Lesson(scheduleId: selectedSchedule!.id, topic: topicController.text.trim());
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Провести занятие', onPressed: _showAddLessonDialog),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _lessons.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Проведенных занятий пока нет', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _lessons.length,
                itemBuilder: (context, index) => _buildLessonTile(_lessons[index]),
              ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF5E35B1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5E35B1))),
          ],
        ),
      ),
    );
  }
}
