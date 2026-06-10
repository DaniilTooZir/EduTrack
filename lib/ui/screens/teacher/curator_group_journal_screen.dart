import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_bottom_sheet.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _SortMode { name, gradeDesc }

Color _gradeColor(double avg) {
  if (avg >= 4.5) return Colors.green;
  if (avg >= 3.5) return Colors.lightGreen;
  if (avg >= 2.5) return Colors.orange;
  return Colors.red;
}

class CuratorGroupJournalScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<Student> students;

  const CuratorGroupJournalScreen({super.key, required this.groupId, required this.groupName, required this.students});

  @override
  State<CuratorGroupJournalScreen> createState() => _CuratorGroupJournalScreenState();
}

class _CuratorGroupJournalScreenState extends State<CuratorGroupJournalScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _SortMode _sortMode = _SortMode.name;
  Map<String, double> _avgGrades = {};
  Map<String, List<SubjectAnalytics>> _analyticsCache = {};
  bool _gradesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllAverages();
  }

  Future<void> _loadAllAverages() async {
    if (widget.students.isEmpty) {
      if (mounted) setState(() => _gradesLoading = false);
      return;
    }
    final gradeRepo = Provider.of<GradeRepository>(context, listen: false);
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    final results = await Future.wait(
      widget.students.map(
        (s) => gradeRepo.getStudentAnalytics(s.id, startDate: period?.startDate, endDate: period?.endDate),
      ),
    );
    if (!mounted) return;
    final avgs = <String, double>{};
    final cache = <String, List<SubjectAnalytics>>{};
    for (var i = 0; i < widget.students.length; i++) {
      final result = results[i];
      if (result.isSuccess) {
        final analytics = result.data;
        cache[widget.students[i].id] = analytics;
        final allGrades = analytics.expand((a) => a.grades).toList();
        if (allGrades.isNotEmpty) {
          avgs[widget.students[i].id] = allGrades.fold<int>(0, (acc, g) => acc + g.value) / allGrades.length;
        }
      }
    }
    setState(() {
      _analyticsCache = cache;
      _avgGrades = avgs;
      _gradesLoading = false;
    });
  }

  List<Student> get _filtered {
    var base = [...widget.students];
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      base = base.where((s) => s.name.toLowerCase().contains(q) || s.surname.toLowerCase().contains(q)).toList();
    }
    if (_sortMode == _SortMode.gradeDesc) {
      base.sort((a, b) {
        final avgA = _avgGrades[a.id] ?? -1;
        final avgB = _avgGrades[b.id] ?? -1;
        return avgB.compareTo(avgA);
      });
    } else {
      base.sort((a, b) => a.surname.compareTo(b.surname));
    }
    return base;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStudentGrades(Student student) {
    showAppBottomSheet(
      context,
      builder: (_) => _StudentGradesSheet(student: student, preloaded: _analyticsCache[student.id]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Text('Журнал: ${widget.groupName}'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по студентам...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _query.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                        : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('По фамилии'),
                  selected: _sortMode == _SortMode.name,
                  onSelected: (_) => setState(() => _sortMode = _SortMode.name),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('По баллу'),
                  selected: _sortMode == _SortMode.gradeDesc,
                  onSelected: (_) => setState(() => _sortMode = _SortMode.gradeDesc),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                widget.students.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: AppSpacing.l),
                          Text(
                            'Студентов в группе нет',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                    : filtered.isEmpty
                    ? Center(child: Text('Ничего не найдено', style: TextStyle(color: colors.onSurfaceVariant)))
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder:
                          (context, index) => _StudentCard(
                            student: filtered[index],
                            onTap: () => _openStudentGrades(filtered[index]),
                            avgGrade: _gradesLoading ? null : _avgGrades[filtered[index].id],
                            isGradesLoading: _gradesLoading,
                          ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final double? avgGrade;
  final bool isGradesLoading;

  const _StudentCard({required this.student, required this.onTap, this.avgGrade, this.isGradesLoading = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: student.isHeadman ? Colors.amber : colors.primaryContainer,
                child: Icon(
                  student.isHeadman ? Icons.star : Icons.person,
                  color: student.isHeadman ? Colors.white : colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.surname} ${student.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (student.isHeadman)
                      Text('Cтароста', style: TextStyle(fontSize: 12, color: Colors.amber.shade700)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGradesLoading)
                    const Skeleton(height: 28, width: 44, borderRadius: 14)
                  else if (avgGrade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gradeColor(avgGrade!).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        avgGrade!.toStringAsFixed(1),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _gradeColor(avgGrade!)),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentGradesSheet extends StatefulWidget {
  final Student student;
  final List<SubjectAnalytics>? preloaded;
  const _StudentGradesSheet({required this.student, this.preloaded});

  @override
  State<_StudentGradesSheet> createState() => _StudentGradesSheetState();
}

class _StudentGradesSheetState extends State<_StudentGradesSheet> {
  late final GradeRepository _gradeService;
  bool _isLoading = true;
  String? _error;
  List<SubjectAnalytics> _analytics = [];

  @override
  void initState() {
    super.initState();
    _gradeService = Provider.of<GradeRepository>(context, listen: false);
    if (widget.preloaded != null) {
      _analytics = widget.preloaded!;
      _isLoading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    final result = await _gradeService.getStudentAnalytics(
      widget.student.id,
      startDate: period?.startDate,
      endDate: period?.endDate,
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.errorMessage;
        _isLoading = false;
      });
    } else {
      setState(() {
        _analytics = result.data;
        _isLoading = false;
      });
    }
  }

  double _overallGpa() {
    final allGrades = _analytics.expand((a) => a.grades).toList();
    if (allGrades.isEmpty) return 0;
    return allGrades.fold<int>(0, (acc, g) => acc + g.value) / allGrades.length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final gpa = _overallGpa();
    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.m),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.person, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.student.surname} ${widget.student.name}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      if (!_isLoading && _error == null && gpa > 0)
                        Text(
                          'Средний балл: ${gpa.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 13, color: _gradeColor(gpa), fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Обновить'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Divider(height: 1, color: colors.outlineVariant),
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return AppErrorView(message: _error!, onRetry: _load);
    if (_analytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.l),
            Text('Оценок пока нет', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }
    final withGrades =
        _analytics.where((a) => a.gradeSeries.isNotEmpty).toList()
          ..sort((a, b) => a.subject.name.compareTo(b.subject.name));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: withGrades.length,
      itemBuilder: (context, index) => _SubjectGradesTile(analytics: withGrades[index]),
    );
  }
}

class _SubjectGradesTile extends StatelessWidget {
  final SubjectAnalytics analytics;
  const _SubjectGradesTile({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avg = analytics.averageGrade;
    final avgColor = _gradeColor(avg);
    final entries = [...analytics.gradeSeries]..sort((a, b) => b.date.compareTo(a.date));
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: avgColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              avg == 0.0 ? '—' : avg.toStringAsFixed(1),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: avgColor),
            ),
          ),
        ),
        title: Text(
          analytics.subject.name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.onSurface),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${entries.length} ${_gradeWord(entries.length)}',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ),
        children: [
          Divider(height: 1, color: colors.outlineVariant),
          ...entries.asMap().entries.map((e) {
            final isLast = e.key == entries.length - 1;
            return Column(
              children: [
                _GradeEntryRow(entry: e.value, colors: colors),
                if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: colors.outlineVariant),
              ],
            );
          }),
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

class _GradeEntryRow extends StatelessWidget {
  final ({DateTime date, int value, String? gradeId}) entry;
  final ColorScheme colors;
  const _GradeEntryRow({required this.entry, required this.colors});

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(entry.value.toDouble());
    final d = entry.date;
    final dateStr = formatDate(d);
    const labels = {5: 'Отлично', 4: 'Хорошо', 3: 'Удовл.', 2: 'Неудовл.'};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${entry.value}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: gradeColor),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(dateStr, style: TextStyle(fontSize: 14, color: colors.onSurface))),
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
