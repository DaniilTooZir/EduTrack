import 'package:edu_track/data/repositories/debt_repository.dart';
import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/student_debt_info.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_bottom_sheet.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Color _avgColor(double avg) {
  if (avg >= 4.5) return Colors.green;
  if (avg >= 3.5) return Colors.lightGreen;
  if (avg >= 2.5) return Colors.orange;
  return Colors.red;
}

class TeacherDebtsScreen extends StatefulWidget {
  const TeacherDebtsScreen({super.key});

  @override
  State<TeacherDebtsScreen> createState() => _TeacherDebtsScreenState();
}

class _TeacherDebtsScreenState extends State<TeacherDebtsScreen> {
  late final DebtRepository _debtRepo;

  bool _isLoadingGroups = true;
  bool _isLoadingDebts = false;
  String? _error;
  List<({String id, String name})> _groups = [];
  String? _selectedGroupId;
  List<StudentDebtInfo> _debts = [];
  bool _showOnlyDebtors = true;

  @override
  void initState() {
    super.initState();
    _debtRepo = Provider.of<DebtRepository>(context, listen: false);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    setState(() {
      _isLoadingGroups = true;
      _error = null;
    });
    final result = await _debtRepo.getTeacherGroups(teacherId);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.errorMessage;
        _isLoadingGroups = false;
      });
      return;
    }
    setState(() {
      _groups = result.data;
      _isLoadingGroups = false;
      if (_groups.isNotEmpty) _selectedGroupId = _groups.first.id;
    });
    if (_groups.isNotEmpty) await _loadDebts();
  }

  Future<void> _loadDebts() async {
    if (_selectedGroupId == null) return;
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    setState(() {
      _isLoadingDebts = true;
      _error = null;
    });
    final result = await _debtRepo.getGroupDebts(
      groupId: _selectedGroupId!,
      startDate: period?.startDate,
      endDate: period?.endDate,
    );
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.errorMessage;
        _isLoadingDebts = false;
      });
      return;
    }
    setState(() {
      _debts = result.data;
      _isLoadingDebts = false;
    });
  }

  List<StudentDebtInfo> get _displayedList {
    var list = [..._debts];
    if (_showOnlyDebtors) list = list.where((d) => d.hasDebts).toList();
    list.sort((a, b) {
      if (a.hasLowGrade && !b.hasLowGrade) return -1;
      if (!a.hasLowGrade && b.hasLowGrade) return 1;
      if (a.averageGrade != b.averageGrade) return a.averageGrade.compareTo(b.averageGrade);
      if (b.pendingHomeworkCount != a.pendingHomeworkCount) {
        return b.pendingHomeworkCount.compareTo(a.pendingHomeworkCount);
      }
      return a.student.surname.compareTo(b.student.surname);
    });
    return list;
  }

  void _openStudentGrades(Student student) {
    showAppBottomSheet(context, builder: (_) => _DebtStudentGradesSheet(student: student));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoadingGroups) return _buildGroupsSkeleton();
    if (_error != null && _groups.isEmpty) return AppErrorView(message: _error!, onRetry: _loadGroups);
    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.l),
            Text('Нет доступных групп', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadDebts,
      color: colors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [_buildGroupSelector(colors), const SizedBox(height: AppSpacing.m), _buildFilterRow(colors)],
              ),
            ),
          ),
          if (_isLoadingDebts)
            SliverFillRemaining(child: _buildDebtsSkeleton())
          else if (_error != null)
            SliverFillRemaining(child: AppErrorView(message: _error!, onRetry: _loadDebts))
          else
            ..._buildBody(colors),
        ],
      ),
    );
  }

  Widget _buildGroupSelector(ColorScheme colors) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Группа',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGroupId,
          isDense: true,
          isExpanded: true,
          items: _groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
          onChanged: (val) {
            if (val != _selectedGroupId) {
              setState(() => _selectedGroupId = val);
              _loadDebts();
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterRow(ColorScheme colors) {
    final debtorCount = _debts.where((d) => d.hasDebts).length;
    final displayed = _displayedList;
    return Row(
      children: [
        FilterChip(
          label: Text(_showOnlyDebtors ? 'Задолжники ($debtorCount)' : 'Показать всех (${_debts.length})'),
          selected: _showOnlyDebtors,
          onSelected: (val) => setState(() => _showOnlyDebtors = val),
          selectedColor: colors.errorContainer,
          checkmarkColor: colors.onErrorContainer,
          labelStyle: TextStyle(color: _showOnlyDebtors ? colors.onErrorContainer : colors.onSurface),
        ),
        const SizedBox(width: 8),
        Text('Найдено: ${displayed.length}', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
      ],
    );
  }

  List<Widget> _buildBody(ColorScheme colors) {
    final list = _displayedList;
    if (list.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withValues(alpha: 0.7)),
                const SizedBox(height: AppSpacing.l),
                Text(
                  _showOnlyDebtors ? 'Задолжников нет!' : 'Студентов нет',
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
                ),
                if (_showOnlyDebtors)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Все студенты успевают',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _StudentDebtCard(info: list[i], onTap: () => _openStudentGrades(list[i].student)),
            childCount: list.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildGroupsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 5,
      itemBuilder:
          (_, __) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Skeleton(height: 44, width: 44, borderRadius: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 14, width: 160),
                        SizedBox(height: 6),
                        Skeleton(height: 12, width: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDebtsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      itemBuilder:
          (_, __) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Skeleton(height: 44, width: 44, borderRadius: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 14, width: 160),
                        SizedBox(height: 6),
                        Skeleton(height: 12, width: 100),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Skeleton(height: 24, width: 24),
                ],
              ),
            ),
          ),
    );
  }
}

