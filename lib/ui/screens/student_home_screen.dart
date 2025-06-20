import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель студента'),
      ),
      body: const Center(
        child: Text(
          'Добро пожаловать, студент!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}