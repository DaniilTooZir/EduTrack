import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/student/student_homework_screen.dart';
import 'package:edu_track/ui/screens/student/student_lesson_screen.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';
import 'package:edu_track/ui/screens/student/student_schedule_screen.dart';
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

  final Color primaryColor = const Color(0xFF9575CD);
  final Color drawerStart = const Color(0xFF7E57C2);
  final Color drawerEnd = const Color(0xFF5E35B1);

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
        if (mounted)
          setState(() {
            _dashboardError = 'Не удалось получить ID студента';
            _isDashboardLoading = false;
          });
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

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF5E35B1) : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF5E35B1) : null,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: () {
        _onItemTapped(index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
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
                  Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String label, VoidCallback onTap) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
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
                Icon(icon, color: const Color(0xFF5E35B1), size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: primaryColor,
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF512DA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Привет, студент!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_groupName != null)
                    Text('Твоя группа: $_groupName', style: const TextStyle(color: Colors.white70, fontSize: 16))
                  else
                    const Text('Добро пожаловать в EduTrack', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickActionCard(Icons.assignment, 'Мои задания', () => _onItemTapped(1)),
                  _buildQuickActionCard(Icons.calendar_month, 'Расписание', () => _onItemTapped(3)),
                  _buildQuickActionCard(Icons.menu_book, 'Уроки', () => _onItemTapped(2)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Твоя успеваемость',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
            ),
            const SizedBox(height: 12),
            if (_isDashboardLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_dashboardError != null)
              Center(child: Text(_dashboardError!, style: const TextStyle(color: Colors.red)))
            else
              Column(
                children: [
                  _buildStatCard(
                    icon: Icons.assignment,
                    title: 'Всего заданий',
                    value: '$_totalHomework',
                    iconColor: const Color(0xFF5E35B1),
                    bgColor: const Color(0xFFEDE7F6),
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    title: 'Выполнено',
                    value: '$_completedHomework',
                    iconColor: Colors.green,
                    bgColor: Colors.green.shade50,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.pending_actions,
                    title: 'Осталось',
                    value: '$_pendingHomework',
                    iconColor: Colors.orange,
                    bgColor: Colors.orange.shade50,
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const StudentHomeworkScreen();
      case 2:
        return const StudentLessonScreen();
      case 3:
        return const StudentScheduleScreen();
      case 4:
        return const StudentProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDashboard = _selectedIndex == 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(_titles[_selectedIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (isDashboard)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Обновить',
              onPressed: _loadDashboardData,
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
                  colors: [drawerStart, drawerEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Меню студента',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0),
            _buildDrawerItem(Icons.assignment_rounded, 'Домашние задания', 1),
            _buildDrawerItem(Icons.menu_book_rounded, 'Уроки', 2),
            _buildDrawerItem(Icons.calendar_month_rounded, 'Расписание', 3),
            _buildDrawerItem(Icons.person_rounded, 'Профиль', 4),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }
}
