import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = (size.width * 0.75).clamp(240.0, 400.0);
    final titleStyle = TextStyle(
      fontSize: size.width.clamp(24.0, 40.0),
      fontWeight: FontWeight.w800,
      color: const Color(0xFF453190),
    );
    final subtitleStyle = TextStyle(fontSize: size.width.clamp(14.0, 18.0), color: Colors.black.withOpacity(0.7));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox.expand(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          Image.asset(
                            'assets/images/logo.png',
                            width: size.width * 0.5,
                            height: size.height * 0.22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          Text('EduTrack', textAlign: TextAlign.center, style: titleStyle),
                          const SizedBox(height: 12),
                          Text(
                            'Цифровая платформа для образовательных учреждений.\nУчёт, контроль, обучение — в одном месте.',
                            textAlign: TextAlign.center,
                            style: subtitleStyle,
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: buttonWidth,
                            child: ElevatedButton(
                              onPressed: () => context.push('/login'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF5E35B1),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 3,
                              ),
                              child: const Text('Войти'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(width: buttonWidth, child: const Divider(thickness: 1, color: Colors.white60)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: buttonWidth,
                            child: OutlinedButton(
                              onPressed: () => context.push('/institution-request'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5E35B1),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF5E35B1), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Зарегистрировать ОО'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(width: buttonWidth, child: const Divider(thickness: 1, color: Colors.white60)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: buttonWidth,
                            child: TextButton(
                              onPressed: () => context.push('/check-status'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF7E57C2),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              child: const Text('Проверить статус заявки'),
                            ),
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
