import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/providers/user_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final institutionId =
        Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    final groups = await _service.getGroups(institutionId);
    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  Future<void> _addGroup() async {
    if (!_formKey.currentState!.validate()) return;
    final institutionId =
        Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    final newGroup = Group(
      name: _nameController.text.trim(),
      institutionId: institutionId,
    );
    await _service.addGroup(newGroup);
    _nameController.clear();
    await _loadGroups();
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
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Название группы',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? 'Введите название'
                                                  : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _addGroup,
                                    child: const Text('Добавить'),
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
                              _groups.isEmpty
                                  ? Center(
                                    child: Text(
                                      'Группы не найдены',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  )
                                  : ListView.separated(
                                    itemCount: _groups.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final group = _groups[index];
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 3,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Colors.deepPurple[200],
                                            child: Text(
                                              group.name.isNotEmpty
                                                  ? group.name[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            group.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
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
