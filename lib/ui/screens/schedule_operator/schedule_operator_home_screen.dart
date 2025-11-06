import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_track/providers/user_provider.dart';

class ScheduleOperatorHomeScreen extends StatelessWidget {
  const ScheduleOperatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель оператора расписания'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти из аккаунта',
            onPressed: () {
              userProvider.clearUser();
              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Добро пожаловать, оператор расписания!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}