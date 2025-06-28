import 'package:flutter/material.dart';
import 'package:edu_track/data/services/institution_request_service.dart';

class InstitutionRequestScreen extends StatefulWidget {
  const InstitutionRequestScreen({super.key});

  @override
  State<InstitutionRequestScreen> createState() =>
      _InstitutionRequestScreenState();
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
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        comment:
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка успешно отправлена!')),
      );

      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      debugPrint('[InstitutionRequestScreen] Ошибка: $e');
      debugPrint('[InstitutionRequestScreen] StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Произошла ошибка при отправке заявки. Попробуйте позже.',
          ),
          backgroundColor: Colors.redAccent,
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация образовательной организации'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          _nameController,
                          'Название организации',
                          true,
                        ),
                        _buildTextField(
                          _addressController,
                          'Адрес организации',
                          true,
                        ),
                        _buildTextField(
                          _headNameController,
                          'Имя руководителя',
                          true,
                        ),
                        _buildTextField(
                          _headSurnameController,
                          'Фамилия руководителя',
                          true,
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Введите email';
                            final emailReg = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailReg.hasMatch(v))
                              return 'Введите корректный email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _phoneController,
                          'Телефон (необязательно)',
                          false,
                          inputType: TextInputType.phone,
                        ),
                        _buildTextField(
                          _commentController,
                          'Комментарий (необязательно)',
                          false,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitRequest,
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
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
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: inputType,
        maxLines: maxLines,
        validator:
            required
                ? (v) =>
                    v == null || v.isEmpty ? 'Поле "$label" обязательно' : null
                : null,
      ),
    );
  }
}
