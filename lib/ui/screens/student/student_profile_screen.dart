import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/institution.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/data/services/institution_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  late final StudentService _studentService;
  late final InstitutionService _institutionService;
  Student? _student;
  Institution? _institution;

  @override
  void initState() {
    super.initState();
    _studentService = StudentService();
    _institutionService = InstitutionService();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    final student = await _studentService.getStudentById(userId);
    if (student != null) {
      final inst = await _institutionService.getInstitutionById(
        student.institutionId,
      );
      setState(() {
        _student = student;
        _institution = inst;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_student == null) return;
    setState(() => _isSaving = true);
    final updatedData = <String, dynamic>{};
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (password.isNotEmpty && password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пароли не совпадают')));
      setState(() => _isSaving = false);
      return;
    }
    if (_nameController.text.trim().isNotEmpty) {
      updatedData['name'] = _nameController.text.trim();
    }
    if (_surnameController.text.trim().isNotEmpty) {
      updatedData['surname'] = _surnameController.text.trim();
    }
    if (_emailController.text.trim().isNotEmpty) {
      updatedData['email'] = _emailController.text.trim();
    }
    if (_loginController.text.trim().isNotEmpty) {
      updatedData['login'] = _loginController.text.trim();
    }
    if (_passwordController.text.trim().isNotEmpty) {
      updatedData['password'] = _passwordController.text.trim();
    }
    try {
      if (updatedData.isNotEmpty) {
        await _studentService.updateStudentData(_student!.id, updatedData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
      }
      setState(() {
        _isEditing = false;
        _loadStudentData();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при обновлении: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetChanges() {
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    _loginController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _isEditing = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль студента')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Имя', _student!.name),
                              _infoRow('Фамилия', _student!.surname),
                              _infoRow('Email', _student!.email),
                              _infoRow('Логин', _student!.login),
                              _infoRow('Учреждение', _institution?.name ?? '—'),
                              const SizedBox(height: 24),
                              if (_isEditing)
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildField(_nameController, 'Имя'),
                                      _buildField(
                                        _surnameController,
                                        'Фамилия',
                                      ),
                                      _buildField(
                                        _emailController,
                                        'Email',
                                        type: TextInputType.emailAddress,
                                      ),
                                      _buildField(_loginController, 'Логин'),
                                      _buildField(
                                        _passwordController,
                                        'Пароль',
                                        obscure: true,
                                      ),
                                      if (_passwordController.text.isNotEmpty)
                                        _buildField(
                                          _confirmPasswordController,
                                          'Подтвердите пароль',
                                          obscure: true,
                                        ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                                  _isSaving
                                                      ? null
                                                      : _saveChanges,
                                              child:
                                                  _isSaving
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                      : const Text('Сохранить'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _resetChanges,
                                              child: const Text('Сбросить'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _resetChanges();
                                      setState(() => _isEditing = true);
                                    },
                                    child: const Text('Изменить данные'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: type,
        obscureText: obscure,
        validator: (val) {
          if (label == 'Email' && (val == null || val.isEmpty)) {
            return 'Введите email';
          }
          if (label == 'Пароль' &&
              val != null &&
              val.isNotEmpty &&
              val.length < 6) {
            return 'Пароль должен быть не менее 6 символов';
          }
          return null;
        },
      ),
    );
  }
}
