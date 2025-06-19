import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.7;
    final titleStyle = TextStyle(
      fontSize: size.width * 0.08,
      fontWeight: FontWeight.bold,
      color: const Color.fromRGBO(69, 49, 144, 1.0),
    );
    final subtitleStyle = TextStyle(
      fontSize: size.width * 0.045,
      color: Colors.grey[700],
    );

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
                      Text('EduTrack', textAlign: TextAlign.center, style: titleStyle),
                      const SizedBox(height: 16),
                      Text(
                        'Система для образовательных организаций, призванная упростить наблюдение и ведение обучения.',
                        textAlign: TextAlign.center,
                        style: subtitleStyle,
                      ),
                      const SizedBox(height: 48),

                      // Кнопка "Войти"
                      SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Навигация на экран входа
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Войти'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Кнопка "Зарегистрировать ОО"
                      SizedBox(
                        width: buttonWidth,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/institution-request');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text('Зарегистрировать ОО'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Кнопка "Проверить статус заявки"
                      SizedBox(
                        width: buttonWidth,
                        child: TextButton(
                          onPressed: () {
                            context.push('/check-status');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                            foregroundColor: Colors.deepPurple,
                          ),
                          child: const Text('Проверить статус заявки'),
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