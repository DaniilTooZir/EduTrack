import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edu_track/data/services/institution_request_status_service.dart';
import 'package:go_router/go_router.dart';

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
            default:
              _statusMessage = 'Статус заявки: $status';
          }
        }
      });
    } catch (e) {
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
        backgroundColor: const Color(0xFF5E35B1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = (size.width * 0.85).clamp(320.0, 600.0);
    final textStyle = const TextStyle(fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Проверка статуса заявки'),
        backgroundColor: const Color(0xFFBC9BF3),
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                          const Text(
                            'Введите email руководителя для проверки статуса заявки',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email руководителя',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF5E35B1)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите email';
                              }
                              final emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailReg.hasMatch(value)) {
                                return 'Введите корректный email';
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                    )
                                    : const Icon(Icons.search, color: Colors.white70),
                            label: const Text(
                              'Проверить статус',
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                            onPressed: _isLoading ? null : _checkStatus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E35B1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (_statusMessage != null)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildStatusResult(textStyle),
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

  Widget _buildStatusResult(TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: ValueKey(_statusMessage),
      children: [
        Text(
          _statusMessage!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A148C)),
        ),
        if (_login != null && _password != null) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: SelectableText('Логин: $_login', style: textStyle)),
              IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF5E35B1)),
                tooltip: 'Копировать логин',
                onPressed: () => _copyToClipboard(_login!, 'Логин'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: SelectableText('Пароль: $_password', style: textStyle)),
              IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF5E35B1)),
                tooltip: 'Копировать пароль',
                onPressed: () => _copyToClipboard(_password!, 'Пароль'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Перейти к авторизации', style: TextStyle(fontSize: 16, color: Colors.white70)),
          ),
        ],
      ],
    );
  }
}
