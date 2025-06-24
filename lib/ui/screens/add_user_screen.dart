import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/data/services/user_add_service.dart';
import 'package:edu_track/data/services/group_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedRole;
  List<Group> _groups = [];
  Group? _selectedGroup;

  bool _isLoading = false;
  String? _errorMessage;

  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final institutionId =
        Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;

    final groups = await _groupService.getGroups(institutionId);
    setState(() {
      _groups = groups;
    });
  }

  Future<void> _addUser() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final role = _selectedRole;

    if (login.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        role == null) {
      setState(() => _errorMessage = 'Пожалуйста, заполните все поля');
      return;
    }

    if (role == 'student' && _selectedGroup == null) {
      setState(() => _errorMessage = 'Пожалуйста, выберите группу');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final institutionId = userProvider.institutionId;
      if (institutionId == null) {
        throw Exception('Не удалось получить ID учреждения');
      }
      final service = UserAddService();
      if (role == 'student') {
        if (_selectedGroup == null) {
          setState(() => _errorMessage = 'Пожалуйста, выберите группу');
          return;
        }
        await service.addStudent(
          login: login,
          password: password,
          name: name,
          surname: surname,
          email: email,
          institutionId: institutionId,
          groupId: _selectedGroup!.id.toString(),
        );
      } else if (role == 'teacher') {
        await service.addTeacher(
          login: login,
          password: password,
          name: name,
          surname: surname,
          email: email,
          institutionId: institutionId,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пользователь успешно добавлен')),
      );
      _loginController.clear();
      _passwordController.clear();
      _nameController.clear();
      _surnameController.clear();
      _emailController.clear();
      setState(() {
        _selectedRole = null;
        _selectedGroup = null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(44),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Имя'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _surnameController,
            decoration: const InputDecoration(labelText: 'Фамилия'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _loginController,
            decoration: const InputDecoration(labelText: 'Логин'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Пароль'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            items: const [
              DropdownMenuItem(value: 'student', child: Text('Студент')),
              DropdownMenuItem(value: 'teacher', child: Text('Преподаватель')),
            ],
            onChanged:
                (value) => setState(() {
                  _selectedRole = value;
                  _selectedGroup = null;
                }),
            decoration: const InputDecoration(labelText: 'Роль'),
          ),
          if (_selectedRole == 'student') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<Group>(
              value: _selectedGroup,
              items:
                  _groups
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g.name)),
                      )
                      .toList(),
              onChanged: (group) => setState(() => _selectedGroup = group),
              decoration: const InputDecoration(labelText: 'Группа'),
            ),
          ],
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            style: buttonStyle,
            onPressed: _isLoading ? null : _addUser,
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
                    : const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
