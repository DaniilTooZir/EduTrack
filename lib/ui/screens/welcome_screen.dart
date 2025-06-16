import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Text(
                        'EduTrack',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(69, 49, 144, 1.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Система для образовательных организаций, призванная упростить наблюдение и ведение обучения.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: size.width * 0.6,
                        child: ElevatedButton(
                          onPressed: () {
                            // Навигация на экран входа
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          child: const Text('Войти'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: size.width * 0.6,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/institution-request');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          child: const Text('Зарегистрировать ОО'),
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}