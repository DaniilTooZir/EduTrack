import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/users_fetch_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) {
      setState(() => _error = 'Не удалось получить ID учреждения');
      return;
    }

    final service = UsersFetchService();
    try {
      final teachers = await service.fetchTeachers(institutionId);
      final students = await service.fetchStudents(institutionId);
      setState(() {
        _teachers = teachers;
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке данных: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Преподаватели', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._teachers.map((t) => _userTile(t, role: 'teacher')),

          const SizedBox(height: 24),
          const Text('Студенты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._students.map((s) => _userTile(s, role: 'student')),
        ],
      ),
    );
  }

  Widget _userTile(Map<String, dynamic> user, {required String role}) {
    final fullName = '${user['surname']} ${user['name']}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(fullName),
        subtitle: Text('${user['email']} • ${user['login']}${role == 'student' ? ' • Номер группы ${user['class_number']}' : ''}'),
        leading: Icon(role == 'teacher' ? Icons.person : Icons.school),
      ),
    );
  }
}