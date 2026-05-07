import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/data/services/lesson_attendance_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double _nameColWidth = 160.0;
const double _cellWidth = 56.0;
const double _cellHeight = 48.0;
const double _headerHeight = 48.0;

Color _gradeColor(int value, ColorScheme colors) => switch (value) {
  5 => const Color(0xFF2E7D32),
  4 => const Color(0xFF558B2F),
  3 => const Color(0xFFE65100),
  _ => colors.error,
};

class TeacherJournalScreen extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final void Function(VoidCallback loadJournal)? onReady;

  const TeacherJournalScreen({super.key, required this.groupId, required this.subjectId, this.onReady});

  @override
  State<TeacherJournalScreen> createState() => _TeacherJournalScreenState();
}

class _TeacherJournalScreenState extends State<TeacherJournalScreen> {
  late final GradeService _gradeService;
  final _attendanceService = AttendanceService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Lesson> _lessons = [];
  List<Student> _students = [];
  Map<String, Grade> _gradeMap = {};
  Map<String, LessonAttendance> _attendanceMap = {};
  Map<String, DateTime?> _lessonDateMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gradeService = GradeService(db: Provider.of<AppDatabase>(context, listen: false));
      widget.onReady?.call(_loadJournal);
      _loadJournal();
    });
  }

  Future<void> _loadJournal() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _gradeService.getJournalData(groupId: widget.groupId, subjectId: widget.subjectId);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage;
      });
      return;
    }

    final data = result.data;
    final lessons = (data['lessons'] as List<Lesson>).where((l) => l.id != null).toList();
    final students = data['students'] as List<Student>;
    final grades = data['grades'] as List<Grade>;
    final attendances = data['attendances'] as List<LessonAttendance>;
    final schedules = data['schedules'] as List<Map<String, dynamic>>;
    final scheduleMap = {for (final s in schedules) s['id'].toString(): s};
    final lessonDateMap = <String, DateTime?>{};
    for (final lesson in lessons) {
      final sched = scheduleMap[lesson.scheduleId];
      final rawDate = sched?['date'];
      lessonDateMap[lesson.id!] = rawDate != null ? DateTime.tryParse(rawDate.toString()) : null;
    }
    lessons.sort((a, b) {
      final da = lessonDateMap[a.id];
      final db = lessonDateMap[b.id];
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    setState(() {
      _lessons = lessons;
      _students = students;
      _gradeMap = {for (final g in grades) '${g.studentId}|${g.lessonId}': g};
      _attendanceMap = {for (final a in attendances) '${a.studentId}|${a.lessonId}': a};
      _lessonDateMap = lessonDateMap;
      _isLoading = false;
    });
  }

  Future<void> _onCellTap(Student student, Lesson lesson) async {
    final key = '${student.id}|${lesson.id!}';
    final result = await showModalBottomSheet<Object?>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder:
          (_) => _CellEditSheet(
            studentName: '${student.surname} ${student.name}',
            dateLabel: _fmtDate(_lessonDateMap[lesson.id]),
            currentGrade: _gradeMap[key],
            currentAttendance: _attendanceMap[key],
          ),
    );
    if (result == null || !mounted) return;
    if (result is int) {
      final grade = Grade(lessonId: lesson.id!, studentId: student.id, value: result);
      final res = await _gradeService.addOrUpdateGrade(grade);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      setState(() {
        _gradeMap[key] = grade;
        _attendanceMap.remove(key);
      });
      MessengerHelper.showSuccess('Оценка $result сохранена');
    } else if (result == 'н') {
      final attendance = LessonAttendance(lessonId: lesson.id!, studentId: student.id, status: 'absent');
      final res = await _attendanceService.addOrUpdateAttendance(attendance);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      setState(() {
        _attendanceMap[key] = attendance;
        _gradeMap.remove(key);
      });
      MessengerHelper.showSuccess('Отметка «Н» сохранена');
    } else if (result == 'clear') {
      final res = await _gradeService.clearJournalCell(studentId: student.id, lessonId: lesson.id!);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      setState(() {
        _gradeMap.remove(key);
        _attendanceMap.remove(key);
      });
      MessengerHelper.showSuccess('Ячейка очищена');
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '?';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
      child:
          _isLoading
              ? _buildSkeleton()
              : _errorMessage != null
              ? _buildError(colors)
              : (_lessons.isEmpty || _students.isEmpty)
              ? _buildEmpty(colors)
              : _buildJournal(colors),
    );
  }

  Widget _buildJournal(ColorScheme colors) {
    return SingleChildScrollView(
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildGrid(colors)),
    );
  }

  Widget _buildGrid(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(colors),
        const Divider(height: 1, thickness: 1),
        for (var i = 0; i < _students.length; i++) _buildStudentRow(_students[i], i.isEven, colors),
      ],
    );
  }

  Widget _buildHeaderRow(ColorScheme colors) {
    return Container(
      height: _headerHeight,
      color: colors.primaryContainer,
      child: Row(children: [_headerNameCell(colors), for (final lesson in _lessons) _headerDateCell(lesson, colors)]),
    );
  }

  Widget _headerNameCell(ColorScheme colors) {
    return Container(
      width: _nameColWidth,
      height: _headerHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        'Студент',
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer, fontSize: 12),
      ),
    );
  }

  Widget _headerDateCell(Lesson lesson, ColorScheme colors) {
    return Container(
      width: _cellWidth,
      height: _headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Text(
        _fmtDate(_lessonDateMap[lesson.id]),
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer, fontSize: 12),
      ),
    );
  }

  Widget _buildStudentRow(Student student, bool isEven, ColorScheme colors) {
    return Container(
      height: _cellHeight,
      color: isEven ? colors.surface : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Row(
        children: [
          SizedBox(
            width: _nameColWidth,
            height: _cellHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${student.surname} ${student.name}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
                ),
              ),
            ),
          ),
          for (final lesson in _lessons) _buildDataCell(student, lesson, colors),
        ],
      ),
    );
  }

  Widget _buildDataCell(Student student, Lesson lesson, ColorScheme colors) {
    final key = '${student.id}|${lesson.id!}';
    final grade = _gradeMap[key];
    final attendance = _attendanceMap[key];
    return GestureDetector(
      onTap: () => _onCellTap(student, lesson),
      child: Container(
        width: _cellWidth,
        height: _cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.2), width: 0.5)),
        ),
        child: _cellContent(grade, attendance, colors),
      ),
    );
  }

  Widget _cellContent(Grade? grade, LessonAttendance? attendance, ColorScheme colors) {
    if (grade != null) {
      return Text(
        '${grade.value}',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _gradeColor(grade.value, colors)),
      );
    }
    if (attendance != null) {
      return Text('Н', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.error));
    }
    return Icon(Icons.add, size: 16, color: colors.outline.withValues(alpha: 0.4));
  }

  Widget _buildSkeleton() {
    const cols = 6;
    const rows = 8;
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Skeleton(height: _headerHeight, width: _nameColWidth, borderRadius: 8),
                  for (var i = 0; i < cols; i++)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Skeleton(height: _headerHeight, width: _cellWidth, borderRadius: 8),
                    ),
                ],
              ),
              for (var r = 0; r < rows; r++)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Skeleton(height: _cellHeight, width: _nameColWidth, borderRadius: 8),
                      for (var i = 0; i < cols; i++)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Skeleton(height: _cellHeight, width: _cellWidth, borderRadius: 8),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(color: colors.error, fontSize: 15)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: _loadJournal, icon: const Icon(Icons.refresh), label: const Text('Повторить')),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined, size: 64, color: colors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Данных пока нет',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Нет уроков или студентов для выбранной группы',
            style: TextStyle(color: colors.outlineVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CellEditSheet extends StatelessWidget {
  final String studentName;
  final String dateLabel;
  final Grade? currentGrade;
  final LessonAttendance? currentAttendance;

  const _CellEditSheet({required this.studentName, required this.dateLabel, this.currentGrade, this.currentAttendance});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasData = currentGrade != null || currentAttendance != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              studentName,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(dateLabel, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final g in [2, 3, 4, 5])
                  _OptionButton(
                    label: '$g',
                    color: _gradeColor(g, colors),
                    isSelected: currentGrade?.value == g,
                    onTap: () => Navigator.of(context).pop(g),
                  ),
                _OptionButton(
                  label: 'Н',
                  color: colors.error,
                  isSelected: currentAttendance != null && currentGrade == null,
                  onTap: () => Navigator.of(context).pop('н'),
                ),
              ],
            ),
            if (hasData) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop('clear'),
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Очистить'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({required this.label, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: isSelected ? 0 : 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color),
        ),
      ),
    );
  }
}
