import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';
import 'package:edu_track/ui/screens/student/student_homework_screen.dart';
import 'package:edu_track/ui/screens/student/student_schedule_screen.dart';
import 'package:edu_track/ui/screens/student/student_lesson_screen.dart';

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
    setState(() {
      _isDashboardLoading = true;
      _dashboardError = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final studentId = userProvider.userId;
      if (studentId == null) {
        setState(() {
          _dashboardError = 'Не удалось получить ID студента';
          _isDashboardLoading = false;
        });
        return;
      }
      final groupResponse = await _homeworkService.getGroupByStudentId(studentId);
      if (groupResponse == null) {
        setState(() {
          _dashboardError = 'Не удалось получить группу студента';
          _isDashboardLoading = false;
        });
        return;
      }
      final groupId = groupResponse['id'] as String;
      final groupName = groupResponse['name'] as String;
      final homeworks = await _homeworkService.getHomeworksByStudentGroup(studentId);
      final statuses = await _homeworkService.getHomeworkStatusesForStudent(studentId);
      final statusMap = {for (var s in statuses) s.homeworkId: s};
      int completed = 0;
      int pending = 0;
      for (var hw in homeworks) {
        final status = statusMap[hw.id];
        if (status != null && status.isCompleted) {
          completed++;
        } else {
          pending++;
        }
      }

      setState(() {
        _groupName = groupName;
        _totalHomework = homeworks.length;
        _completedHomework = completed;
        _pendingHomework = pending;
        _isDashboardLoading = false;
      });
    } catch (e) {
      setState(() {
        _dashboardError = 'Ошибка загрузки данных: $e';
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

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    if (_isDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dashboardError != null) {
      return Center(
        child: Text(
          _dashboardError!,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Привет, студент!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 12),
              if (_groupName != null) Text('Ваша группа: $_groupName', style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.assignment, size: 40, color: Color(0xFF5E35B1)),
                  title: const Text('Всего домашних заданий'),
                  trailing: Text('$_totalHomework', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, size: 40, color: Colors.green),
                  title: const Text('Выполнено'),
                  trailing: Text(
                    '$_completedHomework',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.radio_button_unchecked, size: 40, color: Colors.red),
                  title: const Text('Осталось выполнить'),
                  trailing: Text(
                    '$_pendingHomework',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        title: Text(_titles[_selectedIndex], style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              userProvider.clearUser();
              context.go('/');
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
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0),
            _buildDrawerItem(Icons.assignment, 'Домашние задания', 1),
            _buildDrawerItem(Icons.school, 'Уроки', 2),
            _buildDrawerItem(Icons.schedule, 'Расписание', 3),
            _buildDrawerItem(Icons.person, 'Профиль', 4),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(16.0), child: _buildBody()),
      ),
    );
  }
}
