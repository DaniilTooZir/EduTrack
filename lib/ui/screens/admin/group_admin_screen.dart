import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GroupAdminScreen extends StatefulWidget {
  const GroupAdminScreen({super.key});

  @override
  State<GroupAdminScreen> createState() => _GroupAdminScreenState();
}

class _GroupAdminScreenState extends State<GroupAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _service = GroupService();
  List<Group> _groups = [];
  bool _isLoading = true;
  bool _isAdding = false;

  final _groupNameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9-]+$');
  final _groupNameAllowList = RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9-]');

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    try {
      final groups = await _service.getGroups(institutionId);
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Future<void> _addGroup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);
    try {
      final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
      if (institutionId == null) throw Exception('ID учреждения не найден');
      final newGroup = Group(name: _nameController.text.trim(), institutionId: institutionId);
      await _service.addGroup(newGroup);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Группа успешно добавлена'), backgroundColor: Colors.green));
      _nameController.clear();
      await _loadGroups();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _editGroup(Group group) async {
    final editController = TextEditingController(text: group.name);
    final editFormKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Изменить название'),
            content: Form(
              key: editFormKey,
              child: TextFormField(
                controller: editController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Новое название',
                  border: OutlineInputBorder(),
                  hintText: 'Например: 11-Б',
                ),
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.allow(_groupNameAllowList)],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Введите название';
                  if (!_groupNameRegex.hasMatch(val)) return 'Только буквы, цифры и "-"';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: () async {
                  if (!editFormKey.currentState!.validate()) return;
                  if (editController.text.trim() == group.name) {
                    Navigator.pop(ctx);
                    return;
                  }
                  try {
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    await _service.updateGroup(group.id!, editController.text.trim());
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Группа обновлена')));
                    await _loadGroups();
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent));
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteGroup(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить группу?'),
            content: Text('Вы уверены, что хотите удалить группу "${group.name}"? Это действие нельзя отменить.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _service.deleteGroup(group.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Группа удалена')));
        await _loadGroups();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Название группы',
                                hintText: 'Например: 10-А',
                                prefixIcon: const Icon(Icons.group_work, color: Color(0xFF5E35B1)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                isDense: true,
                                counterText: '',
                              ),
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.allow(_groupNameAllowList)],
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Введите название';
                                if (!_groupNameRegex.hasMatch(val)) {
                                  return 'Только буквы, цифры и "-"';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E35B1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(0, 50),
                            ),
                            onPressed: _isAdding ? null : _addGroup,
                            child:
                                _isAdding
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                    : const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Список групп',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[700],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _groups.isEmpty
                          ? Center(
                            child: Text(
                              'Группы не найдены',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          )
                          : ListView.separated(
                            itemCount: _groups.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final group = _groups[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 3,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepPurple[200],
                                    child: Text(
                                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editGroup(group);
                                      } else if (value == 'delete') {
                                        _deleteGroup(group);
                                      }
                                    },
                                    itemBuilder:
                                        (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('Изменить'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Удалить'),
                                              ],
                                            ),
                                          ),
                                        ],
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  ),
                                ),
                              );
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
}
