import 'package:edu_track/data/services/lesson_attendance_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonAttendanceScreen extends StatefulWidget {
  const LessonAttendanceScreen({super.key});

  @override
  State<LessonAttendanceScreen> createState() => _LessonAttendanceScreenState();
}

class _LessonAttendanceScreenState extends State<LessonAttendanceScreen> {
  late Lesson lesson;
  final _studentService = StudentService();
  final _attendanceService = AttendanceService();

  List<Student> _students = [];
  Map<String, String?> _attendance = {};
  bool _loading = true;

  final List<String> statuses = ['был', 'н', 'нб'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lesson = GoRouter.of(context).state.extra as Lesson;
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    final schedule = await _studentService.getScheduleById(lesson.scheduleId);
    if (schedule == null) {
      setState(() => _loading = false);
      return;
    }
    final students = await _studentService.getStudentsByGroupId(schedule.groupId);
    setState(() {
      _students = students;
      _attendance = {for (final s in students) s.id: null};
      _loading = false;
    });
  }

  Future<void> _save() async {
    for (final entry in _attendance.entries) {
      if (entry.value == null) continue;
      final record = LessonAttendance(lessonId: lesson.id!, studentId: entry.key, status: entry.value);
      await _attendanceService.addOrUpdateAttendance(record);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Посещаемость сохранена')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Посещаемость урока')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final st = _students[index];
                        return ListTile(
                          title: Text('${st.surname} ${st.name}'),
                          trailing: DropdownButton<String>(
                            value: _attendance[st.id],
                            items:
                                statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                            hint: const Text('Статус'),
                            onChanged: (v) {
                              setState(() {
                                _attendance[st.id] = v;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
    );
  }
}
