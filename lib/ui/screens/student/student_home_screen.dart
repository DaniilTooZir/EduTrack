import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/repositories/homework_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/chat_list_screen.dart';
import 'package:edu_track/ui/screens/chat_screen.dart';
import 'package:edu_track/ui/screens/student/student_analytics_screen.dart';
import 'package:edu_track/ui/screens/student/student_homework_screen.dart';
import 'package:edu_track/ui/screens/student/student_lesson_screen.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';
import 'package:edu_track/ui/screens/student/student_schedule_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/drawer_nav_item.dart';
import 'package:edu_track/ui/widgets/next_lesson_card.dart';
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/quick_action_card.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/ui/widgets/stat_card.dart';
import 'package:edu_track/ui/widgets/welcome_card.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:edu_track/utils/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  bool _isDashboardLoading = true;
  String? _dashboardError;
  int _totalHomework = 0;
  int _completedHomework = 0;
  int _pendingHomework = 0;
  double _overallAverage = 0.0;
  ScheduleRepository get _scheduleRepository => Provider.of<ScheduleRepository>(context, listen: false);
  HomeworkRepository get _homeworkRepository => Provider.of<HomeworkRepository>(context, listen: false);
  GradeRepository get _gradeRepository => Provider.of<GradeRepository>(context, listen: false);
  Schedule? _nextLesson;
  final List<String> _titles = [
    'Главная',
    'Домашние задания',
    'Уроки',
    'Расписание',
    'Профиль',
    'Сообщения',
    'Аналитика',
  ];

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 0) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    if (!_isDashboardLoading) {
      setState(() {
        _isDashboardLoading = true;
        _dashboardError = null;
      });
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final studentId = userProvider.userId;
    final groupId = userProvider.groupId;
    if (studentId == null) {
      if (mounted) {
        setState(() {
          _dashboardError = 'Не удалось получить ID студента';
          _isDashboardLoading = false;
        });
      }
      return;
    }
    final homeworksResult = await _homeworkRepository.getHomeworksForStudentGroup(studentId, groupId ?? '');
    if (homeworksResult.isFailure) {
      if (mounted) {
        setState(() {
          _dashboardError = homeworksResult.errorMessage;
          _isDashboardLoading = false;
        });
      }
      return;
    }
    final statusesResult = await _homeworkRepository.getStatusesForStudent(studentId);
    if (statusesResult.isFailure) {
      if (mounted) {
        setState(() {
          _dashboardError = statusesResult.errorMessage;
          _isDashboardLoading = false;
        });
      }
      return;
    }
    final homeworks = homeworksResult.data;
    final statuses = statusesResult.data;
    final statusMap = {for (final s in statuses) s.homeworkId: s};
    int completed = 0;
    int pending = 0;
    for (final hw in homeworks) {
      final status = statusMap[hw.id];
      if (status != null && status.isCompleted) {
        completed++;
      } else {
        pending++;
      }
    }
    final avg = await _gradeRepository.getStudentAverage(studentId);
    final scheduleResult = await _scheduleRepository.getScheduleForStudent(studentId, groupId);
    Schedule? nextLesson;
    if (scheduleResult.isSuccess) {
      nextLesson = findNextLesson(scheduleResult.data);
    }
    if (mounted) {
      setState(() {
        _totalHomework = homeworks.length;
        _completedHomework = completed;
        _pendingHomework = pending;
        _overallAverage = avg;
        _nextLesson = nextLesson;
        _isDashboardLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _isDashboardLoading ? _buildDashboardSkeleton(colors) : _buildDashboard(colors);
        break;
      case 1:
        body = const StudentHomeworkScreen();
        break;
      case 2:
        body = const StudentLessonScreen();
        break;
      case 3:
        body = const StudentScheduleScreen();
        break;
      case 4:
        body = const StudentProfileScreen();
        break;
      case 5:
        body = const ChatListScreen();
        break;
      case 6:
        body = const StudentAnalyticsScreen();
        break;
      default:
        body = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          const PeriodDropdown(),
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _loadDashboardData),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).clearUser();
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
                  'Меню студента',
                  style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DrawerNavItem(
              icon: Icons.dashboard_rounded,
              title: 'Главная',
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.assignment_rounded,
              title: 'Домашние задания',
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.menu_book_rounded,
              title: 'Уроки',
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.calendar_month_rounded,
              title: 'Расписание',
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.message_rounded,
              title: 'Сообщения',
              selected: _selectedIndex == 5,
              onTap: () {
                _onItemTapped(5);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.bar_chart_rounded,
              title: 'Аналитика',
              selected: _selectedIndex == 6,
              onTap: () {
                _onItemTapped(6);
                Navigator.of(context).pop();
              },
            ),
            DrawerNavItem(
              icon: Icons.person_rounded,
              title: 'Профиль',
              selected: _selectedIndex == 4,
              onTap: () {
                _onItemTapped(4);
                Navigator.of(context).pop();
              },
            ),
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
        child: body,
      ),
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firstName = userProvider.userName ?? 'студент';
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(
              title: 'Привет, $firstName!',
              subtitleWidget: Builder(
                builder: (ctx) {
                  final groupName = Provider.of<UserProvider>(ctx, listen: false).groupName;
                  final onPrimary = Theme.of(ctx).colorScheme.onPrimary;
                  return Text(
                    groupName != null ? 'Твоя группа: $groupName' : 'Добро пожаловать в EduTrack',
                    style: TextStyle(color: onPrimary.withValues(alpha: 0.9), fontSize: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildDebtBanner(colors),
            if (_nextLesson != null) ...[
              Text(
                'Ближайший урок',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 8),
              NextLessonCard(
                lesson: _nextLesson!,
                dateLabel: lessonDateLabel(_nextLesson!),
                detailIcon: Icons.person_outline,
                detailText: _nextLesson!.teacherName,
              ),
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
                  QuickActionCard(icon: Icons.assignment, label: 'Мои задания', onTap: () => _onItemTapped(1)),
                  QuickActionCard(icon: Icons.calendar_month, label: 'Расписание', onTap: () => _onItemTapped(3)),
                  QuickActionCard(icon: Icons.menu_book, label: 'Уроки', onTap: () => _onItemTapped(2)),
                  QuickActionCard(icon: Icons.bar_chart_rounded, label: 'Аналитика', onTap: () => _onItemTapped(6)),
                  QuickActionCard(icon: Icons.forum, label: 'Чат группы', onTap: () => _openGroupChat(context)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Твоя успеваемость',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 12),
            if (_isDashboardLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_dashboardError != null)
              Center(child: Text(_dashboardError!, style: TextStyle(color: colors.error)))
            else
              Column(
                children: [
                  StatCard(
                    icon: Icons.assignment,
                    title: 'Всего заданий',
                    value: '$_totalHomework',
                    iconColor: colors.primary,
                    bgColor: colors.primaryContainer,
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    icon: Icons.check_circle,
                    title: 'Выполнено',
                    value: '$_completedHomework',
                    iconColor: Colors.green,
                    bgColor: Colors.green.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    icon: Icons.pending_actions,
                    title: 'Осталось',
                    value: '$_pendingHomework',
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtBanner(ColorScheme colors) {
    final hasLowGrade = _overallAverage > 0 && _overallAverage < 3.0;
    final hasPending = _pendingHomework > 0;
    if (!hasLowGrade && !hasPending) return const SizedBox.shrink();
    final parts = <String>[];
    if (hasLowGrade) parts.add('Средний балл: ${_overallAverage.toStringAsFixed(1)} (ниже 3.0)');
    if (hasPending) parts.add('$_pendingHomework невыполненных заданий');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Внимание: есть задолженности',
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.onErrorContainer, fontSize: 14),
                ),
                const SizedBox(height: 4),
                ...parts.map((p) => Text('• $p', style: TextStyle(color: colors.onErrorContainer, fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGroupChat(BuildContext context) async {
    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupId = userProvider.groupId;
    final groupName = userProvider.groupName;
    if (groupId == null) {
      MessengerHelper.showError('Не удалось получить данные группы');
      return;
    }
    final chatResult = await ChatService().getOrCreateGroupChat(groupId, groupName ?? groupId);
    if (chatResult.isFailure) {
      MessengerHelper.showError(chatResult.errorMessage);
      return;
    }
    if (mounted) {
      await navigator.push(
        MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatResult.data, title: 'Группа $groupName')),
      );
    }
  }

  Widget _buildDashboardSkeleton(ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 160, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 16),
          const Skeleton(height: 22, width: 160),
          const SizedBox(height: 8),
          const Skeleton(height: 86, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 16),
          const Skeleton(height: 24, width: 180),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Skeleton(height: 110, width: 110, borderRadius: 16),
                  ),
            ),
          ),
          const SizedBox(height: 24),
          const Skeleton(height: 24, width: 200),
          const SizedBox(height: 12),
          const Skeleton(height: 90, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 12),
          const Skeleton(height: 90, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 12),
          const Skeleton(height: 90, width: double.infinity, borderRadius: 16),
        ],
      ),
    );
  }
}
