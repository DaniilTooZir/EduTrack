import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_schedule_operator_screen.dart';

class ScheduleOperatorHomeScreen extends StatefulWidget {
  const ScheduleOperatorHomeScreen({super.key});

  @override
  State<ScheduleOperatorHomeScreen> createState() => _ScheduleOperatorHomeScreenState();
}

class _ScheduleOperatorHomeScreenState extends State<ScheduleOperatorHomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Главная', 'Расписание'];

  final Color primaryColor = const Color(0xFF9575CD);
  final Color drawerStart = const Color(0xFF7E57C2);
  final Color drawerEnd = const Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildDashboard();
        break;
      case 1:
        bodyContent = const ScheduleScheduleOperatorScreen();
        break;
      default:
        bodyContent = _buildPlaceholder(_titles[_selectedIndex]);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
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
                  'Меню оператора расписания',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Главная', 0),
            _buildDrawerItem(Icons.schedule, 'Расписание', 1),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Добро пожаловать!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
              ),
              SizedBox(height: 12),
              Text(
                'Вы вошли как оператор расписания. Здесь вы можете управлять расписанием и уроками образовательной организации.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                'Разделы панели:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
              ),
              SizedBox(height: 12),
              Text('• Расписание — создание, редактирование и просмотр расписания занятий.'),
              Text('• Уроки — управление уроками и их параметрами.'),
              Text('• Профиль — информация об учетной записи.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        '$title — экран в разработке',
        style: const TextStyle(fontSize: 18, color: Color(0xFF5E35B1), fontWeight: FontWeight.w500),
      ),
    );
  }
}
