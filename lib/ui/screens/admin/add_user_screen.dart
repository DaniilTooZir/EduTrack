import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/user_add_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedRole;
  List<Group> _groups = [];
  Group? _selectedGroup;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadGroups();
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

  Future<void> _loadGroups() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    try {
      final groups = await _groupService.getGroups(institutionId);
      if (mounted) {
        setState(() {
          _groups = groups;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки групп: $e');
    }
  }

  Future<void> _addUser() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'student' && _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите группу для студента'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final institutionId = userProvider.institutionId;
      if (institutionId == null) throw Exception('Не удалось получить ID учреждения');
      final service = UserAddService();
      final userData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'login': _loginController.text.trim(),
        'password': _passwordController.text.trim(),
        'institution_id': institutionId,
      };
      switch (_selectedRole) {
        case 'student':
          await service.addStudent(userData: userData, groupId: _selectedGroup!.id.toString());
          break;
        case 'teacher':
          await service.addTeacher(userData);
          break;
        case 'schedule_operator':
          await service.addScheduleOperator(userData);
          break;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пользователь успешно добавлен'), backgroundColor: Colors.green));
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _loginController.clear();
    _passwordController.clear();
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    setState(() {
      _selectedRole = null;
      _selectedGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Добавить пользователя',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Имя',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => Validators.validateName(val, 'Имя'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _surnameController,
                                decoration: const InputDecoration(
                                  labelText: 'Фамилия',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) => Validators.validateName(val, 'Фамилия'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _loginController,
                          decoration: const InputDecoration(
                            labelText: 'Логин',
                            prefixIcon: Icon(Icons.account_circle),
                            border: OutlineInputBorder(),
                            helperText: 'Только латинские буквы и цифры',
                          ),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]'))],
                          validator: (val) => Validators.requiredField(val, fieldName: 'Логин'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (val) {
                            final req = Validators.requiredField(val, fieldName: 'Пароль');
                            if (req != null) return req;
                            if (val!.length < 6) return 'Пароль должен быть не менее 6 символов';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Роль',
                            prefixIcon: Icon(Icons.group),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'student', child: Text('Студент')),
                            DropdownMenuItem(value: 'teacher', child: Text('Преподаватель')),
                            DropdownMenuItem(value: 'schedule_operator', child: Text('Оператор расписания')),
                          ],
                          validator: (val) => val == null ? 'Выберите роль' : null,
                          onChanged:
                              (value) => setState(() {
                                _selectedRole = value;
                                _selectedGroup = null;
                              }),
                        ),
                        if (_selectedRole == 'student') ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Group>(
                            value: _selectedGroup,
                            decoration: const InputDecoration(
                              labelText: 'Группа',
                              prefixIcon: Icon(Icons.group_work),
                              border: OutlineInputBorder(),
                            ),
                            items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                            onChanged: (group) => setState(() => _selectedGroup = group),
                            validator: (val) => _selectedRole == 'student' && val == null ? 'Выберите группу' : null,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _addUser,
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 3, color: colors.onPrimary),
                                  )
                                  : const Text(
                                    'Добавить пользователя',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}
