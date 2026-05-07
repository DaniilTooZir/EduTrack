import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentAnalyticsScreen extends StatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  State<StudentAnalyticsScreen> createState() => _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState extends State<StudentAnalyticsScreen> {
  late final GradeService _gradeService;
  bool _isLoading = true;
  String? _error;
  List<SubjectAnalytics> _analytics = [];

  @override
  void initState() {
    super.initState();
    _gradeService = GradeService(db: Provider.of<AppDatabase>(context, listen: false));
    _load();
  }

  Future<void> _load() async {
    if (!_isLoading) setState(() { _isLoading = true; _error = null; });
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) {
      setState(() { _error = 'Не удалось получить ID студента'; _isLoading = false; });
      return;
    }
    final result = await _gradeService.getStudentAnalytics(studentId);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() { _error = result.errorMessage; _isLoading = false; });
    } else {
      setState(() { _analytics = result.data; _isLoading = false; });
    }
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

    return Column(
      children: [
        _buildGpaHeader(gpa, gpaColor, colors),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: colors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _analytics.length,
              itemBuilder: (context, index) => _SubjectAnalyticsCard(analytics: _analytics[index]),
            ),
          ),
        ),
      ],
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
        boxShadow: [
          BoxShadow(color: gpaColor.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Общий средний балл',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
              ),
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
      case 1: return 'предмету';
      case 2:
      case 3:
      case 4: return 'предметам';
      default: return 'предметам';
    }
  }
}

Color _gradeColor(double avg) {
  if (avg >= 4.5) return Colors.green;
  if (avg >= 3.5) return Colors.lightGreen;
  if (avg >= 2.5) return Colors.orange;
  return Colors.red;
}

class _SubjectAnalyticsCard extends StatelessWidget {
  final SubjectAnalytics analytics;

  const _SubjectAnalyticsCard({required this.analytics});

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
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              avgText,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: barColor),
            ),
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
            Text(
              'Оценок: ${analytics.grades.length}',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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

class _GradeLineChart extends StatelessWidget {
  final SubjectAnalytics analytics;
  final Color barColor;
  final ColorScheme colors;

  const _GradeLineChart({
    required this.analytics,
    required this.barColor,
    required this.colors,
  });

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

    final spots = series.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble()))
        .toList();

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
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 4,
                    color: barColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  color: barColor.withValues(alpha: 0.08),
                ),
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
                    return Text(
                      '$intVal',
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colors.outline.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
