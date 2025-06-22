import 'package:flutter/material.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Добавить пользователя',
    'Пользователи',
    'Расписание',
    'Предметы',
  ];

  final List<IconData> _icons = [
    Icons.person_add,
    Icons.people,
    Icons.schedule,
    Icons.book,
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Center(child: Text('Экран добавления пользователя'));
      case 1:
        return Center(child: Text('Список пользователей'));
      case 2:
        return Center(child: Text('Расписание'));
      case 3:
        return Center(child: Text('Предметы'));
      default:
        return Center(child: Text('Неизвестный раздел'));
    }
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Главная — Администратор: ${_titles[_selectedIndex]}'),
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
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'Меню Администратора',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _titles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(_icons[index], color: index == _selectedIndex ? Theme.of(context).primaryColor : null),
                      title: Text(_titles[index]),
                      selected: index == _selectedIndex,
                      onTap: () => _onItemTap(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }
}
