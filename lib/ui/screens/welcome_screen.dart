import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип или название
              Text(
                'EduTrack',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              // Слоган
              Text(
                'Следи за прогрессом. Управляй обучением.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 48),
              // Кнопки
              ElevatedButton(
                onPressed: () {
                  // Навигация на экран входа
                },
                child: const Text('Войти'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Навигация на экран регистрации (если понадобится)
                },
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}