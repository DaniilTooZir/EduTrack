import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/services/final_grade_service.dart';
import 'package:edu_track/data/services/grade_comment_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/final_grade.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _AnalyticsSort { gradeAsc, gradeDesc, nameAsc }

class StudentAnalyticsScreen extends StatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  State<StudentAnalyticsScreen> createState() => _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState extends State<StudentAnalyticsScreen> {
  late final GradeRepository _gradeService;
  final _commentService = GradeCommentService();
  final _finalGradeService = FinalGradeService();

  bool _isLoading = true;
  bool _initialized = false;
  String? _error;
  List<SubjectAnalytics> _analytics = [];
  Map<String, String> _commentMap = {};
  Map<String, FinalGrade> _finalGradeMap = {};
  AcademicPeriod? _loadedPeriod;
  _AnalyticsSort _sortOrder = _AnalyticsSort.gradeAsc;

  List<SubjectAnalytics> get _sortedAnalytics {
    final list = List<SubjectAnalytics>.from(_analytics);
    switch (_sortOrder) {
      case _AnalyticsSort.gradeAsc:
        list.sort((a, b) => a.averageGrade.compareTo(b.averageGrade));
      case _AnalyticsSort.gradeDesc:
        list.sort((a, b) => b.averageGrade.compareTo(a.averageGrade));
      case _AnalyticsSort.nameAsc:
        list.sort((a, b) => a.subject.name.compareTo(b.subject.name));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _gradeService = Provider.of<GradeRepository>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final period = Provider.of<UserProvider>(context).selectedPeriod;
    if (!_initialized || period != _loadedPeriod) {
      _initialized = true;
      _loadedPeriod = period;
      _load();
    }
  }

  Future<void> _load() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    final provider = Provider.of<UserProvider>(context, listen: false);
    final studentId = provider.userId;
    final period = provider.selectedPeriod;
    if (studentId == null) {
      setState(() {
        _error = 'Не удалось получить ID студента';
        _isLoading = false;
      });
      return;
    }
    final analyticsFuture = _gradeService.getStudentAnalytics(
      studentId,
      startDate: period?.startDate,
      endDate: period?.endDate,
    );
    final Future<AppResult<List<FinalGrade>>?> finalGradeFuture =
        period != null
            ? _finalGradeService.getFinalGradesByStudent(studentId: studentId, periodId: period.id)
            : Future.value();

    final (result, finalResult) = await (analyticsFuture, finalGradeFuture).wait;
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.errorMessage;
        _isLoading = false;
      });
      return;
    }

    final analytics = result.data;
    final gradeIds = analytics.expand((a) => a.grades).map((g) => g.id).whereType<String>().toList();
    final commentsResult = await _commentService.getCommentsByGradeIds(gradeIds);
    if (!mounted) return;

    final finalGradeMap = <String, FinalGrade>{};
    if (finalResult != null && finalResult.isSuccess) {
      for (final fg in finalResult.data) {
        finalGradeMap[fg.subjectId] = fg;
      }
    }

    setState(() {
      _analytics = analytics;
      _commentMap = commentsResult.isSuccess ? commentsResult.data : {};
      _finalGradeMap = finalGradeMap;
      _isLoading = false;
      _error = null;
    });
  }

  double _overallGpa() {
    final allGrades = _analytics.expand((a) => a.grades).toList();
    return Grade.calculateGPA(allGrades);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: colors.error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }
    if (_analytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Оценок пока нет', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 18)),
          ],
        ),
      );
    }
    final gpa = _overallGpa();
    final gpaColor = _gradeColor(gpa);
    final sorted = _sortedAnalytics;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [Tab(text: 'Аналитика'), Tab(text: 'Журнал')],
            labelColor: colors.primary,
            indicatorColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    _buildGpaHeader(gpa, gpaColor, colors),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          Text('Сортировка:', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          SegmentedButton<_AnalyticsSort>(
                            segments: const [
                              ButtonSegment(
                                value: _AnalyticsSort.gradeAsc,
                                label: Text('Балл ↑'),
                                icon: Icon(Icons.arrow_upward, size: 14),
                              ),
                              ButtonSegment(
                                value: _AnalyticsSort.gradeDesc,
                                label: Text('Балл ↓'),
                                icon: Icon(Icons.arrow_downward, size: 14),
                              ),
                              ButtonSegment(
                                value: _AnalyticsSort.nameAsc,
                                label: Text('А–Я'),
                                icon: Icon(Icons.sort_by_alpha, size: 14),
                              ),
                            ],
                            selected: {_sortOrder},
                            onSelectionChanged: (s) => setState(() => _sortOrder = s.first),
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        color: colors.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: sorted.length,
                          itemBuilder:
                              (context, index) => _SubjectAnalyticsCard(
                                analytics: sorted[index],
                                finalGrade: _finalGradeMap[sorted[index].subject.id],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                RefreshIndicator(
                  onRefresh: _load,
                  color: colors.primary,
                  child: _buildJournalTab(sorted, colors, _commentMap),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalTab(List<SubjectAnalytics> subjects, ColorScheme colors, Map<String, String> commentMap) {
    final withGrades = subjects.where((s) => s.gradeSeries.isNotEmpty).toList();
    if (withGrades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('Нет оценок для отображения', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: withGrades.length,
      itemBuilder:
          (context, index) => _JournalSubjectTile(
            analytics: withGrades[index],
            commentMap: commentMap,
            finalGrade: _finalGradeMap[withGrades[index].subject.id],
          ),
    );
  }

  Widget _buildGpaHeader(double gpa, Color gpaColor, ColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gpaColor.withValues(alpha: 0.75), gpaColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: gpaColor.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Общий средний балл', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                gpa.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1),
              ),
              const SizedBox(height: 2),
              Text(
                'по ${_analytics.length} ${_subjectWord(_analytics.length)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.school_rounded, size: 56, color: Colors.white.withValues(alpha: 0.25)),
        ],
      ),
    );
  }

  String _subjectWord(int n) {
    if (n % 100 >= 11 && n % 100 <= 14) return 'предметам';
    switch (n % 10) {
      case 1:
        return 'предмету';
      case 2:
      case 3:
      case 4:
        return 'предметам';
      default:
        return 'предметам';
    }
  }
}

Color _gradeColor(double avg) {
  if (avg >= 4.5) return Colors.green;
  if (avg >= 3.5) return Colors.lightGreen;
  if (avg >= 2.5) return Colors.orange;
  return Colors.red;
}

Color _gradeColorInt(int value) => switch (value) {
  5 => const Color(0xFF2E7D32),
  4 => const Color(0xFF558B2F),
  3 => const Color(0xFFE65100),
  _ => Colors.red,
};

class _SubjectAnalyticsCard extends StatelessWidget {
  final SubjectAnalytics analytics;
  final FinalGrade? finalGrade;

  const _SubjectAnalyticsCard({required this.analytics, this.finalGrade});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avg = analytics.averageGrade;
    final progress = (avg / 5.0).clamp(0.0, 1.0);
    final barColor = _gradeColor(avg);
    final avgText = avg == 0.0 ? '—' : avg.toStringAsFixed(1);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: barColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(avgText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: barColor)),
          ),
        ),
        title: Text(
          analytics.subject.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Оценок: ${analytics.grades.length}',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                if (finalGrade != null) ...[const SizedBox(width: 8), _FinalGradeBadge(value: finalGrade!.value)],
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
        children: [
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: _GradeLineChart(analytics: analytics, barColor: barColor, colors: colors),
          ),
        ],
      ),
    );
  }
}

