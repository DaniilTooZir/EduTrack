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
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
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
      nextLesson = _findNextLesson(scheduleResult.data);
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

  Future<void> _showJournalSelectorSheet({bool switchToTab = false}) async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _JournalSelectorSheet(teacherId: teacherId),
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent =
            _isLoading
                ? _buildTeacherHomeSkeleton()
                : _hasError
                ? _buildErrorState(colors)
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
        leadingWidth: _selectedIndex == 8 ? 248 : 56,
        leading:
            _selectedIndex == 8
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder:
                          (ctx) =>
                              IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()),
                    ),
                    TextButton.icon(
                      onPressed: _showJournalSelectorSheet,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.white),
                      label: const Text('Сменить предмет', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (_journalExportCallback != null)
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 22),
                        tooltip: 'Экспорт в PDF',
                        onPressed: _journalExportCallback,
                      ),
                  ],
                )
                : null,
        actions: [
          const PeriodDropdown(),
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _refreshDashboard),
          if (_selectedIndex == 8 && _journalRefreshCallback != null)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _journalRefreshCallback),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await userProvider.clearUser();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.secondary, colors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Меню преподавателя',
                  style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0, colors),
            _buildDrawerItem(Icons.assignment_rounded, 'Домашние задания', 1, colors),
            _buildDrawerItem(Icons.checklist_rtl_rounded, 'Проверка ДЗ', 5, colors),
            _buildDrawerItem(Icons.supervised_user_circle_rounded, 'Моя группа', 6, colors),
            ListTile(
              leading: Icon(
                Icons.table_chart_rounded,
                color: _selectedIndex == 8 ? colors.primary : colors.onSurfaceVariant,
              ),
              title: Text(
                'Журнал успеваемости',
                style: TextStyle(
                  color: _selectedIndex == 8 ? colors.primary : colors.onSurface,
                  fontWeight: _selectedIndex == 8 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: _selectedIndex == 8,
              selectedTileColor: colors.primaryContainer.withValues(alpha: 0.3),
              onTap: _openJournalSelector,
            ),
            _buildDrawerItem(Icons.warning_amber_rounded, 'Задолженности', 9, colors),
            _buildDrawerItem(Icons.message_rounded, 'Сообщения', 7, colors),
            _buildDrawerItem(Icons.menu_book_rounded, 'Мои занятия', 2, colors),
            _buildDrawerItem(Icons.calendar_month_rounded, 'Расписание', 3, colors),
            _buildDrawerItem(Icons.person_rounded, 'Профиль', 4, colors),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: colors.onSurfaceVariant),
              title: Text('Настройки', style: TextStyle(color: colors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                showSettingsSheet(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: bodyContent,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, ColorScheme colors) {
    final bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? colors.primary : colors.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? colors.primary : colors.onSurface,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.3),
      onTap: () {
        _navigateToTab(index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshDashboard();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(colors),
            const SizedBox(height: 16),
            if (_nextLesson != null) ...[
              Text(
                'Ближайший урок',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 8),
              _buildNextLessonCard(_nextLesson!, colors),
              const SizedBox(height: 16),
            ],
            Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickActionCard(Icons.add_task, 'Выдать ДЗ', () => _navigateToTab(1), colors),
                  _buildQuickActionCard(Icons.checklist, 'Проверить ДЗ', () => _navigateToTab(5), colors),
                  _buildQuickActionCard(Icons.warning_amber_rounded, 'Задолжники', () => _navigateToTab(9), colors),
                  _buildQuickActionCard(Icons.group, 'Моя группа', () => _navigateToTab(6), colors),
                  _buildQuickActionCard(Icons.play_lesson, 'Начать урок', () => _navigateToTab(2), colors),
                  _buildQuickActionCard(Icons.calendar_today, 'Расписание', () => _navigateToTab(3), colors),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ваши предметы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary)),
            const SizedBox(height: 12),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToTab(2),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Нажмите, чтобы перейти к урокам',
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

  Widget _buildWelcomeCard(ColorScheme colors) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firstName = userProvider.userName ?? 'преподаватель';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.secondary, colors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'С возвращением, $firstName!',
            style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Готовы начать учебный день? Проверьте расписание или создайте новые задания.',
            style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String label, VoidCallback onTap, ColorScheme colors) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: colors.surface,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: colors.primary, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          const SizedBox(height: 16),
          Text('Не удалось загрузить данные', style: TextStyle(fontSize: 16, color: colors.error)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Повторить')),
        ],
      ),
    );
  }

  Schedule? _findNextLesson(List<Schedule> schedules) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Schedule? best;
    DateTime? bestStart;
    for (final s in schedules) {
      if (s.date == null) continue;
      final lessonDate = DateTime(s.date!.year, s.date!.month, s.date!.day);
      if (lessonDate.isBefore(today)) continue;
      final parts = s.startTime.split(':');
      if (parts.length < 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      final lessonStart = DateTime(lessonDate.year, lessonDate.month, lessonDate.day, h, m);
      if (lessonDate == today && lessonStart.isBefore(now)) continue;
      if (best == null || lessonStart.isBefore(bestStart!)) {
        best = s;
        bestStart = lessonStart;
      }
    }
    return best;
  }

  String _lessonDateLabel(Schedule s) {
    if (s.date == null) return '';
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lessonDate = DateTime(s.date!.year, s.date!.month, s.date!.day);
    final diff = lessonDate.difference(todayDate).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Завтра';
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return '${days[s.date!.weekday - 1]}, ${s.date!.day.toString().padLeft(2, '0')}.${s.date!.month.toString().padLeft(2, '0')}';
  }

  Widget _buildNextLessonCard(Schedule lesson, ColorScheme colors) {
    final label = _lessonDateLabel(lesson);
    final isToday = label == 'Сегодня';
    final accentColor = isToday ? colors.primary : colors.secondary;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time_rounded, size: 15, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.startTime.substring(0, 5)} – ${lesson.endTime.substring(0, 5)}',
                          style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.subjectName ?? 'Предмет',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 15, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lesson.groupName ?? 'Группа',
                            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          const SizedBox(height: 16),
          const Skeleton(height: 22, width: 160),
          const SizedBox(height: 8),
          const Skeleton(height: 86, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 16),
          const Skeleton(height: 20, width: 150),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
  const _JournalSelectorSheet({required this.teacherId});

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
            const SizedBox(height: 16),
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
