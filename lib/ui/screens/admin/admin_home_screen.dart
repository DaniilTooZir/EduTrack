import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/data/services/dashboard_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/admin/user_list_screen.dart';
import 'package:edu_track/ui/screens/admin/schedule_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/subject_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/admin_profile_screen.dart';
import 'package:edu_track/ui/screens/admin/group_admin_screen.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Главная',
    'Пользователи',
    'Добавить пользователя',
    'Расписание',
    'Предметы',
    'Профиль',
    'Группы',
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildDashboard();
        break;
      case 1:
        bodyContent = const UserListScreen();
        break;
      case 2:
        bodyContent = const AddUserScreen();
        break;
      case 3:
        bodyContent = const ScheduleAdminScreen();
        break;
      case 4:
        bodyContent = const SubjectAdminScreen();
        break;
      case 5:
        bodyContent = const AdminProfileScreen();
        break;
      case 6:
        bodyContent = const GroupAdminScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
    }
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
                'Меню администратора',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0),
            _buildDrawerItem(Icons.people, 'Пользователи', 1),
            _buildDrawerItem(Icons.person_add, 'Добавить пользователя', 2),
            _buildDrawerItem(Icons.schedule, 'Расписание', 3),
            _buildDrawerItem(Icons.book, 'Предметы', 4),
            _buildDrawerItem(Icons.person, 'Профиль', 5),
            _buildDrawerItem(Icons.group, 'Группы', 6),
          ],
        ),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: bodyContent),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
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
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDashboard() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final institutionId = userProvider.institutionId;
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(institutionId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка при загрузке статистики: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общая статистика по вашему учреждению',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _statCard('Преподаватели', data['teachers'].toString()),
                _statCard('Студенты', data['students'].toString()),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _fetchStats(String institutionId) async {
    final dashboardService = DashboardService();
    final studentCount = await dashboardService.getStudentCount(institutionId);
    final teacherCount = await dashboardService.getTeacherCount(institutionId);
    return {
      'students': studentCount,
      'teachers': teacherCount,
    };
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(69, 49, 144, 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(69, 49, 144, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