class _JournalSubjectTile extends StatelessWidget {
  final SubjectAnalytics analytics;
  final Map<String, String> commentMap;
  final FinalGrade? finalGrade;

  const _JournalSubjectTile({required this.analytics, required this.commentMap, this.finalGrade});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avg = analytics.averageGrade;
    final avgColor = _gradeColor(avg);
    final entries = [...analytics.gradeSeries]..sort((a, b) => b.date.compareTo(a.date));
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: avgColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              avg == 0.0 ? '—' : avg.toStringAsFixed(1),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: avgColor),
            ),
          ),
        ),
        title: Text(
          analytics.subject.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                '${entries.length} ${_gradeWord(entries.length)}',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              if (finalGrade != null) ...[const SizedBox(width: 8), _FinalGradeBadge(value: finalGrade!.value)],
            ],
          ),
        ),
        children: [
          Divider(height: 1, color: colors.outlineVariant),
          ...entries.asMap().entries.map((e) {
            final isLast = e.key == entries.length - 1;
            final comment = e.value.gradeId != null ? commentMap[e.value.gradeId] : null;
            return Column(
              children: [
                _JournalGradeRow(entry: e.value, colors: colors, comment: comment),
                if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: colors.outlineVariant),
              ],
            );
          }),
          if (finalGrade != null) ...[
            Divider(height: 1, color: colors.outlineVariant),
            _FinalGradeRow(finalGrade: finalGrade!, colors: colors),
          ],
        ],
      ),
    );
  }

  String _gradeWord(int n) {
    if (n % 100 >= 11 && n % 100 <= 14) return 'оценок';
    switch (n % 10) {
      case 1:
        return 'оценка';
      case 2:
      case 3:
      case 4:
        return 'оценки';
      default:
        return 'оценок';
    }
  }
}

