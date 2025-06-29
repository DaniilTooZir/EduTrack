import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/providers/user_provider.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  late final HomeworkService _homeworkService;
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
    setState(() {
      _isLoading = true;
    });
    try {
      final homeworks = await _homeworkService.getHomeworksByStudentGroup(
        studentId,
      );
      final statuses = await _homeworkService.getHomeworkStatusesForStudent(
        studentId,
      );
      setState(() {
        _homeworks = homeworks;
        _statuses = {for (var s in statuses) s.homeworkId: s};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки домашних заданий: $e'),
            backgroundColor: Colors.redAccent,
          ),
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
      await _loadHomework();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления статуса: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_homeworks.isEmpty) {
      return Center(
        child: Text(
          'Нет домашних заданий.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
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
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.85),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.purple.withOpacity(0.3),
                onTap: () => _toggleCompletion(hw),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isDone ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hw.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (hw.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 6),
                              Text(
                                hw.description!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                if (hw.dueDate != null)
                                  _InfoChip(
                                    icon: Icons.calendar_today,
                                    label:
                                        'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                                  ),
                                if (hw.subject != null)
                                  _InfoChip(
                                    icon: Icons.book,
                                    label: 'Предмет: ${hw.subject!.name}',
                                  ),
                                if (hw.group != null)
                                  _InfoChip(
                                    icon: Icons.group,
                                    label: 'Группа: ${hw.group!.name}',
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
  const _InfoChip({Key? key, required this.icon, required this.label})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.purple[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
