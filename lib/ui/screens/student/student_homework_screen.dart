import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  late final HomeworkService _homeworkService;
  final _studentService = StudentService();
  bool _isLoading = true;
  List<Homework> _homeworks = [];
  Map<String, HomeworkStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _homeworkService = HomeworkService();
    _loadHomework();
  }

  Future<void> _loadHomework() async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    setState(() => _isLoading = true);
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

  Future<void> _toggleCompletion(Homework homework) async {
    final studentId = Provider.of<UserProvider>(context, listen: false).userId;
    if (studentId == null) return;
    final current = _statuses[homework.id];
    final isCompleted = !(current?.isCompleted ?? false);
    try {
      await _homeworkService.setHomeworkCompletion(
        homeworkId: homework.id,
        studentId: studentId,
        isCompleted: isCompleted,
      );
      setState(() {
        if (current != null) {
          _statuses[homework.id] = HomeworkStatus(
            id: current.id,
            homeworkId: current.homeworkId,
            studentId: current.studentId,
            isCompleted: isCompleted,
            updatedAt: DateTime.now(),
          );
        } else {
          _loadHomework();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Не удалось открыть ссылку';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка открытия: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
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
            final isDone = _statuses[hw.id]?.isCompleted ?? false;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colors.surface.withOpacity(0.9),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _toggleCompletion(hw),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isDone ? Colors.green : colors.onSurfaceVariant,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hw.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? colors.onSurface.withOpacity(0.5) : colors.onSurface,
                              ),
                            ),
                            if (hw.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 6),
                              Text(hw.description!, style: TextStyle(color: colors.onSurfaceVariant)),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (hw.dueDate != null)
                                  _InfoChip(
                                    icon: Icons.calendar_today,
                                    label: hw.dueDate!.toLocal().toString().split(' ')[0],
                                    color: colors.primaryContainer.withOpacity(0.5),
                                    textColor: colors.onPrimaryContainer,
                                  ),
                                if (hw.subject != null)
                                  _InfoChip(
                                    icon: Icons.book,
                                    label: hw.subject!.name,
                                    color: colors.secondaryContainer.withOpacity(0.5),
                                    textColor: colors.onSecondaryContainer,
                                  ),
                                if (hw.fileUrl != null)
                                  _InfoChip(
                                    icon: Icons.attach_file,
                                    label: hw.fileName ?? 'Файл',
                                    isAction: true,
                                    onTap: () => _openFile(hw.fileUrl!),
                                    color: colors.tertiaryContainer.withOpacity(0.5),
                                    textColor: colors.onTertiaryContainer,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAction;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isAction = false,
    this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: isAction ? Border.all(color: textColor.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: content);
    }
    return content;
  }
}