class _FinalGradeRow extends StatelessWidget {
  final FinalGrade finalGrade;
  final ColorScheme colors;

  const _FinalGradeRow({required this.finalGrade, required this.colors});

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColorInt(finalGrade.value);
    const labels = {5: 'Отлично', 4: 'Хорошо', 3: 'Удовл.', 2: 'Неудовл.'};
    return Container(
      color: gradeColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${finalGrade.value}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Итоговая оценка за период',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
                const SizedBox(height: 2),
                Text('Выставлена преподавателем', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gradeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              labels[finalGrade.value] ?? '${finalGrade.value}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gradeColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalGradeBadge extends StatelessWidget {
  final int value;

  const _FinalGradeBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = _gradeColorInt(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 11, color: color),
          const SizedBox(width: 3),
          Text('Итог: $value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _GradeLineChart extends StatelessWidget {
  final SubjectAnalytics analytics;
  final Color barColor;
  final ColorScheme colors;

  const _GradeLineChart({required this.analytics, required this.barColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    final series = analytics.gradeSeries;
    if (series.length < 2) {
      return SizedBox(
        height: 72,
        child: Center(
          child: Text(
            series.isEmpty
                ? 'Нет данных о датах для построения графика'
                : 'Добавьте больше оценок для отображения динамики',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final spots = series.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble())).toList();
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 4),
        child: LineChart(
          LineChartData(
            minY: 1.5,
            maxY: 5.5,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: barColor,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter:
                      (spot, percent, bar, index) =>
                          FlDotCirclePainter(radius: 4, color: barColor, strokeWidth: 2, strokeColor: Colors.white),
                ),
                belowBarData: BarAreaData(color: barColor.withValues(alpha: 0.08)),
              ),
            ],
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= series.length) return const SizedBox.shrink();
                    if (series.length > 6 && idx % 2 != 0) return const SizedBox.shrink();
                    final date = series[idx].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${date.day}.${date.month.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final intVal = value.toInt();
                    if (value != intVal.toDouble() || intVal < 2 || intVal > 5) {
                      return const SizedBox.shrink();
                    }
                    return Text('$intVal', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant));
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine:
                  (value) => FlLine(color: colors.outline.withValues(alpha: 0.15), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}

class _JournalGradeRow extends StatelessWidget {
  final ({DateTime date, int value, String? gradeId}) entry;
  final ColorScheme colors;
  final String? comment;

  const _JournalGradeRow({required this.entry, required this.colors, this.comment});

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(entry.value.toDouble());
    final d = entry.date;
    final dateStr = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    const labels = {5: 'Отлично', 4: 'Хорошо', 3: 'Удовл.', 2: 'Неудовл.'};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${entry.value}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gradeColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: TextStyle(fontSize: 14, color: colors.onSurface)),
                if (comment != null && comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment!,
                    style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labels[entry.value] ?? '${entry.value}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gradeColor),
            ),
          ),
        ],
      ),
    );
  }
}
