import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edu_track/data/services/institution_request_status_service.dart';
import 'package:go_router/go_router.dart';

class CheckRequestStatusScreen extends StatefulWidget {
  const CheckRequestStatusScreen({super.key});

  @override
  State<CheckRequestStatusScreen> createState() =>
      _CheckRequestStatusScreenState();
}

class _CheckRequestStatusScreenState extends State<CheckRequestStatusScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _statusMessage;
  String? _login;
  String? _password;
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _login = null;
      _password = null;
    });

    final email = _emailController.text.trim();

    try {
      final result =
          await InstitutionRequestStatusService.getRequestDetailsByEmail(email);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label скопирован в буфер обмена')));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyle = const TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Проверка статуса заявки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email руководителя',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkStatus,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Проверить статус'),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusMessage!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_login != null && _password != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Логин: $_login', style: textStyle),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Копировать логин',
                          onPressed: () => _copyToClipboard(_login!, 'Логин'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Пароль: $_password', style: textStyle),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Копировать пароль',
                          onPressed:
                              () => _copyToClipboard(_password!, 'Пароль'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/login');
                        },
                        child: const Text('Перейти к авторизации'),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
