import 'package:edu_track/data/services/education_head_service.dart';
import 'package:edu_track/data/services/institution_service.dart';
import 'package:edu_track/models/education_head.dart';
import 'package:edu_track/models/institution.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isPasswordVisible = false;

  late final EducationHeadService _headService;
  late final InstitutionService _institutionService;
  EducationHead? _admin;
  Institution? _institution;

  @override
  void initState() {
    super.initState();
    _headService = EducationHeadService();
    _institutionService = InstitutionService();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    try {
      final admin = await _headService.getHeadById(userId);
      if (admin != null) {
        final inst = await _institutionService.getInstitutionById(admin.institutionId);
        if (mounted) {
          setState(() {
            _admin = admin;
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
    if (_admin == null) return;
    _nameController.text = _admin!.name;
    _surnameController.text = _admin!.surname;
    _phoneController.text = _admin!.phone;
    _loginController.text = _admin!.login;
  }

  Future<void> _saveChanges() async {
    if (_admin == null) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final updatedData = <String, dynamic>{};
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (password.isNotEmpty && password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пароли не совпадают')));
      setState(() => _isSaving = false);
      return;
    }

    if (_nameController.text.trim() != _admin!.name) {
      updatedData['name'] = _nameController.text.trim();
    }
    if (_surnameController.text.trim() != _admin!.surname) {
      updatedData['surname'] = _surnameController.text.trim();
    }
    if (_phoneController.text.trim() != _admin!.phone) {
      updatedData['phone'] = _phoneController.text.trim();
    }
    if (_loginController.text.trim() != _admin!.login) {
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
      await _headService.updateHeadData(_admin!.id, updatedData);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль обновлён'), backgroundColor: Colors.green));
        setState(() {
          _isEditing = false;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
        await _loadAdminData();
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
    _phoneController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                          constraints: const BoxConstraints(maxWidth: 600),
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
                                      '${_admin!.name} ${_admin!.surname}',
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
                                  _infoRow('Телефон', _admin!.phone),
                                  _infoRow('Логин', _admin!.login),
                                  _infoRow('Email', _admin!.email),
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
    );
  }

  Widget _buildAvatar() {
    final initials = '${_admin!.name[0]}${_admin!.surname[0]}';
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
          _fillControllers();
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
          ),
          _buildField(
            controller: _surnameController,
            label: 'Фамилия',
            validator: (val) => Validators.validateName(val, 'Фамилия'),
          ),
          _buildField(
            controller: _phoneController,
            label: 'Телефон',
            type: TextInputType.phone,
            validator: Validators.validatePhone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\(\)\s]'))],
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
