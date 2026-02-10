import 'package:edu_track/data/services/file_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  final _homeworkService = HomeworkService();
  final _fileService = FileService();
  bool _isLoading = true;
  List<Homework> _homeworks = [];
  Map<String, HomeworkStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  Future<void> _loadHomework() async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    if (_homeworks.isEmpty) setState(() => _isLoading = true);
    try {
      final homeworks = await _homeworkService.getHomeworksByStudentGroup(studentId);
      final statuses = await _homeworkService.getHomeworkStatusesForStudent(studentId);
      if (mounted) {
        setState(() {
          _homeworks = homeworks;
          _statuses = {for (final s in statuses) s.homeworkId: s};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _openHomeworkSheet(Homework hw) async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _HomeworkSubmissionSheet(
            homework: hw,
            status: _statuses[hw.id],
            studentId: studentId,
            homeworkService: _homeworkService,
            fileService: _fileService,
          ),
    );
    _loadHomework();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_homeworks.isEmpty) {
      return Center(
        child: Text('Нет домашних заданий.', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16)),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          itemCount: _homeworks.length,
          itemBuilder: (context, index) {
            final hw = _homeworks[index];
            final status = _statuses[hw.id];
            final isDone = status?.isCompleted ?? false;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colors.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openHomeworkSheet(hw),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.green.withOpacity(0.1) : colors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.priority_high,
                          color: isDone ? Colors.green : colors.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hw.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hw.subject?.name ?? 'Предмет',
                              style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            if (hw.dueDate != null)
                              Text(
                                'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color:
                                      hw.dueDate!.isBefore(DateTime.now()) && !isDone
                                          ? colors.error
                                          : colors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeworkSubmissionSheet extends StatefulWidget {
  final Homework homework;
  final HomeworkStatus? status;
  final String studentId;
  final HomeworkService homeworkService;
  final FileService fileService;
  const _HomeworkSubmissionSheet({
    required this.homework,
    required this.status,
    required this.studentId,
    required this.homeworkService,
    required this.fileService,
  });

  @override
  State<_HomeworkSubmissionSheet> createState() => _HomeworkSubmissionSheetState();
}

class _HomeworkSubmissionSheetState extends State<_HomeworkSubmissionSheet> {
  final _commentController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _isDone = widget.status?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await widget.fileService.pickFile();
    if (file != null) {
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _submitWork() async {
    setState(() => _isSubmitting = true);
    try {
      String? fileUrl;
      String? fileName;
      if (_selectedFile != null) {
        fileUrl = await widget.fileService.uploadFile(file: _selectedFile!, folderName: 'student_homeworks');
        fileName = _selectedFile!.name;
        if (fileUrl == null) throw Exception('Не удалось загрузить файл');
      }
      await widget.homeworkService.submitHomework(
        homeworkId: widget.homework.id,
        studentId: widget.studentId,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        fileUrl: fileUrl,
        fileName: fileName,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Работа успешно сдана!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _cancelSubmission() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.homeworkService.cancelSubmission(homeworkId: widget.homework.id, studentId: widget.studentId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сдача отменена')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Theme.of(context).colorScheme.error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hw = widget.homework;
    final status = widget.status;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('Задание', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(hw.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (hw.description != null)
                      Text(hw.description!, style: TextStyle(color: colors.onSurface.withOpacity(0.8), fontSize: 16)),
                    const SizedBox(height: 16),
                    if (hw.fileUrl != null)
                      InkWell(
                        onTap: () => _openFile(hw.fileUrl!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, color: colors.onSecondaryContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Материал учителя',
                                      style: TextStyle(fontSize: 10, color: colors.onSecondaryContainer),
                                    ),
                                    Text(
                                      hw.fileName ?? 'Скачать файл',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSecondaryContainer),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.download, color: colors.onSecondaryContainer),
                            ],
                          ),
                        ),
                      ),
                    const Divider(height: 40),
                    Text(
                      _isDone ? 'Ваш ответ (Сдано)' : 'Ваше решение',
                      style: TextStyle(
                        color: _isDone ? Colors.green : colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isDone) ...[
                      if (status?.studentComment != null && status!.studentComment!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Text(status.studentComment!),
                        ),
                      const SizedBox(height: 12),
                      if (status?.fileUrl != null)
                        InkWell(
                          onTap: () => _openFile(status.fileUrl!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.description, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    status!.fileName ?? 'Ваш файл',
                                    style: TextStyle(color: colors.onPrimaryContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _cancelSubmission,
                          icon: const Icon(Icons.undo),
                          label: const Text('Отменить сдачу'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            side: BorderSide(color: colors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Напишите комментарий к решению...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, color: colors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFile != null ? _selectedFile!.name : 'Прикрепить файл (необязательно)',
                                  style: TextStyle(
                                    color: _selectedFile != null ? colors.onSurface : colors.onSurfaceVariant,
                                    fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton(
                                  icon: Icon(Icons.close, color: colors.error),
                                  onPressed: () => setState(() => _selectedFile = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitWork,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon:
                              _isSubmitting
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: colors.onPrimary, strokeWidth: 2),
                                  )
                                  : const Icon(Icons.send),
                          label: const Text('Сдать работу'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
