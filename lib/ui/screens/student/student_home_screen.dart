import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/student/student_homework_screen.dart';
import 'package:edu_track/ui/screens/student/student_lesson_screen.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';
import 'package:edu_track/ui/screens/student/student_schedule_screen.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
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
  final HomeworkService _homeworkService = HomeworkService();
  final List<String> _titles = ['Главная', 'Домашние задания', 'Уроки', 'Расписание', 'Профиль'];

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
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
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
      final groupResponse = await _homeworkService.getGroupByStudentId(studentId);
      String? groupName;
      if (groupResponse != null) {
        groupName = groupResponse['name'] as String;
      }
      final homeworks = await _homeworkService.getHomeworksByStudentGroup(studentId);
      final statuses = await _homeworkService.getHomeworkStatusesForStudent(studentId);
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
      if (mounted) {
        setState(() {
          _groupName = groupName;
          _totalHomework = homeworks.length;
          _completedHomework = completed;
          _pendingHomework = pending;
          _isDashboardLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardError = 'Ошибка загрузки данных: $e';
          _isDashboardLoading = false;
        });
      }
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
        body = _buildDashboard(colors);
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
          if (_selectedIndex == 0)
            IconButton(icon: const Icon(Icons.refresh), tooltip: 'Обновить', onPressed: _loadDashboardData),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              if (context.mounted) {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                context.go('/');
              }
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
      selectedTileColor: colors.primaryContainer.withOpacity(0.3),
      onTap: () {
        _onItemTapped(index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
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
                  colors: [colors.primary.withOpacity(0.8), colors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Привет, студент!',
                    style: TextStyle(color: colors.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_groupName != null)
                    Text(
                      'Твоя группа: $_groupName',
                      style: TextStyle(color: colors.onPrimary.withOpacity(0.9), fontSize: 16),
                    )
                  else
                    Text(
                      'Добро пожаловать в EduTrack',
                      style: TextStyle(color: colors.onPrimary.withOpacity(0.9), fontSize: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                    bgColor: Colors.green.withOpacity(0.2),
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.pending_actions,
                    title: 'Осталось',
                    value: '$_pendingHomework',
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.withOpacity(0.2),
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
        decoration: BoxDecoration(color: colors.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
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
}
