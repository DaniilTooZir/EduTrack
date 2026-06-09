import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(AppRoutes.welcome);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.3;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(themeProvider.effectiveMode(Theme.of(context).brightness)),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppTheme.getLogoPath(themeProvider.effectiveMode(Theme.of(context).brightness)),
                              width: logoSize.clamp(80, 160),
                              height: logoSize.clamp(80, 160),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'EduTrack',
                              style: TextStyle(
                                fontSize: size.width.clamp(24, 42),
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                                letterSpacing: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              'Инициализация...',
                              style: TextStyle(
                                color: colors.onSurface.withValues(alpha: 0.7),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 30),
                            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colors.primary)),
                          ],
                        ),
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