class _StudentDebtCard extends StatelessWidget {
  final StudentDebtInfo info;
  final VoidCallback? onTap;
  const _StudentDebtCard({required this.info, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avg = info.averageGrade;
    final avgColor = avg == 0 ? colors.onSurfaceVariant : _avgColor(avg);
    final avgText = avg == 0 ? '—' : avg.toStringAsFixed(1);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: info.hasDebts ? BorderSide(color: colors.error.withValues(alpha: 0.4)) : BorderSide.none,
      ),
      child:
          info.pendingHomeworkCount > 0
              ? ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _AvgBadge(text: avgText, color: avgColor),
                title: Text(
                  '${info.student.surname} ${info.student.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: _Subtitle(info: info, colors: colors),
                trailing: Icon(Icons.warning_amber_rounded, color: colors.error),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Несданные задания:',
                          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        ...info.pendingHomeworkTitles.map(
                          (title) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.assignment_late_rounded, size: 16, color: colors.error),
                                const SizedBox(width: 8),
                                Expanded(child: Text(title, style: TextStyle(color: colors.onSurface, fontSize: 13))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.bar_chart_rounded, size: 16),
                            label: const Text('Журнал оценок'),
                            onPressed: onTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _AvgBadge(text: avgText, color: avgColor),
                title: Text(
                  '${info.student.surname} ${info.student.name}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: _Subtitle(info: info, colors: colors),
                trailing:
                    info.hasDebts
                        ? Icon(Icons.warning_amber_rounded, color: colors.error)
                        : Icon(Icons.check_circle, color: Colors.green, size: 22),
                onTap: onTap,
              ),
    );
  }
}

class _AvgBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _AvgBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Center(child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final StudentDebtInfo info;
  final ColorScheme colors;
  const _Subtitle({required this.info, required this.colors});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (info.hasLowGrade) parts.add('Низкий балл');
    if (info.hasPendingHomework) parts.add('${info.pendingHomeworkCount} ДЗ не сдано');
    if (parts.isEmpty) return Text('Успевает', style: TextStyle(color: Colors.green, fontSize: 12));
    return Text(parts.join(' • '), style: TextStyle(color: colors.error, fontSize: 12));
  }
}

class _DebtStudentGradesSheet extends StatefulWidget {
  final Student student;
  const _DebtStudentGradesSheet({required this.student});

  @override
  State<_DebtStudentGradesSheet> createState() => _DebtStudentGradesSheetState();
}

class _DebtStudentGradesSheetState extends State<_DebtStudentGradesSheet> {
  late final GradeRepository _gradeService;
  bool _isLoading = true;
  String? _error;
  List<SubjectAnalytics> _analytics = [];

  @override
  void initState() {
    super.initState();
    _gradeService = Provider.of<GradeRepository>(context, listen: false);
    _load();
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
                          style: TextStyle(fontSize: 13, color: _avgColor(gpa), fontWeight: FontWeight.w600),
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
      itemBuilder: (context, index) {
        final analytics = withGrades[index];
        final avg = analytics.averageGrade;
        final avgColor = _avgColor(avg);
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
              decoration: BoxDecoration(
                color: avgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
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
              child: Text('${entries.length} оценок', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            ),
            children: [
              Divider(height: 1, color: colors.outlineVariant),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _avgColor(e.value.toDouble()).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.value}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _avgColor(e.value.toDouble()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(formatDate(e.date), style: TextStyle(fontSize: 14, color: colors.onSurface)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
