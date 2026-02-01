import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = (size.width * 0.75).clamp(240.0, 400.0);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final titleStyle = TextStyle(
      fontSize: size.width.clamp(24.0, 40.0),
      fontWeight: FontWeight.w800,
      color: colors.primary,
    );
    final subtitleStyle = TextStyle(fontSize: size.width.clamp(14.0, 18.0), color: colors.onSurface.withOpacity(0.7));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox.expand(
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
                                AppTheme.getLogoPath(themeProvider.mode),
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
                                    foregroundColor: colors.onPrimary,
                                    backgroundColor: colors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 3,
                                  ),
                                  child: const Text('Войти'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: buttonWidth,
                                child: Divider(thickness: 1, color: colors.outline.withOpacity(0.5)),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: buttonWidth,
                                child: OutlinedButton(
                                  onPressed: () => context.push('/institution-request'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: colors.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Зарегистрировать ОО'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: buttonWidth,
                                child: Divider(thickness: 1, color: colors.outline.withOpacity(0.5)),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: buttonWidth,
                                child: TextButton(
                                  onPressed: () => context.push('/check-status'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.secondary,
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
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: IconButton(
                        onPressed: () => showSettingsSheet(context),
                        icon: Icon(Icons.settings, color: colors.primary),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
