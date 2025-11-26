import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/models/institution.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/teacher_service.dart';
import 'package:edu_track/data/services/institution_service.dart';
import 'package:edu_track/utils/validators.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
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
  bool _isPasswordVisible = false;

  late final TeacherService _teacherService;
  late final InstitutionService _institutionService;
  Teacher? _teacher;
  Institution? _institution;

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _institutionService = InstitutionService();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    try {
      final teacher = await _teacherService.getTeacherById(userId);
      if (teacher != null) {
        final inst = await _institutionService.getInstitutionById(teacher.institutionId);
        if (mounted) {
          setState(() {
            _teacher = teacher;
            _institution = inst;
            _fillControllers();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillControllers() {
    if (_teacher == null) return;
    _nameController.text = _teacher!.name;
    _surnameController.text = _teacher!.surname;
    _emailController.text = _teacher!.email;
    _loginController.text = _teacher!.login;
  }

  Future<void> _saveChanges() async {
    if (_teacher == null) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updatedData = <String, dynamic>{};
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isNotEmpty && password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пароли не совпадают'), backgroundColor: Colors.redAccent));
      setState(() => _isSaving = false);
      return;
    }

    if (_nameController.text.trim() != _teacher!.name) {
      updatedData['name'] = _nameController.text.trim();
    }
    if (_surnameController.text.trim() != _teacher!.surname) {
      updatedData['surname'] = _surnameController.text.trim();
    }
    if (_emailController.text.trim() != _teacher!.email) {
      updatedData['email'] = _emailController.text.trim();
    }
    if (_loginController.text.trim() != _teacher!.login) {
      updatedData['login'] = _loginController.text.trim();
    }
    if (password.isNotEmpty) {
      updatedData['password'] = password;
    }

    if (updatedData.isEmpty) {
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      return;
    }
    try {
      await _teacherService.updateTeacherData(_teacher!.id, updatedData);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль обновлён'), backgroundColor: Colors.green));
        setState(() {
          _isEditing = false;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
        await _loadTeacherData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetChanges() {
    _fillControllers();
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
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
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
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildAvatar(),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        '${_teacher!.name} ${_teacher!.surname}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        _institution?.name ?? '',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(color: Colors.deepPurple.shade300),
                                      ),
                                    ),
                                    const Divider(height: 32),
                                    _sectionTitle('Данные профиля'),
                                    const SizedBox(height: 8),
                                    _infoRow('Логин', _teacher!.login),
                                    _infoRow('Email', _teacher!.email),
                                    _infoRow('Учреждение', _institution?.name ?? '—'),
                                    const SizedBox(height: 24),
                                    AnimatedCrossFade(
                                      firstChild: _editButton(),
                                      secondChild: _editForm(),
                                      crossFadeState: _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                      duration: const Duration(milliseconds: 300),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = '${_teacher!.name[0]}${_teacher!.surname[0]}';
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.deepPurple.shade200,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple));
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(value))],
      ),
    );
  }

  Widget _editButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit),
        label: const Text('Изменить данные'),
        onPressed: () {
          _resetChanges();
          setState(() => _isEditing = true);
        },
      ),
    );
  }

  Widget _editForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField(
            controller: _nameController,
            label: 'Имя',
            validator: (val) => Validators.validateName(val, 'Имя'),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ\s-]'))],
          ),
          _buildField(
            controller: _surnameController,
            label: 'Фамилия',
            validator: (val) => Validators.validateName(val, 'Фамилия'),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ\s-]'))],
          ),
          _buildField(
            controller: _emailController,
            label: 'Email',
            type: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          _buildField(
            controller: _loginController,
            label: 'Логин',
            validator: (val) => Validators.requiredField(val, fieldName: 'Логин'),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]'))],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return null;
                if (val.length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _passwordController,
            builder: (context, TextEditingValue value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: const InputDecoration(labelText: 'Подтвердите пароль', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val != _passwordController.text) return 'Пароли не совпадают';
                    return null;
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                          : const Text('Сохранить'),
                  onPressed: _isSaving ? null : _saveChanges,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Отменить'),
                  onPressed: _resetChanges,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: type,
        obscureText: obscure,
        validator: validator,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
