import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/users_fetch_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _allTeachers = [];
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _allOperators = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Group> _groups = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'all';
  bool _sortAsc = true;
  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) {
      MessengerHelper.showError('Не удалось получить ID учреждения');
      return;
    }
    setState(() => _isLoading = true);
    final service = UsersFetchService();

    final results = await Future.wait([
      service.fetchTeachers(institutionId),
      service.fetchStudents(institutionId),
      service.fetchScheduleOperators(institutionId),
      _groupService.getGroups(institutionId),
    ]);

    for (final result in results) {
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _allTeachers = results[0].data as List<Map<String, dynamic>>;
      _allStudents = results[1].data as List<Map<String, dynamic>>;
      _allOperators = results[2].data as List<Map<String, dynamic>>;
      _groups = results[3].data as List<Group>;
      _filteredUsers = _computeFiltered();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _computeFiltered() {
    List<Map<String, dynamic>> combined = [];
    if (_selectedRole == 'teacher' || _selectedRole == 'all') {
      combined += _allTeachers.map((t) => {...t, 'role': 'teacher'}).toList();
    }
    if (_selectedRole == 'schedule_operator' || _selectedRole == 'all') {
      combined += _allOperators.map((o) => {...o, 'role': 'schedule_operator'}).toList();
    }
    if (_selectedRole == 'student' || _selectedRole == 'all') {
      combined += _allStudents.map((s) => {...s, 'role': 'student'}).toList();
    }
    if (_searchQuery.isNotEmpty) {
      combined =
          combined.where((user) {
            final query = _searchQuery.toLowerCase();
            return (user['name']?.toLowerCase().contains(query) ?? false) ||
                (user['surname']?.toLowerCase().contains(query) ?? false) ||
                (user['email']?.toLowerCase().contains(query) ?? false) ||
                (user['login']?.toLowerCase().contains(query) ?? false);
          }).toList();
    }
    combined.sort((a, b) {
      final sa = '${a['surname']} ${a['name']}'.toLowerCase();
      final sb = '${b['surname']} ${b['name']}'.toLowerCase();
      return _sortAsc ? sa.compareTo(sb) : sb.compareTo(sa);
    });
    return combined;
  }

  void _applyFilters() {
    setState(() => _filteredUsers = _computeFiltered());
  }

  Future<void> _deleteUser(String id, String role) async {
    final service = UsersFetchService();
    final result = await service.deleteUserById(id, role);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    MessengerHelper.showSuccess('Пользователь удалён');
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) return _buildUserSkeleton();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilters(colors),
                const SizedBox(height: AppSpacing.l),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUsers,
                    child:
                        _filteredUsers.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      'Пользователи не найдены',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredUsers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _buildUserCard(user, colors);
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ColorScheme colors) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
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
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('Все', 'all', colors),
                        const SizedBox(width: 10),
                        _filterChip('Преподаватели', 'teacher', colors),
                        const SizedBox(width: 10),
                        _filterChip('Операторы', 'schedule_operator', colors),
                        const SizedBox(width: 10),
                        _filterChip('Студенты', 'student', colors),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _sortAsc ? 'А–Я (нажмите для Я–А)' : 'Я–А (нажмите для А–Я)',
                  icon: Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward, color: colors.primary),
                  onPressed: () {
                    _sortAsc = !_sortAsc;
                    _applyFilters();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, ColorScheme colors) {
    final selected = _selectedRole == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: colors.primary,
      backgroundColor: colors.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        _selectedRole = value;
        _applyFilters();
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ColorScheme colors) {
    final fullName = '${user['surname']} ${user['name']}';
    final role = user['role'] as String;
    final isTeacher = role == 'teacher';
    final isOperator = role == 'schedule_operator';
    final Color avatarColor;
    final IconData icon;
    if (isTeacher) {
      avatarColor = Colors.deepOrange.shade400;
      icon = Icons.school;
    } else if (isOperator) {
      avatarColor = Colors.teal.shade400;
      icon = Icons.edit_calendar;
    } else {
      avatarColor = Colors.blue.shade600;
      icon = Icons.person;
    }
    final String subtitle;
    if (isTeacher || isOperator) {
      subtitle = user['email'] as String? ?? '';
    } else {
      subtitle = 'Группа ${user['group_name']}';
    }
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: avatarColor, child: Icon(icon, color: Colors.white)),
        title: Text(fullName, style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.onSurfaceVariant)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.primary),
              tooltip: 'Редактировать',
              onPressed: () => _showEditDialog(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Удалить пользователя',
              onPressed: () => _confirmDelete(user),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    showDialog<bool>(
      context: context,
      builder: (_) => _EditUserDialog(user: user, groups: _groups, service: UsersFetchService()),
    ).then((updated) {
      if (updated == true) _loadUsers();
    });
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

  Widget _buildUserSkeleton() {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.all(AppSpacing.l),
      itemBuilder:
          (context, index) => ListTile(
            leading: const Skeleton(height: 48, width: 48, borderRadius: 24),
            title: const Skeleton(height: 16, width: 120),
            subtitle: const Skeleton(height: 12, width: 200),
            trailing: Skeleton(height: 32, width: 32, borderRadius: 8),
          ),
    );
  }
}

class _EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Group> groups;
  final UsersFetchService service;

  const _EditUserDialog({required this.user, required this.groups, required this.service});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _emailController;
  Group? _selectedGroup;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] as String? ?? '');
    _surnameController = TextEditingController(text: widget.user['surname'] as String? ?? '');
    _emailController = TextEditingController(text: widget.user['email'] as String? ?? '');
    if (widget.user['role'] == 'student') {
      final groupId = widget.user['group_id']?.toString();
      _selectedGroup = widget.groups.where((g) => g.id == groupId).firstOrNull;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || surname.isEmpty || email.isEmpty) {
      MessengerHelper.showError('Заполните все поля');
      return;
    }
    setState(() => _isSaving = true);
    final result = await widget.service.updateUser(
      id: widget.user['id'].toString(),
      role: widget.user['role'] as String,
      name: name,
      surname: surname,
      email: email,
      groupId: _selectedGroup?.id,
    );
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      setState(() => _isSaving = false);
      return;
    }
    MessengerHelper.showSuccess('Данные обновлены');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.user['role'] == 'student';
    return AlertDialog(
      title: const Text('Редактировать пользователя'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder(), isDense: true),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Фамилия',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), isDense: true),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              if (isStudent && widget.groups.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                DropdownButtonFormField<Group>(
                  decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder(), isDense: true),
                  initialValue: _selectedGroup,
                  isExpanded: true,
                  items: widget.groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                  onChanged: (g) => setState(() => _selectedGroup = g),
                ),
              ],
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child:
              _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сохранить'),
        ),
      ],
    );
  }
}
