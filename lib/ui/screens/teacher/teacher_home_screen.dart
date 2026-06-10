import 'dart:async';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/repositories/subject_repository.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/chat_list_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_debts_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_homework_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_homework_status_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_journal_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_lesson_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_my_group_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_profile_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_schedule_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/app_drawer.dart';
import 'package:edu_track/ui/widgets/app_error_view.dart';
import 'package:edu_track/ui/widgets/next_lesson_card.dart';
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/quick_action_card.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/ui/widgets/welcome_card.dart';
import 'package:edu_track/utils/app_bottom_sheet.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;
  List<Subject> _subjects = [];
  Schedule? _nextLesson;
  ScheduleRepository get _scheduleRepository => Provider.of<ScheduleRepository>(context, listen: false);
  SubjectRepository get _subjectRepository => Provider.of<SubjectRepository>(context, listen: false);
  String? _journalGroupId;
  String? _journalSubjectId;
  String? _journalGroupName;
  String? _journalSubjectName;
  bool _journalPrefsLoaded = false;
  VoidCallback? _journalRefreshCallback;
  VoidCallback? _journalExportCallback;
  final List<String> _titles = [
    'Главная',
    'Домашние задания',
    'Мои занятия',
    'Расписание',
    'Профиль',
    'Проверка ДЗ',
    'Моя группа',
    'Сообщения',
    'Журнал успеваемости',
    'Задолженности',
  ];

  Future<void> _loadData() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    final result = await _subjectRepository.getSubjectsByTeacherId(teacherId);
    if (result.isFailure) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }
    final scheduleResult = await _scheduleRepository.getScheduleForTeacher(teacherId);
    Schedule? nextLesson;
    if (scheduleResult.isSuccess) {
      nextLesson = findNextLesson(scheduleResult.data);
    }
    if (mounted) {
      setState(() {
        _subjects = result.data;
        _nextLesson = nextLesson;
        _isLoading = false;
      });
    }
  }

  static const _kGroupId = 'journal_group_id';
  static const _kSubjectId = 'journal_subject_id';
  static const _kGroupName = 'journal_group_name';
  static const _kSubjectName = 'journal_subject_name';

  Future<void> _loadSavedJournal() async {
    final prefs = await SharedPreferences.getInstance();
    final groupId = prefs.getString(_kGroupId);
    final subjectId = prefs.getString(_kSubjectId);
    if (!mounted) return;
    setState(() {
      _journalPrefsLoaded = true;
      if (groupId != null && subjectId != null) {
        _journalGroupId = groupId;
        _journalSubjectId = subjectId;
        _journalGroupName = prefs.getString(_kGroupName);
        _journalSubjectName = prefs.getString(_kSubjectName);
      }
    });
  }

  Future<void> _saveJournalSelection(Map<String, String?> result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGroupId, result['groupId']!);
    await prefs.setString(_kSubjectId, result['subjectId']!);
    if (result['groupName'] != null) await prefs.setString(_kGroupName, result['groupName']!);
    if (result['subjectName'] != null) await prefs.setString(_kSubjectName, result['subjectName']!);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSavedJournal();
  }

  void _refreshDashboard() {
    _loadData();
  }

  Future<void> _openJournalSelector() async {
    Navigator.pop(context);
    if (_journalPrefsLoaded && _journalGroupId != null && _journalSubjectId != null) {
      setState(() => _selectedIndex = 8);
    } else {
      await _showJournalSelectorSheet(switchToTab: true);
    }
  }

  Future<void> _showJournalSelectorSheet({bool switchToTab = false, String? initialSubjectId}) async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    final result = await showAppBottomSheet<Map<String, String>>(
      context,
      builder: (ctx) => _JournalSelectorSheet(teacherId: teacherId, initialSubjectId: initialSubjectId),
    );
    if (result != null && mounted) {
      unawaited(_saveJournalSelection(result));
      setState(() {
        _journalGroupId = result['groupId'];
        _journalSubjectId = result['subjectId'];
        _journalGroupName = result['groupName'];
        _journalSubjectName = result['subjectName'];
        if (switchToTab) _selectedIndex = 8;
      });
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Выход из аккаунта'),
            content: const Text('Вы уверены, что хотите выйти?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
                child: const Text('Выйти'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await Provider.of<UserProvider>(context, listen: false).clearUser();
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent =
            _isLoading
                ? _buildTeacherHomeSkeleton()
                : _hasError
                ? AppErrorView(message: 'Не удалось загрузить данные', onRetry: _loadData)
                : _buildDashboard(colors);
        break;
      case 1:
        bodyContent = TeacherHomeworkScreen(onTabRequest: _navigateToTab);
        break;
      case 2:
        bodyContent = const TeacherLessonScreen();
        break;
      case 3:
        bodyContent = const TeacherScheduleScreen();
        break;
      case 4:
        bodyContent = const TeacherProfileScreen();
        break;
      case 5:
        bodyContent = const TeacherHomeworkStatusScreen();
        break;
      case 6:
        bodyContent = const TeacherMyGroupScreen();
        break;
      case 7:
        bodyContent = const ChatListScreen();
        break;
      case 8:
        bodyContent =
            (_journalGroupId != null && _journalSubjectId != null)
                ? TeacherJournalScreen(
                  key: ValueKey('$_journalGroupId|$_journalSubjectId'),
                  groupId: _journalGroupId!,
                  subjectId: _journalSubjectId!,
                  groupName: _journalGroupName,
                  subjectName: _journalSubjectName,
                  onReady:
                      (fn) => WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _journalRefreshCallback = fn);
                      }),
                  onExportReady:
                      (fn) => WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _journalExportCallback = fn);
                      }),
                )
                : const SizedBox.shrink();
        break;
      case 9:
        bodyContent = const TeacherDebtsScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 8)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: 'Сменить предмет',
              onPressed: _showJournalSelectorSheet,
            ),
          if (_selectedIndex == 8 && _journalExportCallback != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Экспорт в PDF',
              onPressed: _journalExportCallback,
            ),
          if (_selectedIndex != 4 && _selectedIndex != 7) const PeriodDropdown(),
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _refreshDashboard),
          if (_selectedIndex == 8 && _journalRefreshCallback != null)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _journalRefreshCallback),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти', onPressed: () => _confirmLogout(context)),
        ],
      ),
      drawer: AppDrawer(
        title: 'Меню преподавателя',
        selectedIndex: _selectedIndex,
        onNavigate: _navigateToTab,
        items: [
          const AppDrawerItem(icon: Icons.dashboard_rounded, title: 'Главная', tabIndex: 0),
          const AppDrawerItem(icon: Icons.assignment_rounded, title: 'Домашние задания', tabIndex: 1),
          const AppDrawerItem(icon: Icons.checklist_rtl_rounded, title: 'Проверка ДЗ', tabIndex: 5),
          const AppDrawerItem(icon: Icons.supervised_user_circle_rounded, title: 'Моя группа', tabIndex: 6),
          AppDrawerItem(
            icon: Icons.table_chart_rounded,
            title: 'Журнал успеваемости',
            tabIndex: 8,
            customOnTap: _openJournalSelector,
          ),
          const AppDrawerItem(icon: Icons.warning_amber_rounded, title: 'Задолженности', tabIndex: 9),
          const AppDrawerItem(icon: Icons.message_rounded, title: 'Сообщения', tabIndex: 7),
          const AppDrawerItem(icon: Icons.menu_book_rounded, title: 'Мои занятия', tabIndex: 2),
          const AppDrawerItem(icon: Icons.calendar_month_rounded, title: 'Расписание', tabIndex: 3),
          const AppDrawerItem(icon: Icons.person_rounded, title: 'Профиль', tabIndex: 4),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: bodyContent,
      ),
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    final firstName = Provider.of<UserProvider>(context, listen: false).userName ?? 'преподаватель';
    return RefreshIndicator(
      onRefresh: _loadData,
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(
              title: 'С возвращением, $firstName!',
              subtitle: 'Готовы начать учебный день? Проверьте расписание или создайте новые задания.',
              useSecondaryGradient: true,
            ),
            const SizedBox(height: AppSpacing.l),
            if (_nextLesson != null) ...[
              Text(
                'Ближайший урок',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 8),
              NextLessonCard(
                lesson: _nextLesson!,
                dateLabel: lessonDateLabel(_nextLesson!),
                detailIcon: Icons.group_outlined,
                detailText: _nextLesson!.groupName ?? 'Группа',
              ),
              const SizedBox(height: AppSpacing.l),
            ],
            Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  QuickActionCard(icon: Icons.add_task, label: 'Выдать ДЗ', onTap: () => _navigateToTab(1)),
                  QuickActionCard(icon: Icons.checklist, label: 'Проверить ДЗ', onTap: () => _navigateToTab(5)),
                  QuickActionCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Задолжники',
                    onTap: () => _navigateToTab(9),
                  ),
                  QuickActionCard(icon: Icons.group, label: 'Моя группа', onTap: () => _navigateToTab(6)),
                  QuickActionCard(icon: Icons.play_lesson, label: 'Начать урок', onTap: () => _navigateToTab(2)),
                  QuickActionCard(icon: Icons.calendar_today, label: 'Расписание', onTap: () => _navigateToTab(3)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ваши предметы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
            const SizedBox(height: AppSpacing.m),
            if (_subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Предметов пока нет', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subjects.length,
                itemBuilder: (ctx, index) {
                  return _buildSubjectCard(_subjects[index], colors);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, ColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: colors.surface,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => _showJournalSelectorSheet(initialSubjectId: subject.id, switchToTab: true),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors.secondary, colors.primary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Нажмите, чтобы открыть журнал',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherHomeSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 150, width: double.infinity, borderRadius: 24),
          const SizedBox(height: AppSpacing.l),
          const Skeleton(height: 22, width: 160),
          const SizedBox(height: 8),
          const Skeleton(height: 86, width: double.infinity, borderRadius: 16),
          const SizedBox(height: AppSpacing.l),
          const Skeleton(height: 20, width: 150),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Skeleton(height: 110, width: 110, borderRadius: 16),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          const Skeleton(height: 20, width: 180),
          const SizedBox(height: AppSpacing.m),
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 80, width: double.infinity, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchedulePair {
  final String groupId;
  final String groupName;
  final String subjectId;
  final String subjectName;

  const _SchedulePair({
    required this.groupId,
    required this.groupName,
    required this.subjectId,
    required this.subjectName,
  });
}

class _JournalSelectorSheet extends StatefulWidget {
  final String teacherId;
  final String? initialSubjectId;
  const _JournalSelectorSheet({required this.teacherId, this.initialSubjectId});

  @override
  State<_JournalSelectorSheet> createState() => _JournalSelectorSheetState();
}

class _JournalSelectorSheetState extends State<_JournalSelectorSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_SchedulePair> _pairs = [];
  List<({String id, String name})> _subjects = [];
  List<({String id, String name})> _filteredGroups = [];
  String? _selectedSubjectId;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _loadPairs();
  }

  Future<void> _loadPairs() async {
    try {
      final response = await SupabaseConnection.client
          .from('schedule')
          .select('group_id, subject_id, group:groups(id, name), subject:subjects(id, name)')
          .eq('teacher_id', widget.teacherId);
      final seen = <String>{};
      final pairs = <_SchedulePair>[];
      for (final item in response as List) {
        final groupId = item['group_id']?.toString() ?? '';
        final subjectId = item['subject_id']?.toString() ?? '';
        final key = '$groupId|$subjectId';
        if (groupId.isEmpty || subjectId.isEmpty || !seen.add(key)) continue;
        final groupData = item['group'] as Map<String, dynamic>?;
        final subjectData = item['subject'] as Map<String, dynamic>?;
        pairs.add(
          _SchedulePair(
            groupId: groupId,
            groupName: groupData?['name'] as String? ?? groupId,
            subjectId: subjectId,
            subjectName: subjectData?['name'] as String? ?? subjectId,
          ),
        );
      }

      final uniqueSubjects = <String, ({String id, String name})>{};
      for (final p in pairs) {
        uniqueSubjects[p.subjectId] = (id: p.subjectId, name: p.subjectName);
      }

      setState(() {
        _pairs = pairs;
        _subjects = uniqueSubjects.values.toList()..sort((a, b) => a.name.compareTo(b.name));
        _isLoading = false;
      });
      if (widget.initialSubjectId != null && _subjects.any((s) => s.id == widget.initialSubjectId)) {
        _onSubjectChanged(widget.initialSubjectId);
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'Не удалось загрузить данные расписания';
        _isLoading = false;
      });
    }
  }

  void _onSubjectChanged(String? subjectId) {
    final seen = <String>{};
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedGroupId = null;
      _filteredGroups =
          _pairs
              .where((p) => p.subjectId == subjectId)
              .map((p) => (id: p.groupId, name: p.groupName))
              .where((g) => seen.add(g.id))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            'Журнал успеваемости',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 6),
          Text('Выберите предмет и группу', style: TextStyle(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: TextStyle(color: colors.error)))
          else if (_subjects.isEmpty)
            Center(child: Text('Нет доступного расписания', style: TextStyle(color: colors.onSurfaceVariant)))
          else ...[
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Предмет',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSubjectId,
                  isDense: true,
                  isExpanded: true,
                  items: _subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: _onSubjectChanged,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Группа',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroupId,
                  isDense: true,
                  isExpanded: true,
                  items: _filteredGroups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                  onChanged: _selectedSubjectId == null ? null : (val) => setState(() => _selectedGroupId = val),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedGroupId != null && _selectedSubjectId != null
                        ? () {
                          final grp = _filteredGroups.firstWhere((g) => g.id == _selectedGroupId);
                          final subj = _subjects.firstWhere((s) => s.id == _selectedSubjectId);
                          Navigator.of(context).pop({
                            'groupId': _selectedGroupId!,
                            'subjectId': _selectedSubjectId!,
                            'groupName': grp.name,
                            'subjectName': subj.name,
                          });
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Открыть журнал', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
