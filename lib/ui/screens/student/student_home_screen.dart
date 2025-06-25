import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/student/student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Главная',
    'Домашние задания',
    'Расписание',
    'Профиль',
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
        bodyContent = const Center(
          child: Text('Домашние задания (в разработке)'),
        );
        break;
      case 2:
        bodyContent = const Center(child: Text('Расписание (в разработке)'));
        break;
      case 3:
        bodyContent = const StudentProfileScreen();
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
      body: Padding(padding: const EdgeInsets.all(16.0), child: bodyContent),
    );
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
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Привет, студент!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Здесь ты можешь просматривать свои домашние задания, расписание и управлять своим профилем.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
