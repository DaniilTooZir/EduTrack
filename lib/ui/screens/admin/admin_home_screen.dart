import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/data/services/dashboard_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/admin/user_list_screen.dart';
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

  final List<String> _titles = ['Главная', 'Пользователи', 'Добавить пользователя', 'Предметы', 'Профиль', 'Группы'];

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
        bodyContent = const SubjectAdminScreen();
        break;
      case 4:
        bodyContent = const GroupAdminScreen();
        break;
      case 5:
        bodyContent = const AdminProfileScreen();
        break;
      default:
        bodyContent = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9575CD),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Меню администратора',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0),
            _buildDrawerItem(Icons.people, 'Пользователи', 1),
            _buildDrawerItem(Icons.person_add, 'Добавить пользователя', 2),
            _buildDrawerItem(Icons.book, 'Предметы', 3),
            _buildDrawerItem(Icons.group, 'Группы', 4),
            _buildDrawerItem(Icons.person, 'Профиль', 5),
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
        child: Padding(padding: const EdgeInsets.all(16.0), child: bodyContent),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
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
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Общая статистика по вашему учреждению',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _statCard('Преподаватели', data['teachers'].toString()),
                      _statCard('Студенты', data['students'].toString()),
                      _statCard('Группы', data['groups'].toString()),
                      _statCard('Предметы', data['subjects'].toString()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Быстрые действия',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _quickActionButton('Добавить пользователя', Icons.person_add, 2),
                      _quickActionButton('Создать группу', Icons.group_add, 6),
                      _quickActionButton('Назначить предмет', Icons.book, 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, int>> _fetchStats(String institutionId) async {
    final dashboardService = DashboardService();
    final studentCount = await dashboardService.getStudentCount(institutionId);
    final teacherCount = await dashboardService.getTeacherCount(institutionId);
    final groupCount = await dashboardService.getGroupCount(institutionId);
    final subjectCount = await dashboardService.getSubjectCount(institutionId);
    return {'students': studentCount, 'teachers': teacherCount, 'groups': groupCount, 'subjects': subjectCount};
  }

  Widget _quickActionButton(String label, IconData icon, int pageIndex) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() => _selectedIndex = pageIndex);
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9575CD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1))),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
