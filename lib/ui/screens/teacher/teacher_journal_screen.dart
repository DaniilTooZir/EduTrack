import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/final_grade_service.dart';
import 'package:edu_track/data/services/grade_comment_service.dart';
import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/data/services/lesson_attendance_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/final_grade.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/journal_pdf_exporter.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double _nameColWidth = 160.0;
const double _cellWidth = 56.0;
const double _cellHeight = 48.0;
const double _headerHeight = 48.0;
const double _avgColWidth = 64.0;
const double _finalColWidth = 64.0;

Color _gradeColor(int value, ColorScheme colors) => switch (value) {
  5 => const Color(0xFF2E7D32),
  4 => const Color(0xFF558B2F),
  3 => const Color(0xFFE65100),
  _ => colors.error,
};

Color _avgColor(double avg, ColorScheme colors) {
  if (avg == 0) return colors.outline;
  if (avg >= 4.5) return const Color(0xFF2E7D32);
  if (avg >= 3.5) return const Color(0xFF558B2F);
  if (avg >= 2.5) return const Color(0xFFE65100);
  return colors.error;
}

class TeacherJournalScreen extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final String? subjectName;
  final String? groupName;
  final void Function(VoidCallback loadJournal)? onReady;
  final void Function(VoidCallback exportFn)? onExportReady;

  const TeacherJournalScreen({
    super.key,
    required this.groupId,
    required this.subjectId,
    this.subjectName,
    this.groupName,
    this.onReady,
    this.onExportReady,
  });

  @override
  State<TeacherJournalScreen> createState() => _TeacherJournalScreenState();
}

class _TeacherJournalScreenState extends State<TeacherJournalScreen> {
  late GradeService _gradeService;
  final _attendanceService = AttendanceService();
  final _commentService = GradeCommentService();
  final _finalGradeService = FinalGradeService();

