import 'package:edu_track/data/services/debt_service.dart';
import 'package:edu_track/models/student_debt_info.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
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
  final DebtService _debtService = DebtService();

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
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    setState(() {
      _isLoadingGroups = true;
      _error = null;
    });
    final result = await _debtService.getTeacherGroups(teacherId);
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
      if (_groups.isNotEmpty) {
        _selectedGroupId = _groups.first.id;
      }
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
    final result = await _debtService.getGroupDebts(
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoadingGroups) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _groups.isEmpty) return AppErrorView(message: _error!, onRetry: _loadGroups);
    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
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
                children: [_buildGroupSelector(colors), const SizedBox(height: 12), _buildFilterRow(colors)],
              ),
            ),
          ),
          if (_isLoadingDebts)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
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
          label: Text(_showOnlyDebtors ? 'Только задолжники ($debtorCount)' : 'Все студенты (${_debts.length})'),
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
                const SizedBox(height: 16),
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
          delegate: SliverChildBuilderDelegate((ctx, i) => _StudentDebtCard(info: list[i]), childCount: list.length),
        ),
      ),
    ];
  }
}

class _StudentDebtCard extends StatelessWidget {
  final StudentDebtInfo info;
  const _StudentDebtCard({required this.info});

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
    if (parts.isEmpty) {
      return Text('Успевает', style: TextStyle(color: Colors.green, fontSize: 12));
    }
    return Text(parts.join(' • '), style: TextStyle(color: colors.error, fontSize: 12));
  }
}
