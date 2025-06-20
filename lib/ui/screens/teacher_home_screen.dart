import 'package:flutter/material.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель преподавателя'),
      ),
      body: const Center(
        child: Text(
          'Добро пожаловать, преподаватель!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}