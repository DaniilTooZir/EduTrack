import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/data/services/debt_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
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
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
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
  String? _groupName;
  int _totalHomework = 0;
  int _completedHomework = 0;
  int _pendingHomework = 0;
  double _overallAverage = 0.0;
  final HomeworkService _homeworkService = HomeworkService();
  final DebtService _debtService = DebtService();
  final ScheduleService _scheduleService = ScheduleService();
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
    final db = Provider.of<AppDatabase>(context, listen: false);
    final studentId = userProvider.userId;
    if (studentId == null) {
      if (mounted) {
        setState(() {
          _dashboardError = 'Не удалось получить ID студента';
          _isDashboardLoading = false;
        });
      }
      return;
    }
    final groupResult = await _homeworkService.getGroupByStudentId(studentId);
    String? groupName;
    if (groupResult.isSuccess && groupResult.data != null) {
      groupName = groupResult.data!['name'] as String;
    }
    final homeworksResult = await _homeworkService.getHomeworksByStudentGroup(studentId);
    if (homeworksResult.isFailure) {
      if (mounted) {
        setState(() {
          _dashboardError = homeworksResult.errorMessage;
          _isDashboardLoading = false;
        });
      }
      return;
    }
    final statusesResult = await _homeworkService.getHomeworkStatusesForStudent(studentId);
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
    final avgResult = await _debtService.getStudentOverallAverage(studentId);
    final avg = avgResult.isSuccess ? avgResult.data : 0.0;
    final scheduleResult = await _scheduleService.getScheduleForStudent(studentId, userProvider.groupId, db);
    Schedule? nextLesson;
    if (scheduleResult.isSuccess) {
      nextLesson = _findNextLesson(scheduleResult.data);
    }
    if (mounted) {
      setState(() {
        _groupName = groupName;
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
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0, colors),
            _buildDrawerItem(Icons.assignment_rounded, 'Домашние задания', 1, colors),
            _buildDrawerItem(Icons.menu_book_rounded, 'Уроки', 2, colors),
            _buildDrawerItem(Icons.calendar_month_rounded, 'Расписание', 3, colors),
            _buildDrawerItem(Icons.message_rounded, 'Сообщения', 5, colors),
            _buildDrawerItem(Icons.bar_chart_rounded, 'Аналитика', 6, colors),
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
        child: body,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, ColorScheme colors) {
    final selected = _selectedIndex == index;
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
        _onItemTapped(index);
        Navigator.of(context).pop();
      },
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary.withValues(alpha: 0.8), colors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Привет, $firstName!',
                    style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_groupName != null)
                    Text(
                      'Твоя группа: $_groupName',
                      style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), fontSize: 16),
                    )
                  else
                    Text(
                      'Добро пожаловать в EduTrack',
                      style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.9), fontSize: 16),
                    ),
                ],
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
                  _buildQuickActionCard(Icons.assignment, 'Мои задания', () => _onItemTapped(1), colors),
                  _buildQuickActionCard(Icons.calendar_month, 'Расписание', () => _onItemTapped(3), colors),
                  _buildQuickActionCard(Icons.menu_book, 'Уроки', () => _onItemTapped(2), colors),
                  _buildQuickActionCard(Icons.bar_chart_rounded, 'Аналитика', () => _onItemTapped(6), colors),
                  _buildQuickActionCard(Icons.forum, 'Чат группы', () => _openGroupChat(context), colors),
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
                  _buildStatCard(
                    icon: Icons.assignment,
                    title: 'Всего заданий',
                    value: '$_totalHomework',
                    iconColor: colors.primary,
                    bgColor: colors.primaryContainer,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    title: 'Выполнено',
                    value: '$_completedHomework',
                    iconColor: Colors.green,
                    bgColor: Colors.green.withValues(alpha: 0.2),
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.pending_actions,
                    title: 'Осталось',
                    value: '$_pendingHomework',
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.withValues(alpha: 0.2),
                    colors: colors,
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
    required ColorScheme colors,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface)),
                ],
              ),
            ),
          ],
        ),
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

  Future<void> _openGroupChat(BuildContext context) async {
    final navigator = Navigator.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groupResult = await _homeworkService.getGroupByStudentId(userProvider.userId!);
    if (groupResult.isFailure || groupResult.data == null) {
      MessengerHelper.showError('Не удалось получить данные группы');
      return;
    }
    final groupData = groupResult.data!;
    final groupId = groupData['id'] as String;
    final groupName = groupData['name'] as String;
    final chatResult = await ChatService().getOrCreateGroupChat(groupId, groupName);
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
                        Icon(Icons.person_outline, size: 15, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lesson.teacherName,
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
