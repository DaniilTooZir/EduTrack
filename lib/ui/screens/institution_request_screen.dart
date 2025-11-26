import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edu_track/data/services/institution_request_service.dart';
import 'package:edu_track/utils/validators.dart';

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
    FocusScope.of(context).unfocus();
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заявка успешно отправлена!')));

      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      debugPrint('[InstitutionRequestScreen] Ошибка: $e');
      debugPrint('[InstitutionRequestScreen] StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Произошла ошибка при отправке заявки. Попробуйте позже.'),
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
    final size = MediaQuery.of(context).size;
    final maxWidth = (size.width * 0.85).clamp(320.0, 600.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация организации'),
        backgroundColor: const Color(0xFFBC9BF3),
        elevation: 4,
      ),
      body: Container(
        height: double.infinity,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Заполните информацию об организации',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5E35B1)),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Название организации',
                            icon: Icons.business,
                            validator: Validators.validateOrganizationName,
                            maxLength: 100,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s"\-.,№\(\)«»]')),
                            ],
                          ),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Адрес организации',
                            icon: Icons.location_on,
                            validator: Validators.validateAddress,
                            maxLines: 2,
                            maxLength: 200,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s,\-\.\/\(\)]')),
                            ],
                          ),
                          _buildTextField(
                            controller: _headNameController,
                            label: 'Имя руководителя',
                            icon: Icons.person,
                            validator: (val) => Validators.validateName(val, 'Имя'),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ\s-]'))],
                          ),
                          _buildTextField(
                            controller: _headSurnameController,
                            label: 'Фамилия руководителя',
                            icon: Icons.person_outline,
                            validator: (val) => Validators.validateName(val, 'Фамилия'),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ\s-]'))],
                          ),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            inputType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Телефон',
                            icon: Icons.phone,
                            inputType: TextInputType.phone,
                            validator: Validators.validatePhone,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\s\(\)]'))],
                          ),
                          _buildTextField(
                            controller: _commentController,
                            label: 'Комментарий (необязательно)',
                            icon: Icons.comment,
                            maxLines: 3,
                            maxLength: 300,
                            validator: (val) => Validators.validateLength(val, max: 300),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _submitRequest,
                              icon:
                                  _isSubmitting
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                      : const Icon(Icons.send),
                              label: const Text('Отправить заявку'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5E35B1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF5E35B1)) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          counterText: "",
        ),
      ),
    );
  }
}
