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
import 'package:url_launcher/url_launcher.dart';

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
      final results = await Future.wait([
        _subjectService.getSubjectsByTeacherId(teacherId),
        _groupService.getGroups(institutionId),
        _homeworkService.getHomeworkByTeacherId(teacherId),
      ]);
      if (mounted) {
        setState(() {
          _subjects = results[0] as List<Subject>;
          _groups = results[1] as List<Group>;
          _allHomeworks = results[2] as List<Homework>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
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
      await widget.homeworkService.evaluateHomework(
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
            studentComment: existing.studentComment,
            fileUrl: existing.fileUrl,
            fileName: existing.fileName,
          );
        } else {
          _loadDetails();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось обновить статус')));
    }
  }

  void _showEvaluationDialog(Student student, HomeworkStatus? status) {
    showDialog(
      context: context,
      builder:
          (ctx) => _EvaluationDialog(
            student: student,
            status: status,
            homework: widget.homework,
            onUpdate: (isCompleted) async {
              await widget.homeworkService.evaluateHomework(
                homeworkId: widget.homework.id,
                studentId: student.id,
                isCompleted: isCompleted,
              );
              _loadDetails();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final submittedCount =
        _statusMap.values.where((s) => s.isCompleted || (s.fileUrl != null || s.studentComment != null)).length;
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
                        Text('Всего студентов: ${_students.length}', style: TextStyle(color: colors.onSurfaceVariant)),
                        const SizedBox(width: 16),
                        Text(
                          'Сдано: $submittedCount',
                          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
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
                            final hasFile = status?.fileUrl != null;
                            final hasComment = status?.studentComment != null;
                            return Card(
                              elevation: 0,
                              color: colors.surfaceContainerHighest.withOpacity(0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () => _showEvaluationDialog(student, status),
                                title: Text(
                                  '${student.surname} ${student.name}',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
                                ),
                                subtitle: Row(
                                  children: [
                                    if (hasFile) ...[
                                      Icon(Icons.attach_file, size: 14, color: colors.primary),
                                      const SizedBox(width: 4),
                                    ],
                                    if (hasComment) ...[
                                      Icon(Icons.comment, size: 14, color: colors.primary),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      hasFile || hasComment ? 'Есть ответ' : 'Нет ответа',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hasFile || hasComment ? colors.primary : colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  isCompleted ? Icons.check_circle : Icons.circle_outlined,
                                  color: isCompleted ? Colors.green : colors.onSurfaceVariant,
                                ),
                              ),
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

class _EvaluationDialog extends StatelessWidget {
  final Student student;
  final HomeworkStatus? status;
  final Homework homework;
  final Function(bool) onUpdate;

  const _EvaluationDialog({
    required this.student,
    required this.status,
    required this.homework,
    required this.onUpdate,
  });

  Future<void> _openFile(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть файл')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCompleted = status?.isCompleted ?? false;
    final hasAnswer = status?.studentComment != null || status?.fileUrl != null;
    return AlertDialog(
      title: Text('${student.surname} ${student.name}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasAnswer)
              Text(
                'Студент ничего не прикрепил.',
                style: TextStyle(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic),
              )
            else ...[
              if (status?.studentComment != null) ...[
                Text('Комментарий:', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status!.studentComment!),
                ),
                const SizedBox(height: 16),
              ],
              if (status?.fileUrl != null)
                OutlinedButton.icon(
                  onPressed: () => _openFile(context, status!.fileUrl!),
                  icon: const Icon(Icons.file_download),
                  label: Text(status?.fileName ?? 'Скачать файл'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
        ElevatedButton.icon(
          onPressed: () {
            onUpdate(!isCompleted);
            Navigator.pop(context);
          },
          icon: Icon(isCompleted ? Icons.close : Icons.check),
          label: Text(isCompleted ? 'Отменить сдачу' : 'Принять работу'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? colors.error : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