  bool _isLoading = true;
  bool _isExporting = false;
  bool _gradeServiceReady = false;
  String? _errorMessage;
  List<Lesson> _lessons = [];
  List<Student> _students = [];
  Map<String, Grade> _gradeMap = {};
  Map<String, LessonAttendance> _attendanceMap = {};
  Map<String, DateTime?> _lessonDateMap = {};
  Map<String, FinalGrade> _finalGradeMap = {};
  AcademicPeriod? _loadedPeriod;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_gradeServiceReady) {
      _gradeService = GradeService(db: Provider.of<AppDatabase>(context, listen: false));
      _gradeServiceReady = true;
      widget.onReady?.call(_loadJournal);
      widget.onExportReady?.call(_triggerExport);
    }
    final period = Provider.of<UserProvider>(context).selectedPeriod;
    if (period != _loadedPeriod) {
      _loadedPeriod = period;
      _loadJournal();
    }
  }

  void _triggerExport() {
    if (_isExporting || _isLoading || _lessons.isEmpty) return;
    _doExport();
  }

  Future<void> _doExport() async {
    setState(() => _isExporting = true);
    try {
      await JournalPdfExporter.share(
        students: _students,
        lessons: _lessons,
        gradeMap: _gradeMap,
        attendanceMap: _attendanceMap,
        lessonDateMap: _lessonDateMap,
        finalGradeMap: _finalGradeMap,
        period: _loadedPeriod,
        subjectName: widget.subjectName ?? widget.subjectId,
        groupName: widget.groupName ?? widget.groupId,
      );
    } catch (_) {
      if (mounted) MessengerHelper.showError('Не удалось создать PDF');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _loadJournal() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;

    final journalFuture = _gradeService.getJournalData(
      groupId: widget.groupId,
      subjectId: widget.subjectId,
      startDate: period?.startDate,
      endDate: period?.endDate,
    );
    final finalGradeFuture =
        period != null
            ? _finalGradeService.getFinalGrades(
              groupId: widget.groupId,
              subjectId: widget.subjectId,
              periodId: period.id,
            )
            : Future.value(AppResult<List<FinalGrade>>.success([]));

    final (result, finalResult) = await (journalFuture, finalGradeFuture).wait;
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

    final finalGradeMap = <String, FinalGrade>{};
    if (finalResult.isSuccess) {
      for (final fg in finalResult.data) {
        finalGradeMap[fg.studentId] = fg;
      }
    }

    setState(() {
      _lessons = lessons;
      _students = students;
      _gradeMap = {for (final g in grades) '${g.studentId}|${g.lessonId}': g};
      _attendanceMap = {for (final a in attendances) '${a.studentId}|${a.lessonId}': a};
      _lessonDateMap = lessonDateMap;
      _finalGradeMap = finalGradeMap;
      _isLoading = false;
    });
  }

  Future<void> _onCellTap(Student student, Lesson lesson) async {
    final key = '${student.id}|${lesson.id!}';
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
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
    if (result is Map<String, dynamic>) {
      final gradeValue = result['value'] as int;
      final comment = (result['comment'] as String? ?? '').trim();
      final grade = Grade(lessonId: lesson.id!, studentId: student.id, value: gradeValue);
      final res = await _gradeService.addOrUpdateGrade(grade);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      final gradeId = res.data;
      if (comment.isNotEmpty) {
        await _commentService.saveOrUpdate(gradeId: gradeId, teacherId: teacherId, message: comment);
      } else {
        await _commentService.delete(gradeId);
      }
      if (!mounted) return;
      setState(() {
        _gradeMap[key] = grade.copyWith(id: gradeId);
        _attendanceMap.remove(key);
      });
      MessengerHelper.showSuccess('Оценка $gradeValue сохранена');
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
      final existingGradeId = _gradeMap[key]?.id;
      final res = await _gradeService.clearJournalCell(studentId: student.id, lessonId: lesson.id!);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      if (existingGradeId != null) {
        await _commentService.delete(existingGradeId);
      }
      if (!mounted) return;
      setState(() {
        _gradeMap.remove(key);
        _attendanceMap.remove(key);
      });
      MessengerHelper.showSuccess('Ячейка очищена');
    }
  }

  Future<void> _onFinalCellTap(Student student) async {
    final period = _loadedPeriod;
    if (period == null) return;
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    final avg = _computeAvg(student);
    final currentFinalGrade = _finalGradeMap[student.id];

    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder:
          (_) => _FinalGradeSheet(
            studentName: '${student.surname} ${student.name}',
            computedAvg: avg,
            currentFinalGrade: currentFinalGrade,
          ),
    );
    if (result == null || !mounted) return;
    if (result is int) {
      final finalGrade = FinalGrade(
        id: currentFinalGrade?.id,
        studentId: student.id,
        subjectId: widget.subjectId,
        groupId: widget.groupId,
        periodId: period.id,
        value: result,
        isManual: true,
        teacherId: teacherId,
      );
      final res = await _finalGradeService.setFinalGrade(finalGrade);
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      setState(() => _finalGradeMap[student.id] = finalGrade.copyWith(id: res.data));
      MessengerHelper.showSuccess('Итоговая оценка $result сохранена');
    } else if (result == 'clear') {
      final res = await _finalGradeService.clearFinalGrade(
        studentId: student.id,
        subjectId: widget.subjectId,
        periodId: period.id,
      );
      if (!mounted) return;
      if (res.isFailure) {
        MessengerHelper.showError(res.errorMessage);
        return;
      }
      setState(() => _finalGradeMap.remove(student.id));
      MessengerHelper.showSuccess('Итоговая оценка удалена');
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
      child: Stack(
        children: [
          _isLoading
              ? _buildSkeleton()
              : _errorMessage != null
              ? _buildError(colors)
              : (_lessons.isEmpty || _students.isEmpty)
              ? _buildEmpty(colors)
              : _buildJournal(colors),
          if (_isExporting)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primary),
                        const SizedBox(height: 16),
                        Text('Создание PDF...', style: TextStyle(color: colors.onSurface, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _computeAvg(Student student) {
    final grades = _lessons.map((l) => _gradeMap['${student.id}|${l.id!}']).whereType<Grade>().toList();
    if (grades.isEmpty) return 0;
    return grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;
  }

  bool get _showFinalColumn => _loadedPeriod != null;

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
      child: Row(
        children: [
          _headerNameCell(colors),
          for (final lesson in _lessons) _headerDateCell(lesson, colors),
          _headerAvgCell(colors),
          if (_showFinalColumn) _headerFinalCell(colors),
        ],
      ),
    );
  }

  Widget _headerAvgCell(ColorScheme colors) {
    return Container(
      width: _avgColWidth,
      height: _headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.5)))),
      child: Text('Ср.', style: TextStyle(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer, fontSize: 12)),
    );
  }

  Widget _headerFinalCell(ColorScheme colors) {
    return Container(
      width: _finalColWidth,
      height: _headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.5))),
        color: colors.primary.withValues(alpha: 0.12),
      ),
      child: Text('Итог', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 12)),
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
          _buildAvgCell(student, colors),
          if (_showFinalColumn) _buildFinalGradeCell(student, colors),
        ],
      ),
    );
  }

  Widget _buildAvgCell(Student student, ColorScheme colors) {
    final avg = _computeAvg(student);
    final color = _avgColor(avg, colors);
    return Container(
      width: _avgColWidth,
      height: _cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.5)))),
      child:
          avg == 0
              ? Icon(Icons.remove, size: 16, color: colors.outline.withValues(alpha: 0.4))
              : Text(avg.toStringAsFixed(1), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildFinalGradeCell(Student student, ColorScheme colors) {
    final finalGrade = _finalGradeMap[student.id];
    final avg = _computeAvg(student);
    final suggested = avg == 0 ? null : avg.round().clamp(2, 5);

    return GestureDetector(
      onTap: () => _onFinalCellTap(student),
      child: Container(
        width: _finalColWidth,
        height: _cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.primary.withValues(alpha: 0.3))),
          color: colors.primary.withValues(alpha: 0.06),
        ),
        child:
            finalGrade != null
                ? Text(
                  '${finalGrade.value}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _gradeColor(finalGrade.value, colors),
                  ),
                )
                : suggested != null
                ? Text(
                  '~$suggested',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _gradeColor(suggested, colors).withValues(alpha: 0.45),
                  ),
                )
                : Icon(Icons.add, size: 16, color: colors.primary.withValues(alpha: 0.3)),
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
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Skeleton(height: _headerHeight, width: _avgColWidth, borderRadius: 8),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Skeleton(height: _cellHeight, width: _avgColWidth, borderRadius: 8),
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

