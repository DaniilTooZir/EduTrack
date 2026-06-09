import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/services/final_grade_service.dart';
import 'package:edu_track/data/services/grade_comment_service.dart';
import 'package:edu_track/data/services/lesson_attendance_service.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/final_grade.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_bottom_sheet.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/date_utils.dart';
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
const double _paginationBarHeight = 44.0;

const _monthNames = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
];

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
  late GradeRepository _gradeService;
  final _attendanceService = AttendanceService();
  final _commentService = GradeCommentService();
  final _finalGradeService = FinalGradeService();
  final _lessonService = LessonService();

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
  Map<String, String> _commentMap = {};
  AcademicPeriod? _loadedPeriod;

  final _leftScrollCtrl = ScrollController();
  final _rightScrollCtrl = ScrollController();
  bool _scrollSyncing = false;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _leftScrollCtrl.addListener(_syncLeftToRight);
    _rightScrollCtrl.addListener(_syncRightToLeft);
  }

  void _syncLeftToRight() {
    if (_scrollSyncing || !_rightScrollCtrl.hasClients) return;
    _scrollSyncing = true;
    _rightScrollCtrl.jumpTo(_leftScrollCtrl.offset);
    _scrollSyncing = false;
  }

  void _syncRightToLeft() {
    if (_scrollSyncing || !_leftScrollCtrl.hasClients) return;
    _scrollSyncing = true;
    _leftScrollCtrl.jumpTo(_rightScrollCtrl.offset);
    _scrollSyncing = false;
  }

  @override
  void dispose() {
    _leftScrollCtrl.dispose();
    _rightScrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_gradeServiceReady) {
      _gradeService = Provider.of<GradeRepository>(context, listen: false);
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
      final exportLessons = _visibleLessons.where((l) => l.id != null).toList();
      final pages = _pages;
      String? pageLabel;
      if (pages.length > 1 && _pageIndex < pages.length) {
        final start = pages[_pageIndex].$1;
        pageLabel = '${_monthNames[start.month - 1]} ${start.year}';
      }
      await JournalPdfExporter.share(
        students: _students,
        lessons: exportLessons,
        gradeMap: _gradeMap,
        attendanceMap: _attendanceMap,
        lessonDateMap: _lessonDateMap,
        finalGradeMap: _finalGradeMap,
        period: _loadedPeriod,
        pageLabel: pageLabel,
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

    final existingScheduleIds = lessons.map((l) => l.scheduleId).toSet();
    final pendingLessons = <Lesson>[];
    for (final sched in schedules) {
      final schedId = sched['id'].toString();
      if (existingScheduleIds.contains(schedId)) continue;
      final rawDate = sched['date'];
      if (rawDate == null) continue;
      final date = DateTime.tryParse(rawDate.toString());
      if (date == null) continue;
      pendingLessons.add(Lesson(scheduleId: schedId, attendanceStatus: 'pending'));
      lessonDateMap[schedId] = date;
    }

    final allLessons = [...lessons, ...pendingLessons];
    allLessons.sort((a, b) {
      final da = lessonDateMap[a.id ?? a.scheduleId];
      final db = lessonDateMap[b.id ?? b.scheduleId];
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

    final gradeIds = grades.where((g) => g.id != null).map((g) => g.id!).toList();
    final commentResult = await _commentService.getCommentsByGradeIds(gradeIds);
    final commentMap = commentResult.isSuccess ? commentResult.data : <String, String>{};
    if (!mounted) return;

    setState(() {
      _lessons = allLessons;
      _students = students;
      _gradeMap = {for (final g in grades) '${g.studentId}|${g.lessonId}': g};
      _attendanceMap = {for (final a in attendances) '${a.studentId}|${a.lessonId}': a};
      _lessonDateMap = lessonDateMap;
      _finalGradeMap = finalGradeMap;
      _commentMap = commentMap;
      _isLoading = false;

      final pageCount = _pages.length;
      _pageIndex = pageCount > 0 ? pageCount - 1 : 0;
    });
  }

  Future<Lesson?> _ensureLessonCreated(Lesson lesson) async {
    if (lesson.id != null) return lesson;
    final result = await _lessonService.addLesson(lesson);
    if (!mounted) return null;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return null;
    }
    final realLesson = lesson.copyWith(id: result.data);
    setState(() {
      final idx = _lessons.indexWhere((l) => l.scheduleId == lesson.scheduleId && l.id == null);
      if (idx >= 0) _lessons[idx] = realLesson;
      final date = _lessonDateMap[lesson.scheduleId];
      if (date != null) _lessonDateMap[realLesson.id!] = date;
    });
    return realLesson;
  }

  Future<void> _onHeaderTap(Lesson lesson) async {
    if (!mounted) return;
    final result = await showAppBottomSheet<String?>(
      context,
      builder: (_) => _LessonTopicSheet(dateLabel: _fmtDate(_lessonDateMap[lesson.id]), currentTopic: lesson.topic),
    );
    if (result == null || !mounted) return;
    final newTopic = result.trim().isEmpty ? null : result.trim();
    final res = await _lessonService.updateLessonTopic(lesson.id!, newTopic);
    if (!mounted) return;
    if (res.isFailure) {
      MessengerHelper.showError(res.errorMessage);
      return;
    }
    setState(() {
      final idx = _lessons.indexWhere((l) => l.id == lesson.id);
      if (idx >= 0) _lessons[idx] = _lessons[idx].copyWith(topic: newTopic);
    });
    MessengerHelper.showSuccess(newTopic == null ? 'Тема удалена' : 'Тема урока сохранена');
  }

  Future<void> _onCellTap(Student student, Lesson lesson) async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId ?? '';
    final resolvedLesson = await _ensureLessonCreated(lesson);
    if (resolvedLesson == null || !mounted) return;

    final key = '${student.id}|${resolvedLesson.id!}';
    final result = await showAppBottomSheet<Object?>(
      context,
      builder:
          (_) => _CellEditSheet(
            studentName: '${student.surname} ${student.name}',
            dateLabel: _fmtDate(_lessonDateMap[resolvedLesson.id]),
            currentGrade: _gradeMap[key],
            currentAttendance: _attendanceMap[key],
            currentComment: _commentMap[_gradeMap[key]?.id ?? ''],
          ),
    );
    if (result == null || !mounted) return;
    if (result is Map<String, dynamic>) {
      final gradeValue = result['value'] as int;
      final comment = (result['comment'] as String? ?? '').trim();
      final grade = Grade(lessonId: resolvedLesson.id!, studentId: student.id, value: gradeValue);
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
        if (comment.isNotEmpty) {
          _commentMap[gradeId] = comment;
        } else {
          _commentMap.remove(gradeId);
        }
      });
      MessengerHelper.showSuccess('Оценка $gradeValue сохранена');
    } else if (result == 'н') {
      final attendance = LessonAttendance(lessonId: resolvedLesson.id!, studentId: student.id, status: 'absent');
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
      final res = await _gradeService.clearJournalCell(studentId: student.id, lessonId: resolvedLesson.id!);
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
        if (existingGradeId != null) _commentMap.remove(existingGradeId);
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

    final result = await showAppBottomSheet<Object?>(
      context,
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
    return formatShortDate(d);
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
              ? AppErrorView(message: _errorMessage!, onRetry: _loadJournal)
              : (_lessons.isEmpty || _students.isEmpty)
              ? _buildEmpty(colors)
              : _buildJournal(colors),
          if (_isExporting)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: colors.primary),
                        const SizedBox(height: AppSpacing.l),
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
    final grades =
        _lessons.where((l) => l.id != null).map((l) => _gradeMap['${student.id}|${l.id!}']).whereType<Grade>().toList();
    if (grades.isEmpty) return 0;
    return grades.map((g) => g.value).reduce((a, b) => a + b) / grades.length;
  }

  bool get _showFinalColumn => _loadedPeriod != null;

  List<(DateTime, DateTime)> get _pages {
    final months = <DateTime>{};
    for (final lesson in _lessons) {
      final date = _lessonDateMap[lesson.id ?? lesson.scheduleId];
      if (date != null) months.add(DateTime(date.year, date.month));
    }
    if (months.isEmpty) return [];
    final sorted = months.toList()..sort();
    return sorted.map((m) => (m, DateTime(m.year, m.month + 1, 0))).toList();
  }

  List<Lesson> get _visibleLessons {
    final pages = _pages;
    if (pages.length <= 1) return _lessons;
    if (_pageIndex >= pages.length) return _lessons;
    final (start, _) = pages[_pageIndex];
    return _lessons.where((l) {
      final date = _lessonDateMap[l.id ?? l.scheduleId];
      return date != null && date.year == start.year && date.month == start.month;
    }).toList();
  }

  Widget _buildPaginationBar(ColorScheme colors) {
    final pages = _pages;
    if (pages.length <= 1) return const SizedBox.shrink();
    final (start, _) = pages[_pageIndex];
    final label = '${_monthNames[start.month - 1]} ${start.year}';
    return Container(
      height: _paginationBarHeight,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            iconSize: 20,
            onPressed: _pageIndex > 0 ? () => setState(() => _pageIndex--) : null,
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.onSurface),
            ),
          ),
          Text('${_pageIndex + 1} / ${pages.length}', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            iconSize: 20,
            onPressed: _pageIndex < pages.length - 1 ? () => setState(() => _pageIndex++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildJournal(ColorScheme colors) {
    return Column(
      children: [
        _buildPaginationBar(colors),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _nameColWidth,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: colors.shadow.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(3, 0)),
                  ],
                ),
                child: Column(
                  children: [
                    _headerNameCell(colors),
                    Divider(height: 1, thickness: 1, color: colors.outline.withValues(alpha: 0.5)),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _leftScrollCtrl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < _students.length; i++) _buildNameCell(_students[i], i.isEven, colors),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable data area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bodyHeight = constraints.maxHeight - _headerHeight - 1;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDataHeaderRow(colors),
                          Divider(height: 1, thickness: 1, color: colors.outline.withValues(alpha: 0.5)),
                          SizedBox(
                            height: bodyHeight,
                            child: SingleChildScrollView(
                              controller: _rightScrollCtrl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < _students.length; i++)
                                    _buildDataRowWithoutName(_students[i], i.isEven, colors),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameCell(Student student, bool isEven, ColorScheme colors) {
    return Container(
      width: _nameColWidth,
      height: _cellHeight,
      color: isEven ? colors.surface : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        '${student.surname} ${student.name}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.onSurface),
      ),
    );
  }

  Widget _buildDataHeaderRow(ColorScheme colors) {
    return Container(
      height: _headerHeight,
      color: colors.primaryContainer,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lesson in _visibleLessons) _headerDateCell(lesson, colors),
          _headerAvgCell(colors),
          if (_showFinalColumn) _headerFinalCell(colors),
        ],
      ),
    );
  }

  Widget _buildDataRowWithoutName(Student student, bool isEven, ColorScheme colors) {
    return Container(
      height: _cellHeight,
      color: isEven ? colors.surface : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lesson in _visibleLessons) _buildDataCell(student, lesson, colors),
          _buildAvgCell(student, colors),
          if (_showFinalColumn) _buildFinalGradeCell(student, colors),
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
    final isPending = lesson.id == null;
    final dateKey = lesson.id ?? lesson.scheduleId;
    final hasTopic = !isPending && (lesson.topic?.isNotEmpty ?? false);
    final cell = Container(
      width: _cellWidth,
      height: _headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _fmtDate(_lessonDateMap[dateKey]),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPending ? colors.onPrimaryContainer.withValues(alpha: 0.4) : colors.onPrimaryContainer,
              fontSize: 12,
            ),
          ),
          if (hasTopic)
            Text(
              lesson.topic!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: colors.onPrimaryContainer.withValues(alpha: 0.6)),
            ),
        ],
      ),
    );
    if (isPending) return cell;
    Widget result = GestureDetector(onTap: () => _onHeaderTap(lesson), child: cell);
    if (hasTopic) {
      result = Tooltip(
        message: lesson.topic!,
        preferBelow: true,
        triggerMode: TooltipTriggerMode.longPress,
        child: result,
      );
    }
    return result;
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
    return GestureDetector(
      onTap: () => _onCellTap(student, lesson),
      child: Container(
        width: _cellWidth,
        height: _cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.outline.withValues(alpha: 0.2), width: 0.5)),
        ),
        child:
            lesson.id == null
                ? Icon(Icons.add, size: 16, color: colors.outline.withValues(alpha: 0.25))
                : _cellContent(
                  _gradeMap['${student.id}|${lesson.id!}'],
                  _attendanceMap['${student.id}|${lesson.id!}'],
                  colors,
                ),
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

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined, size: 64, color: colors.outlineVariant),
          const SizedBox(height: AppSpacing.l),
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
  final String? currentComment;

  const _CellEditSheet({
    required this.studentName,
    required this.dateLabel,
    this.currentGrade,
    this.currentAttendance,
    this.currentComment,
  });

  @override
  State<_CellEditSheet> createState() => _CellEditSheetState();
}

class _CellEditSheetState extends State<_CellEditSheet> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.currentComment ?? '');
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
                prefixIcon: const Icon(Icons.comment_outlined, size: 20),
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
              const SizedBox(height: AppSpacing.m),
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
            const SizedBox(height: AppSpacing.l),
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
              const SizedBox(height: AppSpacing.l),
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

class _LessonTopicSheet extends StatefulWidget {
  final String dateLabel;
  final String? currentTopic;

  const _LessonTopicSheet({required this.dateLabel, this.currentTopic});

  @override
  State<_LessonTopicSheet> createState() => _LessonTopicSheetState();
}

class _LessonTopicSheetState extends State<_LessonTopicSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTopic ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            Text('Тема урока', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(height: 4),
            Text(widget.dateLabel, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Введите тему урока',
                suffixIcon: ListenableBuilder(
                  listenable: _controller,
                  builder:
                      (_, __) =>
                          _controller.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: _controller.clear)
                              : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_controller.text),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Сохранить'),
              ),
            ),
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
              borderRadius: AppRadius.card,
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
