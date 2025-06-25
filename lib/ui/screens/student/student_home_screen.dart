import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';
import 'package:edu_track/ui/screens/student/student_homework_screen.dart';

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

  final List<String> _titles = [
    'Главная',
    'Домашние задания',
    'Расписание',
    'Профиль',
  ];

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
      final groupResponse = await _homeworkService.getGroupByStudentId(
        studentId,
      );
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
      final statuses = await _homeworkService.getHomeworkStatusesForStudent(
        studentId,
      );
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

  Widget _buildDashboard() {
    if (_isDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dashboardError != null) {
      return Center(child: Text(_dashboardError!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Привет, студент!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_groupName != null)
          Text(
            'Ваша группа: $_groupName',
            style: const TextStyle(fontSize: 18),
          ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.assignment, size: 40),
            title: const Text('Всего домашних заданий'),
            trailing: Text('$_totalHomework'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.check_circle,
              size: 40,
              color: Colors.green,
            ),
            title: const Text('Выполнено'),
            trailing: Text('$_completedHomework'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.radio_button_unchecked,
              size: 40,
              color: Colors.red,
            ),
            title: const Text('Осталось выполнить'),
            trailing: Text('$_pendingHomework'),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const StudentHomeworkScreen();
      case 2:
        return const Center(child: Text('Расписание (в разработке)'));
      case 3:
        return const StudentProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? const Color.fromRGBO(69, 49, 144, 1) : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? const Color.fromRGBO(69, 49, 144, 1) : null,
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(69, 49, 144, 1)),
              child: Text(
                'Меню студента',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0),
            _buildDrawerItem(Icons.assignment, 'Домашние задания', 1),
            _buildDrawerItem(Icons.schedule, 'Расписание', 2),
            _buildDrawerItem(Icons.person, 'Профиль', 3),
          ],
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _buildBody()),
    );
  }
}
