import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/data/services/grade_service.dart';

class TeacherGradeScreen extends StatefulWidget {
  const TeacherGradeScreen({super.key});

  @override
  State<TeacherGradeScreen> createState() => _TeacherGradeScreenState();
}

class _TeacherGradeScreenState extends State<TeacherGradeScreen> {
  late Lesson lesson;
  final _gradeService = GradeService();
  final _studentService = StudentService();
  List<Student> _students = [];
  Map<String, int?> _grades = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lesson = GoRouterState.of(context).extra as Lesson;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schedule = await _studentService.getScheduleById(lesson.scheduleId);
      if (schedule == null) throw Exception('Не удалось найти расписание урока');
      final groupId = schedule.groupId;
      _students = await _studentService.getStudentsByGroupId(groupId);
      for (var student in _students) {
        _grades[student.id] = null;
      }
    } catch (e) {
      print('Ошибка при загрузке студентов: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitGrades() async {
    for (var entry in _grades.entries) {
      final studentId = entry.key;
      final gradeValue = entry.value;
      if (gradeValue != null) {
        final grade = Grade(lessonId: lesson.id!, studentId: studentId, value: gradeValue);
        await _gradeService.addOrUpdateGrade(grade);
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оценки сохранены')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оценка студентов')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return ListTile(
                          title: Text('${student.name} ${student.surname}'),
                          trailing: DropdownButton<int>(
                            value: _grades[student.id],
                            items:
                                [2, 3, 4, 5]
                                    .map((grade) => DropdownMenuItem(value: grade, child: Text(grade.toString())))
                                    .toList(),
                            hint: const Text('Оценка'),
                            onChanged: (val) {
                              setState(() {
                                _grades[student.id] = val;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить оценки'),
                      onPressed: _submitGrades,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
                ],
              ),
    );
  }
}
