import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
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
  late final GradeRepository _gradeService;
  final _studentService = StudentService();
  List<Student> _students = [];
  final Map<String, int?> _grades = {};
  bool _isLoading = true;
  bool _hasModifiedGrades = false;

  final _searchController = TextEditingController();
  bool _onlyUngraded = false;

  List<Student> get _filteredStudents {
    final list =
        _students.where((s) {
          final q = _searchController.text.trim().toLowerCase();
          if (q.isNotEmpty) {
            final fullName = '${s.surname} ${s.name}'.toLowerCase();
            if (!fullName.contains(q)) return false;
          }
          if (_onlyUngraded && _grades[s.id] != null) return false;
          return true;
        }).toList();
    return list;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gradeService = Provider.of<GradeRepository>(context, listen: false);
      final extra = GoRouterState.of(context).extra;
      if (extra is Lesson) {
        lesson = extra;
        _loadData();
      } else {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final scheduleResult = await _studentService.getScheduleById(lesson.scheduleId);
    if (scheduleResult.isFailure || scheduleResult.data == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final groupId = scheduleResult.data!.groupId;
    final (studentsResult, gradesResult) =
        await (_studentService.getStudentsByGroupId(groupId), _gradeService.getGradesByLesson(lesson.id!)).wait;
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

  String _pluralStudents(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'студент';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'студента';
    return 'студентов';
  }

  Future<void> _submitGrades() async {
    final ungradedCount = _grades.values.where((v) => v == null).length;
    if (ungradedCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Не все студенты оценены'),
              content: Text('$ungradedCount ${_pluralStudents(ungradedCount)} остались без оценки. Продолжить?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Продолжить')),
              ],
            ),
      );
      if (confirmed != true) return;
    }
    if (!mounted) return;
    final gradesToSave =
        _grades.entries
            .where((e) => e.value != null && lesson.id != null)
            .map((e) => Grade(lessonId: lesson.id!, studentId: e.key, value: e.value!))
            .toList();
    final results = await Future.wait(gradesToSave.map((g) => _gradeService.addOrUpdateGrade(g)));
    if (!mounted) return;
    final failures = results.where((r) => r.isFailure);
    if (failures.isNotEmpty) {
      MessengerHelper.showError(failures.first.errorMessage);
      return;
    }
    MessengerHelper.showSuccess('Оценки сохранены');
    setState(() => _hasModifiedGrades = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_hasModifiedGrades,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Выйти без сохранения?'),
                content: const Text('Оценки не были сохранены. Покинуть экран?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Остаться')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Выйти')),
                ],
              ),
        );
        if (confirmed == true) {
          setState(() => _hasModifiedGrades = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Оценка студентов')),
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
          child: SafeArea(
            child:
                _isLoading
                    ? _buildGradesSkeleton()
                    : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Поиск по имени...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: _searchController.clear,
                                          )
                                          : null,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  FilterChip(
                                    label: const Text('Без оценки'),
                                    selected: _onlyUngraded,
                                    onSelected: (v) => setState(() => _onlyUngraded = v),
                                    avatar: Icon(
                                      Icons.remove_circle_outline,
                                      size: 16,
                                      color: _onlyUngraded ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_filteredStudents.length} из ${_students.length}',
                                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadData,
                            child:
                                _filteredStudents.isEmpty
                                    ? ListView(
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
                                    : ListView.separated(
                                      padding: const EdgeInsets.all(AppSpacing.l),
                                      itemCount: _filteredStudents.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final student = _filteredStudents[index];
                                        return Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          color: colors.surface,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: colors.primaryContainer,
                                              child: Text(
                                                student.name[0],
                                                style: TextStyle(
                                                  color: colors.onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              '${student.surname} ${student.name}',
                                              style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                                  [2, 3, 4, 5].map((grade) {
                                                    final isSelected = _grades[student.id] == grade;
                                                    final gradeColor =
                                                        grade >= 4
                                                            ? Colors.green
                                                            : (grade == 3 ? Colors.orange : Colors.red);
                                                    return GestureDetector(
                                                      onTap:
                                                          () => setState(() {
                                                            _grades[student.id] = isSelected ? null : grade;
                                                            _hasModifiedGrades = true;
                                                          }),
                                                      child: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 120),
                                                        width: 34,
                                                        height: 34,
                                                        margin: const EdgeInsets.only(left: 4),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isSelected
                                                                  ? gradeColor.withValues(alpha: 0.15)
                                                                  : colors.surfaceContainerHighest,
                                                          borderRadius: BorderRadius.circular(8),
                                                          border:
                                                              isSelected
                                                                  ? Border.all(color: gradeColor, width: 1.5)
                                                                  : null,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            grade.toString(),
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                              color: isSelected ? gradeColor : colors.onSurfaceVariant,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.l),
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
      ),
    );
  }

  Widget _buildGradesSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: 10,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Skeleton(height: 40, width: 40, borderRadius: 20),
                const SizedBox(width: AppSpacing.m),
                const Skeleton(height: 16, width: 150),
                const Spacer(),
                const Skeleton(height: 40, width: 60, borderRadius: 8),
              ],
            ),
          ),
    );
  }
}
