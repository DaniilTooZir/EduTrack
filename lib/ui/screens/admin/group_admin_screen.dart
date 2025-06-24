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
    return Scaffold(
      appBar: AppBar(title: const Text('Группы')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Название группы',
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
                            onPressed: _addGroup,
                            child: const Text('Добавить'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Список групп',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _groups.length,
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          return Card(child: ListTile(title: Text(group.name)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
