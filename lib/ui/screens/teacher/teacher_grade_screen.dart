import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  final Map<String, int?> _grades = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Lesson) {
        lesson = extra;
        _loadData();
      } else {
        context.pop();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schedule = await _studentService.getScheduleById(lesson.scheduleId);
      if (schedule == null) throw Exception('Не удалось найти расписание урока');
      final groupId = schedule.groupId;
      _students = await _studentService.getStudentsByGroupId(groupId);

      // Загружается же существующие оценки (если есть) - опционально, пока просто инит null
      // В идеале тут нужен метод getGradesByLesson, но пока оставлю простую логику
      for (final student in _students) {
        _grades[student.id] = null;
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке студентов: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitGrades() async {
    for (final entry in _grades.entries) {
      final studentId = entry.key;
      final gradeValue = entry.value;
      if (gradeValue != null) {
        // lesson.id (int?) -> если null, то сохранять нельзя, но он должен быть
        if (lesson.id != null) {
          final grade = Grade(lessonId: lesson.id!, studentId: studentId, value: gradeValue);
          await _gradeService.addOrUpdateGrade(grade);
        }
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оценки сохранены')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Оценка студентов')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: colors.surface,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colors.primaryContainer,
                                  child: Text(
                                    student.name[0],
                                    style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  '${student.surname} ${student.name}',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _grades[student.id],
                                      dropdownColor: colors.surface,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                                      items:
                                          [2, 3, 4, 5]
                                              .map(
                                                (grade) => DropdownMenuItem(
                                                  value: grade,
                                                  child: Text(
                                                    grade.toString(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      hint: Text('—', style: TextStyle(color: colors.onSurfaceVariant)),
                                      onChanged: (val) {
                                        setState(() {
                                          _grades[student.id] = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Сохранить оценки'),
                          onPressed: _submitGrades,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
