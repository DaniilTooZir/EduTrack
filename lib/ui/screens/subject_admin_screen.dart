import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/subject_service.dart';

class SubjectAdminScreen extends StatefulWidget {
  const SubjectAdminScreen({super.key});

  @override
  State<SubjectAdminScreen> createState() => _SubjectAdminScreenState();
}

class _SubjectAdminScreenState extends State<SubjectAdminScreen> {
  late final SubjectService _subjectService;
  late Future<List<Subject>> _subjectFuture;
  String? _institutionId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjectService = SubjectService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;
    _loadSubjects();
  }

  void _loadSubjects() {
    if (_institutionId == null) {
      _subjectFuture = Future.error('ID учреждения не найден');
    } else {
      _subjectFuture = _subjectService.getSubjectsForInstitution(
        _institutionId!,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherIdController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка: не удалось получить ID учреждения'),
        ),
      );
      return;
    }
    try {
      await _subjectService.addSubject(
        name: _nameController.text.trim(),
        institutionId: _institutionId!,
        teacherId: _teacherIdController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Предмет успешно добавлен')));
      _nameController.clear();
      _teacherIdController.clear();
      _loadSubjects();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении предмета: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название предмета',
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Введите название' : null,
              ),
              TextFormField(
                controller: _teacherIdController,
                decoration: const InputDecoration(
                  labelText: 'ID преподавателя',
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Введите ID преподавателя'
                            : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addSubject,
                child: const Text('Добавить предмет'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder<List<Subject>>(
            future: _subjectFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Ошибка загрузки: ${snapshot.error}'),
                );
              }
              final subjects = snapshot.data ?? [];
              if (subjects.isEmpty) {
                return const Center(child: Text('Список предметов пуст'));
              }
              return ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    title: Text(subject.name),
                    subtitle: Text('Преподаватель ID: ${subject.teacherId}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
