import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/teacher_service.dart';

class SubjectAdminScreen extends StatefulWidget {
  const SubjectAdminScreen({super.key});

  @override
  State<SubjectAdminScreen> createState() => _SubjectAdminScreenState();
}

class _SubjectAdminScreenState extends State<SubjectAdminScreen> {
  late final SubjectService _subjectService;
  late final TeacherService _teacherService;

  late Future<List<Subject>> _subjectFuture;
  late Future<List<Teacher>> _teachersFuture;

  String? _institutionId;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedTeacherId;

  List<Teacher> _teachers = [];

  @override
  void initState() {
    super.initState();
    _subjectService = SubjectService();
    _teacherService = TeacherService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;
    _loadInitialData();
  }

  void _loadInitialData() {
    if (_institutionId == null) {
      _subjectFuture = Future.error('ID учреждения не найден');
      _teachersFuture = Future.value([]);
    } else {
      _subjectFuture = _subjectService.getSubjectsForInstitution(
        _institutionId!,
      );
      _teachersFuture = _teacherService.getTeachers(_institutionId!);
      _teachersFuture.then((list) {
        setState(() => _teachers = list);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addSubject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null || _selectedTeacherId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    try {
      await _subjectService.addSubject(
        name: _nameController.text.trim(),
        institutionId: _institutionId!,
        teacherId: _selectedTeacherId!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Предмет успешно добавлен')));
      _nameController.clear();
      setState(() {
        _selectedTeacherId = null;
        _subjectFuture = _subjectService.getSubjectsForInstitution(
          _institutionId!,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении предмета: $e')),
      );
    }
  }

  String _getTeacherName(String teacherId) {
    final teacher = _teachers.firstWhere(
      (t) => t.id == teacherId,
      orElse:
          () => Teacher(
            id: '',
            name: 'Неизвестно',
            surname: '',
            email: '',
            login: '',
            password: '',
            institutionId: '',
            createdAt: DateTime.now(),
          ),
    );
    return '${teacher.surname} ${teacher.name}';
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
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Введите название'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedTeacherId,
                            decoration: const InputDecoration(
                              labelText: 'Преподаватель',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                _teachers.map((teacher) {
                                  final fullName =
                                      '${teacher.surname} ${teacher.name}';
                                  return DropdownMenuItem(
                                    value: teacher.id,
                                    child: Text(fullName),
                                  );
                                }).toList(),
                            onChanged:
                                (val) =>
                                    setState(() => _selectedTeacherId = val),
                            validator:
                                (val) =>
                                    val == null
                                        ? 'Выберите преподавателя'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _addSubject,
                              child: const Text('Добавить предмет'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          child: Text(
                            'Ошибка: ${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }
                      final subjects = snapshot.data ?? [];
                      if (subjects.isEmpty) {
                        return Center(
                          child: Text(
                            'Список предметов пуст',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              title: Text(subject.name),
                              subtitle: Text(
                                'Преподаватель: ${_getTeacherName(subject.teacherId)}',
                              ),
                            ),
                          );
                        },
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
