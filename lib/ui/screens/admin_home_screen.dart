import 'package:flutter/material.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная — Администратор'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await SessionService.clearSession();
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.clearUser();
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildTile(
              icon: Icons.person_add,
              label: 'Добавить пользователя',
              onTap: () {
                // TODO: переход на экран добавления
              },
            ),
            _buildTile(
              icon: Icons.people,
              label: 'Пользователи',
              onTap: () {
                // TODO: переход на список пользователей
              },
            ),
            _buildTile(
              icon: Icons.schedule,
              label: 'Расписание',
              onTap: () {
                // TODO: переход к расписанию
              },
            ),
            _buildTile(
              icon: Icons.book,
              label: 'Предметы',
              onTap: () {
                // TODO: переход к предметам
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(69, 49, 144, 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color.fromRGBO(69, 49, 144, 1)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
