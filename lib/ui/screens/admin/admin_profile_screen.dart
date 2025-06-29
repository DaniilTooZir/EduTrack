import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/education_head_service.dart';
import 'package:edu_track/data/services/institution_service.dart';
import 'package:edu_track/models/education_head.dart';
import 'package:edu_track/models/institution.dart';
import 'package:edu_track/providers/user_provider.dart';

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

    final admin = await _headService.getHeadById(userId);
    if (admin != null) {
      final inst = await _institutionService.getInstitutionById(
        admin.institutionId,
      );
      setState(() {
        _admin = admin;
        _institution = inst;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_admin == null) return;
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
    if (_phoneController.text.trim().isNotEmpty) {
      updatedData['phone'] = _phoneController.text.trim();
    }
    if (_loginController.text.trim().isNotEmpty) {
      updatedData['login'] = _loginController.text.trim();
    }
    if (password.isNotEmpty) {
      updatedData['password'] = password;
    }

    try {
      if (updatedData.isNotEmpty) {
        await _headService.updateHeadData(_admin!.id, updatedData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
      }
      setState(() {
        _isEditing = false;
        _loadAdminData();
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
    _phoneController.clear();
    _loginController.clear();
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
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
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: Colors.deepPurple.shade300,
                                      ),
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
                                    crossFadeState:
                                        _isEditing
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
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
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
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
          _buildField(_nameController, 'Имя'),
          _buildField(_surnameController, 'Фамилия'),
          _buildField(_phoneController, 'Телефон', type: TextInputType.phone),
          _buildField(_loginController, 'Логин'),
          _buildField(_passwordController, 'Пароль', obscure: true),
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
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: type,
        obscureText: obscure,
      ),
    );
  }
}
