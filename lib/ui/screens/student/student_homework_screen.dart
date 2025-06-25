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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки домашних заданий: $e')),
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка обновления статуса: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_homeworks.isEmpty) {
      return const Center(child: Text('Нет домашних заданий.'));
    }
    return ListView.builder(
      itemCount: _homeworks.length,
      itemBuilder: (context, index) {
        final hw = _homeworks[index];
        final isDone = _statuses[hw.id]?.isCompleted ?? false;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(hw.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hw.description?.isNotEmpty == true) Text(hw.description!),
                if (hw.dueDate != null)
                  Text(
                    'Срок: ${hw.dueDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (hw.subject != null)
                  Text(
                    'Предмет: ${hw.subject!.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (hw.group != null)
                  Text(
                    'Группа: ${hw.group!.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleCompletion(hw),
              tooltip:
                  isDone
                      ? 'Отметить как невыполненное'
                      : 'Отметить как выполненное',
            ),
          ),
        );
      },
    );
  }
}
