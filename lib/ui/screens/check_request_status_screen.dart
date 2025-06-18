import 'package:flutter/material.dart';
import 'package:edu_track/data/services/institution_request_status_service.dart';

class CheckRequestStatusScreen extends StatefulWidget {
  const CheckRequestStatusScreen({super.key});

  @override
  State<CheckRequestStatusScreen> createState() => _CheckRequestStatusScreenState();
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
    final result = await InstitutionRequestStatusService.getRequestDetailsByEmail(email);

    setState(() {
      _isLoading = false;
      if (result == null) {
        _statusMessage = 'Заявка с таким email не найдена.';
        return;
      }

      final status = result['status'] as String;

      if (status == 'pending') {
        _statusMessage = 'Заявка находится на рассмотрении.';
      } else if (status == 'approved') {
        _statusMessage = 'Заявка одобрена!';

        _login = result['login'] as String?;
        _password = result['password'] as String?;
      } else if (status == 'rejected') {
        _statusMessage = 'Заявка отклонена.';
      } else {
        _statusMessage = 'Статус заявки: $status';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка статуса заявки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email руководителя',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkStatus,
              child: const Text('Проверить статус'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_statusMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusMessage!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_login != null && _password != null) ...[
                    const SizedBox(height: 16),
                    Text('Логин: $_login', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Пароль: $_password', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Переход на экран авторизации
                      },
                      child: const Text('Перейти к авторизации'),
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