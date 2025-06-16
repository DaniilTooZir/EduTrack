import 'package:flutter/material.dart';
import 'package:edu_track/data/services/institution_request_service.dart';

class InstitutionRequestScreen extends StatefulWidget {
  const InstitutionRequestScreen({super.key});

  @override
  State<InstitutionRequestScreen> createState() => _InstitutionRequestScreenState();
}

class _InstitutionRequestScreenState extends State<InstitutionRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _headNameController = TextEditingController();
  final _headSurnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await InstitutionRequestService().submitInstitutionRequest(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        headName: _headNameController.text.trim(),
        headSurname: _headSurnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка успешно отправлена!')),
      );
      Navigator.of(context).pop(); // Возврат назад после успешной отправки

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке заявки: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _headNameController.dispose();
    _headSurnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация образовательной организации')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название организации'),
                  validator: (v) => v == null || v.isEmpty ? 'Введите название организации' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Адрес организации'),
                  validator: (v) => v == null || v.isEmpty ? 'Введите адрес организации' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _headNameController,
                  decoration: const InputDecoration(labelText: 'Имя руководителя'),
                  validator: (v) => v == null || v.isEmpty ? 'Введите имя руководителя' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _headSurnameController,
                  decoration: const InputDecoration(labelText: 'Фамилия руководителя'),
                  validator: (v) => v == null || v.isEmpty ? 'Введите фамилию руководителя' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите email';
                    final emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailReg.hasMatch(v)) return 'Введите корректный email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон (необязательно)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Комментарий (необязательно)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Отправить заявку'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}