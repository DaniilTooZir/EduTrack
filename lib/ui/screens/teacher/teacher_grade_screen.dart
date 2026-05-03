import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
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
    final scheduleResult = await _studentService.getScheduleById(lesson.scheduleId);
    if (scheduleResult.isFailure || scheduleResult.data == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final groupId = scheduleResult.data!.groupId;
    final studentsResult = await _studentService.getStudentsByGroupId(groupId);
    final gradesResult = await _gradeService.getGradesByLesson(lesson.id!);
    if (!mounted) return;
    if (studentsResult.isFailure || gradesResult.isFailure) {
      setState(() => _isLoading = false);
      return;
    }
    final students = studentsResult.data;
    final grades = gradesResult.data;
    setState(() {
      _students = students;
      final Map<String, int> existingGradesMap = {for (final g in grades) g.studentId: g.value};
      for (final student in _students) {
        _grades[student.id] = existingGradesMap[student.id];
      }
      _isLoading = false;
    });
  }

  Future<void> _submitGrades() async {
    for (final entry in _grades.entries) {
      final gradeValue = entry.value;
      if (gradeValue != null && lesson.id != null) {
        final grade = Grade(lessonId: lesson.id!, studentId: entry.key, value: gradeValue);
        final result = await _gradeService.addOrUpdateGrade(grade);
        if (result.isFailure) {
          MessengerHelper.showError(result.errorMessage);
          return;
        }
      }
    }
    if (!mounted) return;
    MessengerHelper.showSuccess('Оценки сохранены');
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
                  ? _buildGradesSkeleton()
                  : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
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
                                                      color:
                                                          grade >= 4
                                                              ? Colors.green
                                                              : (grade == 3 ? Colors.orange : Colors.red),
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
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildGradesSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Skeleton(height: 40, width: 40, borderRadius: 20),
                const SizedBox(width: 12),
                const Skeleton(height: 16, width: 150),
                const Spacer(),
                const Skeleton(height: 40, width: 60, borderRadius: 8),
              ],
            ),
          ),
    );
  }
}
