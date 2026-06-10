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
import 'package:edu_track/utils/app_bottom_sheet.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final teacherId = userProvider.userId!;
    final institutionId = userProvider.institutionId!;
    final (subjectsResult, groupsResult, homeworksResult) =
        await (
          _subjectService.getSubjectsByTeacherId(teacherId),
          _groupService.getGroups(institutionId),
          _homeworkService.getHomeworkByTeacherId(teacherId),
        ).wait;
    if (!mounted) return;
    if (subjectsResult.isFailure) {
      setState(() => _isLoading = false);
      MessengerHelper.showError(subjectsResult.errorMessage);
      return;
    }
    if (groupsResult.isFailure) {
      setState(() => _isLoading = false);
      MessengerHelper.showError(groupsResult.errorMessage);
      return;
    }
    if (homeworksResult.isFailure) {
      setState(() => _isLoading = false);
      MessengerHelper.showError(homeworksResult.errorMessage);
      return;
    }
    setState(() {
      _subjects = subjectsResult.data;
      _groups = groupsResult.data;
      _allHomeworks = homeworksResult.data;
      _isLoading = false;
    });
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
    showAppBottomSheet(
      context,
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
                        padding: const EdgeInsets.all(AppSpacing.l),
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
      margin: const EdgeInsets.all(AppSpacing.l),
      elevation: 4,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
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
                fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSubjectId,
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
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGroupId,
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
    final (studentsResult, statusesResult) =
        await (
          widget.studentService.getStudentsByGroupId(widget.homework.groupId),
          widget.homeworkService.getStatusesByHomeworkId(widget.homework.id),
        ).wait;
    if (!mounted) return;
    if (studentsResult.isFailure || statusesResult.isFailure) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _students = studentsResult.data;
      _statusMap = {for (final s in statusesResult.data) s.studentId: s};
      _isLoading = false;
    });
  }

  void _showEvaluationDialog(Student student, HomeworkStatus? status) {
    showDialog(
      context: context,
      builder:
          (ctx) => _EvaluationDialog(
            student: student,
            status: status,
            homework: widget.homework,
            onUpdate: (isCompleted, comment) async {
              final result = await widget.homeworkService.evaluateHomework(
                homeworkId: widget.homework.id,
                studentId: student.id,
                isCompleted: isCompleted,
                teacherComment: comment,
              );
              if (result.isFailure) {
                MessengerHelper.showError(result.errorMessage);
                return false;
              }
              await _loadDetails();
              return true;
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
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
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
                        const SizedBox(width: AppSpacing.l),
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
                            final hasAnswer = status?.fileUrl != null || status?.studentComment != null;

                            final IconData stateIcon;
                            final Color stateColor;
                            final String stateText;
                            if (isCompleted) {
                              stateIcon = Icons.check_circle;
                              stateColor = Colors.green;
                              stateText = 'Принято';
                            } else if (hasAnswer && status?.teacherComment != null) {
                              stateIcon = Icons.refresh_rounded;
                              stateColor = Colors.orange;
                              stateText = 'На доработку';
                            } else if (hasAnswer) {
                              stateIcon = Icons.hourglass_empty_rounded;
                              stateColor = colors.primary;
                              stateText = 'Ожидает проверки';
                            } else {
                              stateIcon = Icons.circle_outlined;
                              stateColor = colors.onSurfaceVariant;
                              stateText = 'Не сдал';
                            }

                            return Card(
                              elevation: 0,
                              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
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
                                    if (status?.fileUrl != null) ...[
                                      Icon(Icons.attach_file, size: 14, color: stateColor),
                                      const SizedBox(width: 4),
                                    ],
                                    if (status?.studentComment != null) ...[
                                      Icon(Icons.comment, size: 14, color: stateColor),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(stateText, style: TextStyle(fontSize: 12, color: stateColor)),
                                  ],
                                ),
                                trailing: Icon(stateIcon, color: stateColor),
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

class _EvaluationDialog extends StatefulWidget {
  final Student student;
  final HomeworkStatus? status;
  final Homework homework;
  final Future<bool> Function(bool, String?) onUpdate;

  const _EvaluationDialog({
    required this.student,
    required this.status,
    required this.homework,
    required this.onUpdate,
  });

  @override
  State<_EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<_EvaluationDialog> {
  late TextEditingController _feedbackController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController(text: widget.status?.teacherComment);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _openFile(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      MessengerHelper.showError('Не удалось открыть файл');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasAnswer = widget.status?.studentComment != null || widget.status?.fileUrl != null;
    final isAccepted = widget.status?.isCompleted == true;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text('${widget.student.surname} ${widget.student.name}', style: const TextStyle(fontSize: 16)),
          ),
          if (isAccepted)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Принято',
                style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
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
              if (widget.status?.studentComment != null) ...[
                Text(
                  'Комментарий студента:',
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.status!.studentComment!),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              if (widget.status?.fileUrl != null)
                OutlinedButton.icon(
                  onPressed: () => _openFile(context, widget.status!.fileUrl!),
                  icon: const Icon(Icons.file_download),
                  label: Text(widget.status?.fileName ?? 'Скачать файл'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                  ),
                ),
            ],
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
            Text('Ваш отзыв:', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Напишите замечания или похвалу...',
                hintStyle: TextStyle(fontSize: 14, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colors.surface,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Отмена')),
        ElevatedButton.icon(
          onPressed:
              (!hasAnswer || _isSubmitting)
                  ? null
                  : () async {
                    final navigator = Navigator.of(context);
                    setState(() => _isSubmitting = true);
                    final comment = _feedbackController.text.trim();
                    final success = await widget.onUpdate(true, comment.isEmpty ? null : comment);
                    if (!mounted) return;
                    if (success) {
                      navigator.pop();
                    } else {
                      setState(() => _isSubmitting = false);
                    }
                  },
          icon:
              _isSubmitting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                  : const Icon(Icons.check),
          label: const Text('Принять'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        ),
        if (hasAnswer)
          TextButton.icon(
            onPressed:
                _isSubmitting
                    ? null
                    : () async {
                      final navigator = Navigator.of(context);
                      setState(() => _isSubmitting = true);
                      final comment = _feedbackController.text.trim();
                      final success = await widget.onUpdate(false, comment.isEmpty ? null : comment);
                      if (!mounted) return;
                      if (success) {
                        navigator.pop();
                      } else {
                        setState(() => _isSubmitting = false);
                      }
                    },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('На доработку'),
            style: TextButton.styleFrom(foregroundColor: colors.error),
          ),
      ],
    );
  }
}
