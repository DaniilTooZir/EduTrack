import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/education_head_service.dart';
import 'package:edu_track/models/education_head.dart';
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

  bool _isLoading = true;
  bool _isSaving = false;
  late final EducationHeadService _service;
  EducationHead? _admin;

  @override
  void initState() {
    super.initState();
    _service = EducationHeadService();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    final admin = await _service.getHeadById(userId);
    if (admin != null) {
      setState(() {
        _admin = admin;
        _nameController.text = admin.name;
        _surnameController.text = admin.surname;
        _phoneController.text = admin.phone;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _admin == null) return;
    setState(() => _isSaving = true);
    final updatedData = {
      'name': _nameController.text.trim(),
      'surname': _surnameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    try {
      await _service.updateHeadData(_admin!.id, updatedData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при обновлении: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль администратора')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Имя'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите имя'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(labelText: 'Фамилия'),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите фамилию'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Введите телефон'
                                    : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        child:
                            _isSaving
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Сохранить изменения'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
