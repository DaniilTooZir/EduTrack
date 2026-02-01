import 'package:edu_track/data/services/institution_request_status_service.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CheckRequestStatusScreen extends StatefulWidget {
  const CheckRequestStatusScreen({super.key});

  @override
  State<CheckRequestStatusScreen> createState() => _CheckRequestStatusScreenState();
}

class _CheckRequestStatusScreenState extends State<CheckRequestStatusScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _statusMessage;
  String? _login;
  String? _password;
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _login = null;
      _password = null;
    });

    final email = _emailController.text.trim();
    try {
      final result = await InstitutionRequestStatusService.getRequestDetailsByEmail(email);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result == null) {
          _statusMessage = 'Заявка с таким email не найдена.';
        } else {
          final status = result['status'] as String;
          switch (status) {
            case 'pending':
              _statusMessage = 'Заявка находится на рассмотрении.';
              break;
            case 'approved':
              _statusMessage = 'Заявка одобрена!';
              _login = result['login'] as String?;
              _password = result['password'] as String?;
              break;
            case 'rejected':
              _statusMessage = 'Заявка отклонена.';
              break;
            case 'failed':
              _statusMessage = 'Произошла техническая ошибка при обработке.';
              break;
            default:
              _statusMessage = 'Статус заявки: $status';
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ошибка при проверке: $e';
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label скопирован в буфер обмена'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = (size.width * 0.85).clamp(320.0, 600.0);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка статуса заявки'), elevation: 4),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Введите email руководителя для проверки статуса',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                            decoration: InputDecoration(
                              labelText: 'Email руководителя',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
                              suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _emailController.clear),
                            ),
                            validator: Validators.validateEmail,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon:
                                _isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                                    )
                                    : const Icon(Icons.search),
                            label: const Text('Проверить статус', style: TextStyle(fontSize: 16)),
                            onPressed: _isLoading ? null : _checkStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_statusMessage != null)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildStatusResult(colors),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusResult(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: ValueKey(_statusMessage),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusMessage!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
        if (_login != null && _password != null) ...[
          const SizedBox(height: 20),
          _buildCopyRow('Логин', _login!, Icons.person, colors),
          const SizedBox(height: 8),
          _buildCopyRow('Пароль', _password!, Icons.lock, colors),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Перейти к авторизации', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCopyRow(String label, String value, IconData icon, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: value,
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: colors.primary),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.copy, color: colors.primary),
          tooltip: 'Копировать $label',
          onPressed: () => _copyToClipboard(value, label),
        ),
      ],
    );
  }
}
