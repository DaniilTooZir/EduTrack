import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/users_fetch_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _allTeachers = [];
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedRole = 'all';

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
        _allTeachers = teachers;
        _allStudents = students;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке данных: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> combined = [];
    if (_selectedRole == 'teacher' || _selectedRole == 'all') {
      combined += _allTeachers.map((t) => {...t, 'role': 'teacher'}).toList();
    }
    if (_selectedRole == 'student' || _selectedRole == 'all') {
      combined += _allStudents.map((s) => {...s, 'role': 'student'}).toList();
    }
    if (_searchQuery.isNotEmpty) {
      combined =
          combined.where((user) {
            final query = _searchQuery.toLowerCase();
            return user['name'].toLowerCase().contains(query) ||
                user['surname'].toLowerCase().contains(query) ||
                user['email'].toLowerCase().contains(query) ||
                user['login'].toLowerCase().contains(query);
          }).toList();
    }
    setState(() {
      _filteredUsers = combined;
    });
  }

  Future<void> _deleteUser(String id, String role) async {
    final service = UsersFetchService();
    try {
      await service.deleteUserById(id, role);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пользователь удалён')));
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при удалении: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilters(),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      _filteredUsers.isEmpty
                          ? const Center(child: Text('Пользователи не найдены'))
                          : ListView.separated(
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Поиск пользователей',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterChip('Все', 'all'),
                const SizedBox(width: 10),
                _filterChip('Преподаватели', 'teacher'),
                const SizedBox(width: 10),
                _filterChip('Студенты', 'student'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _selectedRole == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFF9575CD),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _selectedRole = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final fullName = '${user['surname']} ${user['name']}';
    final role = user['role'] as String;
    final isTeacher = role == 'teacher';
    final subtitle =
        isTeacher
            ? '${user['email']} • ${user['login']}'
            : '${user['email']} • ${user['login']} • Группа ${user['group_name']}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTeacher ? const Color(0xFF9575CD) : const Color(0xFF673AB7),
          child: Icon(isTeacher ? Icons.person : Icons.school, color: Colors.white),
        ),
        title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          tooltip: 'Удалить пользователя',
          onPressed: () => _confirmDelete(user),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    final fullName = '${user['surname']} ${user['name']}';
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удаление пользователя'),
            content: Text('Вы уверены, что хотите удалить $fullName?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteUser(user['id'], user['role']);
                },
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
