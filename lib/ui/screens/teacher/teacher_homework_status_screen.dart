import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherHomeworkStatusScreen extends StatefulWidget {
  const TeacherHomeworkStatusScreen({super.key});

  @override
  State<TeacherHomeworkStatusScreen> createState() => _TeacherHomeworkStatusScreenState();
}

class _TeacherHomeworkStatusScreenState extends State<TeacherHomeworkStatusScreen> {
  final _homeworkService = HomeworkService();
  final _subjectService = SubjectService();
  final _groupService = GroupService();
  final _studentService = StudentService();

  bool _isLoading = true;
  List<Homework> _allHomeworks = [];
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  String? _selectedSubjectId;
  String? _selectedGroupId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final teacherId = userProvider.userId!;
      final institutionId = userProvider.institutionId!;
      final subjects = await _subjectService.getSubjectsByTeacherId(teacherId);
      final groups = await _groupService.getGroups(institutionId);
      final homeworks = await _homeworkService.getHomeworkByTeacherId(teacherId);
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _groups = groups;
          _allHomeworks = homeworks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Homework> get _filteredHomeworks {
    return _allHomeworks.where((hw) {
      final matchSubject = _selectedSubjectId == null || hw.subjectId == _selectedSubjectId;
      final matchGroup = _selectedGroupId == null || hw.groupId == _selectedGroupId;
      final matchSearch = _searchQuery.isEmpty || hw.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSubject && matchGroup && matchSearch;
    }).toList();
  }

  void _openHomeworkDetails(Homework hw) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              _HomeworkDetailSheet(homework: hw, studentService: _studentService, homeworkService: _homeworkService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildFilters(colors),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredHomeworks.isEmpty
                      ? Center(child: Text('Задания не найдены', style: TextStyle(color: colors.onSurfaceVariant)))
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredHomeworks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final hw = _filteredHomeworks[index];
                          return Card(
                            elevation: 2,
                            color: colors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(
                                hw.title,
                                style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
                              ),
                              subtitle: Text(
                                '${hw.group?.name} • ${hw.subject?.name}',
                                style: TextStyle(color: colors.onSurfaceVariant),
                              ),
                              trailing: Icon(Icons.chevron_right, color: colors.primary),
                              onTap: () => _openHomeworkDetails(hw),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ColorScheme colors) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск задания...',
                prefixIcon: Icon(Icons.search, color: colors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Предмет',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(child: Text('Все')),
                      ..._subjects.map(
                        (s) => DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedSubjectId = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    decoration: const InputDecoration(
                      labelText: 'Группа',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(child: Text('Все')),
                      ..._groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedGroupId = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkDetailSheet extends StatefulWidget {
  final Homework homework;
  final StudentService studentService;
  final HomeworkService homeworkService;
  const _HomeworkDetailSheet({required this.homework, required this.studentService, required this.homeworkService});

  @override
  State<_HomeworkDetailSheet> createState() => _HomeworkDetailSheetState();
}

class _HomeworkDetailSheetState extends State<_HomeworkDetailSheet> {
  bool _isLoading = true;
  List<Student> _students = [];
  Map<String, HomeworkStatus> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final students = await widget.studentService.getStudentsByGroupId(widget.homework.groupId);
      final statuses = await widget.homeworkService.getStatusesByHomeworkId(widget.homework.id);
      if (mounted) {
        setState(() {
          _students = students;
          _statusMap = {for (final s in statuses) s.studentId: s};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(String studentId, bool currentStatus) async {
    try {
      await widget.homeworkService.setHomeworkCompletion(
        homeworkId: widget.homework.id,
        studentId: studentId,
        isCompleted: !currentStatus,
      );
      setState(() {
        final existing = _statusMap[studentId];
        if (existing != null) {
          _statusMap[studentId] = HomeworkStatus(
            id: existing.id,
            homeworkId: existing.homeworkId,
            studentId: existing.studentId,
            isCompleted: !currentStatus,
            updatedAt: DateTime.now(),
          );
        } else {
          _loadDetails();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось обновить статус')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.homework.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Всего: ${_students.length}', style: TextStyle(color: colors.onSurfaceVariant)),
                        const SizedBox(width: 16),
                        Text(
                          'Сдали: ${_statusMap.values.where((s) => s.isCompleted).length}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _students.isEmpty
                        ? Center(
                          child: Text('В группе нет студентов', style: TextStyle(color: colors.onSurfaceVariant)),
                        )
                        : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _students.length,
                          itemBuilder: (ctx, index) {
                            final student = _students[index];
                            final status = _statusMap[student.id];
                            final isCompleted = status?.isCompleted ?? false;
                            return CheckboxListTile(
                              title: Text(
                                '${student.surname} ${student.name}',
                                style: TextStyle(color: colors.onSurface),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: isCompleted ? Colors.green[100] : colors.surfaceContainerHighest,
                                child: Icon(
                                  isCompleted ? Icons.check : Icons.person,
                                  color: isCompleted ? Colors.green[800] : colors.onSurfaceVariant,
                                ),
                              ),
                              value: isCompleted,
                              activeColor: colors.primary,
                              onChanged: (val) => _toggleStatus(student.id, isCompleted),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