class _CellEditSheet extends StatefulWidget {
  final String studentName;
  final String dateLabel;
  final Grade? currentGrade;
  final LessonAttendance? currentAttendance;

  const _CellEditSheet({required this.studentName, required this.dateLabel, this.currentGrade, this.currentAttendance});

  @override
  State<_CellEditSheet> createState() => _CellEditSheetState();
}

class _CellEditSheetState extends State<_CellEditSheet> {
  final _commentController = TextEditingController();
  final _commentService = GradeCommentService();
  bool _loadingComment = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentGrade?.id != null) _loadComment();
  }

  Future<void> _loadComment() async {
    setState(() => _loadingComment = true);
    final result = await _commentService.getComment(widget.currentGrade!.id!);
    if (mounted && result.isSuccess && result.data != null) {
      _commentController.text = result.data!;
    }
    if (mounted) setState(() => _loadingComment = false);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasData = widget.currentGrade != null || widget.currentAttendance != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
              widget.studentName,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(widget.dateLabel, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final g in [2, 3, 4, 5])
                  _OptionButton(
                    label: '$g',
                    color: _gradeColor(g, colors),
                    isSelected: widget.currentGrade?.value == g,
                    onTap: () => Navigator.of(context).pop({'value': g, 'comment': _commentController.text.trim()}),
                  ),
                _OptionButton(
                  label: 'Н',
                  color: colors.error,
                  isSelected: widget.currentAttendance != null && widget.currentGrade == null,
                  onTap: () => Navigator.of(context).pop('н'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Комментарий к оценке (необязательно)',
                prefixIcon:
                    _loadingComment
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                        : const Icon(Icons.comment_outlined, size: 20),
                suffixIcon: ListenableBuilder(
                  listenable: _commentController,
                  builder:
                      (_, __) =>
                          _commentController.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: _commentController.clear)
                              : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            if (hasData) ...[
              const SizedBox(height: 12),
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

class _FinalGradeSheet extends StatelessWidget {
  final String studentName;
  final double computedAvg;
  final FinalGrade? currentFinalGrade;

  const _FinalGradeSheet({required this.studentName, required this.computedAvg, this.currentFinalGrade});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final suggested = computedAvg == 0 ? null : computedAvg.round().clamp(2, 5);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
            Text('Итоговая оценка за период', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 16),
            if (computedAvg > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate_outlined, size: 16, color: colors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Средний балл: ${computedAvg.toStringAsFixed(2)}',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    ),
                    if (suggested != null) ...[
                      const SizedBox(width: 6),
                      Text('→', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'рекомендуется $suggested',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _gradeColor(suggested, colors),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final g in [2, 3, 4, 5])
                  _OptionButton(
                    label: '$g',
                    color: _gradeColor(g, colors),
                    isSelected: currentFinalGrade?.value == g,
                    hasSuggestion: suggested == g && currentFinalGrade == null,
                    onTap: () => Navigator.of(context).pop(g),
                  ),
              ],
            ),
            if (currentFinalGrade != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop('clear'),
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Удалить итоговую оценку'),
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
  final bool hasSuggestion;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.hasSuggestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
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
          if (hasSuggestion)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
