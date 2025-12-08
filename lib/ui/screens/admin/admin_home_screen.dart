import 'package:edu_track/data/services/dashboard_service.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/admin/admin_profile_screen.dart';
import 'package:edu_track/ui/screens/admin/group_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/subject_admin_screen.dart';
import 'package:edu_track/ui/screens/admin/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = ['Главная', 'Пользователи', 'Добавить пользователя', 'Предметы', 'Группы', 'Профиль'];
  Key _refreshKey = UniqueKey();

  void _refreshDashboard() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        elevation: 0,
        title: Text(
          _selectedIndex < _titles.length ? _titles[_selectedIndex] : '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Обновить данные',
              onPressed: _refreshDashboard,
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              userProvider.clearUser();
              if (context.mounted) context.go('/');
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
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard_rounded, 'Главная', 0),
            _buildDrawerItem(Icons.people_alt_rounded, 'Пользователи', 1),
            _buildDrawerItem(Icons.person_add_alt_1_rounded, 'Добавить пользователя', 2),
            _buildDrawerItem(Icons.menu_book_rounded, 'Предметы', 3),
            _buildDrawerItem(Icons.groups_rounded, 'Группы', 4),
            _buildDrawerItem(Icons.person_rounded, 'Профиль', 5),
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
        child: bodyContent,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF5E35B1) : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? const Color(0xFF5E35B1) : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: const Color(0xFF5E35B1).withOpacity(0.1),
      onTap: () {
        _navigateToTab(index);
        Navigator.of(context).pop();
      },
    );
  }

  Future<Map<String, int>> _fetchStats(String institutionId) async {
    final dashboardService = DashboardService();
    await Future.delayed(const Duration(milliseconds: 500));
    final studentCount = await dashboardService.getStudentCount(institutionId);
    final teacherCount = await dashboardService.getTeacherCount(institutionId);
    final groupCount = await dashboardService.getGroupCount(institutionId);
    final subjectCount = await dashboardService.getSubjectCount(institutionId);
    return {'students': studentCount, 'teachers': teacherCount, 'groups': groupCount, 'subjects': subjectCount};
  }

  Widget _buildDashboard() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final institutionId = userProvider.institutionId;
    if (institutionId == null) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: () async {
        _refreshDashboard();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: const Color(0xFF9575CD),
      child: FutureBuilder<Map<String, int>>(
        key: _refreshKey,
        future: _fetchStats(institutionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка при загрузке: ${snapshot.error}'));
          }
          final data = snapshot.data ?? {'students': 0, 'teachers': 0, 'groups': 0, 'subjects': 0};
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
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
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Панель администратора',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Управляйте пользователями, группами и учебным процессом в одном месте.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Статистика учреждения',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _statCard('Преподаватели', data['teachers'].toString(), Icons.school, Colors.orange),
                            _statCard('Студенты', data['students'].toString(), Icons.people, Colors.blue),
                            _statCard('Группы', data['groups'].toString(), Icons.groups, Colors.green),
                            _statCard('Предметы', data['subjects'].toString(), Icons.menu_book, Colors.purple),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Быстрые действия',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _quickActionButton('Добавить\nпользователя', Icons.person_add, 2),
                          _quickActionButton('Создать\nгруппу', Icons.group_add, 4),
                          _quickActionButton('Назначить\nпредмет', Icons.book, 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _quickActionButton(String label, IconData icon, int pageIndex) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToTab(pageIndex),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: const Color(0xFF5E35B1)),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}
