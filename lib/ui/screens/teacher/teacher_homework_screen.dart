import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeworkService = HomeworkService();
  final _subjectService = SubjectService();
  final _groupService = GroupService();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Homework> _homeworks = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];

  String? _selectedSubjectId;
  String? _selectedGroupId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId!;
      final institutionId = userProvider.institutionId!;

      final subjects = await _subjectService.getSubjectsByTeacherId(userId);
      final groups = await _groupService.getGroups(institutionId);
      final homeworks = await _homeworkService.getHomeworkByTeacherId(userId);

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _groups = groups;
          _homeworks = homeworks;
          if (_selectedSubjectId == null && subjects.isNotEmpty) _selectedSubjectId = subjects.first.id;
          if (_selectedGroupId == null && groups.isNotEmpty) _selectedGroupId = groups.first.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  Future<void> _addHomework() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите предмет и группу')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await _homeworkService.addHomework(
        institutionId: userProvider.institutionId!,
        subjectId: _selectedSubjectId!,
        groupId: _selectedGroupId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        dueDate: _dueDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Домашнее задание добавлено'), backgroundColor: Colors.green));
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _dueDate = null);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showEditHomeworkDialog(Homework hw) {
    final editTitleController = TextEditingController(text: hw.title);
    final editDescriptionController = TextEditingController(text: hw.description ?? '');
    DateTime? editDueDate = hw.dueDate;
    String? editSelectedGroupId = hw.group?.id;
    final editFormKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Редактировать ДЗ'),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: editSelectedGroupId,
                        decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder()),
                        items: _groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                        onChanged: (val) => setStateDialog(() => editSelectedGroupId = val),
                        validator: (val) => val == null ? 'Выберите группу' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: editTitleController,
                        decoration: const InputDecoration(labelText: 'Заголовок', border: OutlineInputBorder()),
                        validator: (val) => Validators.requiredField(val, fieldName: 'Заголовок'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: editDescriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              editDueDate == null
                                  ? 'Дата сдачи не выбрана'
                                  : 'Срок: ${editDueDate!.toLocal().toString().split(' ')[0]}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: editDueDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setStateDialog(() => editDueDate = picked);
                            },
                            child: const Text('Изменить дату'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                ElevatedButton(
                  onPressed: () async {
                    if (!editFormKey.currentState!.validate()) return;
                    if (editSelectedGroupId == null) return;

                    try {
                      await _homeworkService.updateHomework(
                        id: hw.id,
                        title: editTitleController.text.trim(),
                        description: editDescriptionController.text.trim(),
                        dueDate: editDueDate,
                        groupId: editSelectedGroupId!,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ДЗ обновлено')));
                      _loadData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteHomework(Homework hw) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить задание?'),
            content: Text('Вы уверены, что хотите удалить "${hw.title}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _homeworkService.deleteHomework(hw.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Задание удалено')));
                    _loadData();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                  }
                },
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Текущие задания',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                        ),
                        const SizedBox(height: 16),
                        if (_homeworks.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Нет активных заданий')))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _homeworks.length,
                            itemBuilder: (ctx, index) {
                              final hw = _homeworks[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  title: Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Группа: ${hw.group?.name ?? "—"}'),
                                      if (hw.dueDate != null)
                                        Text(
                                          'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: hw.dueDate!.isBefore(DateTime.now()) ? Colors.red : Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (val) {
                                      if (val == 'edit') _showEditHomeworkDialog(hw);
                                      if (val == 'delete') _confirmDeleteHomework(hw);
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
                        const Divider(height: 40, thickness: 1.5),
                        const Text(
                          'Создать новое задание',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _selectedSubjectId,
                                    decoration: const InputDecoration(
                                      labelText: 'Предмет',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        _subjects
                                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                                            .toList(),
                                    onChanged: (val) => setState(() => _selectedSubjectId = val),
                                    validator: (val) => val == null ? 'Выберите предмет' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: _selectedGroupId,
                                    decoration: const InputDecoration(
                                      labelText: 'Группа',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        _groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                                    onChanged: (val) => setState(() => _selectedGroupId = val),
                                    validator: (val) => val == null ? 'Выберите группу' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Заголовок',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) => Validators.requiredField(val, fieldName: 'Заголовок'),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Описание (опционально)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _dueDate == null
                                                ? 'Срок сдачи не выбран'
                                                : 'Срок: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                                            style: TextStyle(color: _dueDate == null ? Colors.grey[600] : Colors.black),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton.filled(
                                        onPressed: _selectDueDate,
                                        icon: const Icon(Icons.calendar_today),
                                        tooltip: 'Выбрать дату',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: const Color(0xFF5E35B1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: _isSaving ? null : _addHomework,
                                      icon:
                                          _isSaving
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                              : const Icon(Icons.add),
                                      label: const Text('Опубликовать задание'),
                                    ),
                                  ),
                                ],
                              ),
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
}
