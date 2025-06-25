import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/providers/user_provider.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = true;
  List<Schedule> _scheduleList = [];

  final List<String> _weekdays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final teacherId = Provider.of<UserProvider>(context, listen: false).userId;
    if (teacherId == null) return;

    final schedule = await _scheduleService.getScheduleForTeacher(teacherId);
    setState(() {
      _scheduleList = schedule;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_scheduleList.isEmpty) {
      return const Center(child: Text('Расписание не найдено.'));
    }
    return ListView.builder(
      itemCount: _scheduleList.length,
      itemBuilder: (context, index) {
        final entry = _scheduleList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(entry.subjectName ?? 'Предмет'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Группа: ${entry.groupName}'),
                Text('День: ${_weekdays[entry.weekday - 1]}'),
                Text('Время: ${entry.startTime} - ${entry.endTime}'),
              ],
            ),
          ),
        );
      },
    );
  }
}