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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e'), backgroundColor: Colors.redAccent));
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
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildFilters(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredHomeworks.isEmpty
                        ? Center(
                          child: Text('Задания не найдены', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredHomeworks.length,
                          itemBuilder: (context, index) {
                            final hw = _filteredHomeworks[index];
                            return _buildHomeworkCard(hw);
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск задания...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5E35B1)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              fillColor: Colors.grey[100],
              filled: true,
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
    );
  }

  Widget _buildHomeworkCard(Homework hw) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openHomeworkDetails(hw),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.assignment, color: Color(0xFF5E35B1)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hw.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          '${hw.subject?.name ?? "Предмет"} • ${hw.group?.name ?? "Группа"}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              if (hw.dueDate != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.homework.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatChip(
                          label: 'Всего: ${_students.length}',
                          color: Colors.blue.shade50,
                          textColor: Colors.blue.shade800,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Сдали: ${_statusMap.values.where((s) => s.isCompleted).length}',
                          color: Colors.green.shade50,
                          textColor: Colors.green.shade800,
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
                        ? const Center(child: Text('В группе нет студентов'))
                        : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _students.length,
                          itemBuilder: (ctx, index) {
                            final student = _students[index];
                            final status = _statusMap[student.id];
                            final isCompleted = status?.isCompleted ?? false;
                            return CheckboxListTile(
                              title: Text('${student.surname} ${student.name}'),
                              secondary: CircleAvatar(
                                backgroundColor: isCompleted ? Colors.green[100] : Colors.grey[200],
                                child: Icon(
                                  isCompleted ? Icons.check : Icons.person,
                                  color: isCompleted ? Colors.green[800] : Colors.grey[600],
                                ),
                              ),
                              value: isCompleted,
                              activeColor: const Color(0xFF5E35B1),
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

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _StatChip({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
