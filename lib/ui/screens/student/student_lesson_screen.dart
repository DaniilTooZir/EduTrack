import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';

class StudentLessonScreen extends StatefulWidget {
  const StudentLessonScreen({super.key});

  @override
  State<StudentLessonScreen> createState() => _StudentLessonScreenState();
}

class _StudentLessonScreenState extends State<StudentLessonScreen> {
  final LessonService _lessonService = LessonService();
  final ScheduleService _scheduleService = ScheduleService();

  bool _loading = true;
  List<Lesson> _lessons = [];
  List<Schedule> _schedules = [];
  String? get studentId => Provider.of<UserProvider>(context, listen: false).userId;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    if (studentId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final schedules = await _scheduleService.getScheduleForStudent(studentId!);
      _schedules = schedules;
      List<Lesson> allLessons = [];
      for (var schedule in schedules) {
        final lessons = await _lessonService.getLessonsByScheduleId(schedule.id);
        allLessons.addAll(lessons);
      }
      allLessons.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      setState(() {
        _lessons = allLessons;
      });
    } catch (e) {
      print('Ошибка при загрузке уроков: $e');
    }
    setState(() => _loading = false);
  }

  Widget _buildLessonTile(Lesson lesson) {
    return FutureBuilder<Schedule?>(
      future: _scheduleService.getScheduleById(lesson.scheduleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Загрузка...'), subtitle: LinearProgressIndicator());
        }
        final schedule = snapshot.data!;
        final subjectName = schedule.subject?.name ?? 'Предмет';
        final dateString =
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
                Text('📘 Предмет: $subjectName'),
                Text('📅 $dateString'),
                Text('🕐 ${schedule.startTime} - ${schedule.endTime}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                context.push('/student/lesson_comments', extra: lesson.id);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои уроки')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _lessons.isEmpty
              ? const Center(child: Text('Пока нет уроков'))
              : ListView.builder(
                itemCount: _lessons.length,
                itemBuilder: (context, index) => _buildLessonTile(_lessons[index]),
              ),
    );
  }
}
