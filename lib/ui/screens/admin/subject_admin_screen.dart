import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SubjectAdminScreen extends StatefulWidget {
  const SubjectAdminScreen({super.key});

  @override
  State<SubjectAdminScreen> createState() => _SubjectAdminScreenState();
}

class _SubjectAdminScreenState extends State<SubjectAdminScreen> {
  late final SubjectService _subjectService;
  List<Subject> _subjects = [];
  bool _isLoading = true;
  bool _isAdding = false;
  String? _institutionId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectNameAllowList = RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s\-\.\(\)]');

  @override
  void initState() {
    super.initState();
    _subjectService = SubjectService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_institutionId == null) return;
    setState(() => _isLoading = true);
    try {
      final subjects = await _subjectService.getSubjectsForInstitution(_institutionId!);
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null) return;
    setState(() => _isAdding = true);
    try {
      await _subjectService.addSubject(name: _nameController.text.trim(), institutionId: _institutionId!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Предмет успешно добавлен'), backgroundColor: Colors.green));
      _nameController.clear();
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _editSubject(Subject subject) async {
    final editNameController = TextEditingController(text: subject.name);
    final editFormKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Изменить предмет'),
                content: Form(
                  key: editFormKey,
                  child: TextFormField(
                    controller: editNameController,
                    decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                    inputFormatters: [FilteringTextInputFormatter.allow(_subjectNameAllowList)],
                    validator: (val) => Validators.requiredField(val, fieldName: 'Название'),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                  ElevatedButton(
                    onPressed: () async {
                      if (!editFormKey.currentState!.validate()) return;
                      try {
                        Navigator.pop(ctx);
                        this.setState(() => _isLoading = true);
                        await _subjectService.updateSubject(id: subject.id, name: editNameController.text.trim());
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Предмет обновлен')));
                        _loadData();
                      } catch (e) {
                        if (!mounted) return;
                        this.setState(() => _isLoading = false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent));
                      }
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить предмет?'),
            content: Text(
              'Вы уверены, что хотите удалить предмет "${subject.name}"? Это может затронуть расписание и оценки.',
            ),
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
        await _subjectService.deleteSubject(subject.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Предмет удален')));
        _loadData();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
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
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Название предмета',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.book, color: Color(0xFF5E35B1)),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.allow(_subjectNameAllowList)],
                            validator: (val) => Validators.requiredField(val, fieldName: 'Название'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFF5E35B1),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _isAdding ? null : _addSubject,
                              child:
                                  _isAdding
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                      : const Text('Добавить предмет'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Список предметов',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple[700]),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _subjects.isEmpty
                          ? Center(
                            child: Text(
                              'Список предметов пуст',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          )
                          : ListView.separated(
                            itemCount: _subjects.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepPurple[200],
                                    child: Text(
                                      subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') _editSubject(subject);
                                      if (value == 'delete') _deleteSubject(subject);
                                    },
                                    itemBuilder:
                                        (context) => [
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
