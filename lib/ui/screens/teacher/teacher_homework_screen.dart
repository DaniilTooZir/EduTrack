import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/providers/user_provider.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  late BuildContext _scaffoldContext;

  final HomeworkService _homeworkService = HomeworkService();
  final SubjectService _subjectService = SubjectService();
  final GroupService _groupService = GroupService();

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

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId!;
      final institutionId = userProvider.institutionId!;

      final subjects = await _subjectService.getSubjectsByTeacherId(userId);
      final groups = await _groupService.getGroups(institutionId);
      final homeworks = await _homeworkService.getHomeworkByTeacherId(userId);
      setState(() {
        _subjects = subjects;
        _groups = groups;
        _homeworks = homeworks;
        _selectedSubjectId = subjects.isNotEmpty ? subjects.first.id : null;
        _selectedGroupId = groups.isNotEmpty ? groups.first.id : null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
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
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _addHomework() async {
    if (_selectedSubjectId == null ||
        _selectedGroupId == null ||
        _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Пожалуйста, выберите предмет, группу и заполните заголовок',
          ),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final institutionId =
          Provider.of<UserProvider>(context, listen: false).institutionId!;
      await _homeworkService.addHomework(
        institutionId: userProvider.institutionId!,
        subjectId: _selectedSubjectId!,
        groupId: _selectedGroupId!,
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        dueDate: _dueDate,
      );
      await _loadData();
      _titleController.clear();
      _descriptionController.clear();
      _dueDate = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Домашнее задание успешно добавлено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при добавлении: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showEditHomeworkDialog(Homework hw) {
    final _editTitleController = TextEditingController(text: hw.title);
    final _editDescriptionController = TextEditingController(
      text: hw.description ?? '',
    );
    DateTime? _editDueDate = hw.dueDate;
    String? _editSelectedGroupId = hw.group?.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _selectEditDueDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _editDueDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _editDueDate = picked);
              }
            }

            return AlertDialog(
              title: const Text('Редактировать домашнее задание'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _editSelectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Выберите группу',
                        border: OutlineInputBorder(),
                      ),
                      items: _groups
                          .map((group) => DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _editSelectedGroupId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _editTitleController,
                      decoration: const InputDecoration(labelText: 'Заголовок'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _editDescriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Описание'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _editDueDate == null
                                ? 'Дата сдачи не выбрана'
                                : 'Дата сдачи: ${_editDueDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                        TextButton(
                          onPressed: _selectEditDueDate,
                          child: const Text('Выбрать дату'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newTitle = _editTitleController.text.trim();
                    if (newTitle.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Заголовок не может быть пустым'),
                        ),
                      );
                      return;
                    }
                    if (_editSelectedGroupId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Пожалуйста, выберите группу'),
                        ),
                      );
                      return;
                    }
                    try {
                      await _homeworkService.updateHomework(
                        id: hw.id,
                        title: newTitle,
                        description: _editDescriptionController.text.trim(),
                        dueDate: _editDueDate,
                        groupId: _editSelectedGroupId!,
                      );
                      Navigator.of(context).pop();
                      await _loadData();
                      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Домашнее задание обновлено'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                        SnackBar(content: Text('Ошибка обновления: $e')),
                      );
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить домашнее задание?'),
          content: Text(
            'Вы уверены, что хотите удалить задание "${hw.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _homeworkService.deleteHomework(hw.id);
                  await _loadData();
                  ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Домашнее задание удалено')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $e')),
                  );
                }
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Ошибка: $_error'));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ваши домашние задания',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_homeworks.isEmpty)
            const Text('У вас пока нет домашних заданий.')
          else
            ..._homeworks.map((hw) {
              final dueDateText = hw.dueDate != null
                  ? 'До ${hw.dueDate!.toLocal().toString().split(' ')[0]}'
                  : 'Без срока';
              final groupName = hw.group?.name ?? 'Группа не указана';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(hw.title),
                  subtitle: Text('$dueDateText • $groupName'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditHomeworkDialog(hw),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteHomework(hw),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          const Divider(height: 32),
          const Text(
            'Добавить новое домашнее задание',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGroupId,
            decoration: const InputDecoration(
              labelText: 'Выберите группу',
              border: OutlineInputBorder(),
            ),
            items: _groups
                .map(
                  (group) => DropdownMenuItem(
                value: group.id,
                child: Text(group.name),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGroupId = value;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSubjectId,
            decoration: const InputDecoration(
              labelText: 'Выберите предмет',
              border: OutlineInputBorder(),
            ),
            items: _subjects
                .map(
                  (subj) => DropdownMenuItem(
                value: subj.id,
                child: Text(subj.name),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubjectId = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Заголовок задания',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Описание (необязательно)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _dueDate == null
                      ? 'Дата сдачи не выбрана'
                      : 'Дата сдачи: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              TextButton(
                onPressed: _selectDueDate,
                child: const Text('Выбрать дату'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _addHomework,
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Добавить домашнее задание'),
            ),
          ),
        ],
      ),
    );
  }
}
