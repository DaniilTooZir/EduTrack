import 'package:edu_track/data/services/auth_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final authResult = await AuthService.login(login, password);
      if (!mounted) return;
      if (authResult == null) {
        setState(() => _errorMessage = 'Неверный логин или пароль.');
      } else {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(authResult.userId, authResult.role, authResult.institutionId, authResult.groupId);

        switch (authResult.role) {
          case 'admin':
            context.go('/admin-home');
            break;
          case 'teacher':
            context.go('/teacher-home');
            break;
          case 'student':
            context.go('/student-home');
            break;
          case 'schedule_operator':
            context.go('/schedule-operator-home');
            break;
          default:
            context.go('/');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Ошибка при авторизации. Проверьте соединение.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = (size.width * 0.85).clamp(300.0, 450.0);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.primary),
                  onPressed: () => context.go('/'),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () => showSettingsSheet(context),
                    icon: Icon(Icons.settings, color: colors.primary),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, size: 48, color: colors.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Вход в систему',
                                style: TextStyle(
                                  fontSize: size.width.clamp(20.0, 28.0),
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _loginController,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                                decoration: const InputDecoration(
                                  labelText: 'Логин',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Введите логин';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Введите пароль';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                  child:
                                      _isLoading
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                                          )
                                          : const Text('Войти'),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(color: colors.error, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
