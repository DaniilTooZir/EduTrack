import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/data/services/schedule_service.dart';

class ScheduleAdminScreen extends StatefulWidget {
  const ScheduleAdminScreen({super.key});

  @override
  State<ScheduleAdminScreen> createState() => _ScheduleAdminScreenState();
}

class _ScheduleAdminScreenState extends State<ScheduleAdminScreen> {
  late final ScheduleService _scheduleService;
  late Future<List<Schedule>> _scheduleFuture;
  String? _institutionId;

  final _formKey = GlobalKey<FormState>();
  int? _weekday;
  String? _subjectId;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _classGroupController = TextEditingController();

  static const List<String> _weekdays = [
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;

    _loadSchedule();
  }

  void _loadSchedule() {
    if (_institutionId == null) {
      _scheduleFuture = Future.error('ID учреждения не найден');
    } else {
      _scheduleFuture = _scheduleService.getScheduleForInstitution(
        _institutionId!,
      );
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _classGroupController.dispose();
    super.dispose();
  }

  Future<void> _addScheduleEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null || _subjectId == null || _weekday == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final institutionId = userProvider.institutionId;
    if (institutionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: Не удалось получить ID учреждения')),
      );
      return;
    }
    try {
      await _scheduleService.addScheduleEntry(
        institutionId: institutionId,
        subjectId: _subjectId!,
        weekday: _weekday!,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        classGroup: _classGroupController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запись успешно добавлена')));
      _loadSchedule();
      setState(() {});
      _formKey.currentState!.reset();
      _startTimeController.clear();
      _endTimeController.clear();
      _classGroupController.clear();
      _weekday = null;
      _subjectId = null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при добавлении: $e')));
    }
  }

  Future<void> _deleteScheduleEntry(String id) async {
    try {
      await _scheduleService.deleteScheduleEntry(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запись удалена')));
      _loadSchedule();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление расписанием')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'День недели'),
                    items: List.generate(
                      _weekdays.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(_weekdays[index]),
                      ),
                    ),
                    value: _weekday,
                    onChanged: (val) => setState(() => _weekday = val),
                    validator:
                        (val) => val == null ? 'Выберите день недели' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'ID предмета'),
                    onChanged: (val) => _subjectId = val,
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Введите ID предмета'
                                : null,
                  ),
                  TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Время начала (HH:mm:ss)',
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Введите время начала'
                                : null,
                  ),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Время окончания (HH:mm:ss)',
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Введите время окончания'
                                : null,
                  ),
                  TextFormField(
                    controller: _classGroupController,
                    decoration: const InputDecoration(
                      labelText: 'Класс/группа',
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Введите класс/группу'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addScheduleEntry,
                    child: const Text('Добавить запись'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Schedule>>(
                future: _scheduleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка загрузки: ${snapshot.error}'),
                    );
                  }
                  final schedules = snapshot.data ?? [];
                  if (schedules.isEmpty) {
                    return const Center(child: Text('Расписание пустое'));
                  }
                  schedules.sort((a, b) {
                    final cmp = a.weekday.compareTo(b.weekday);
                    if (cmp != 0) return cmp;
                    return a.startTime.compareTo(b.startTime);
                  });
                  return ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final s = schedules[index];
                      return ListTile(
                        title: Text(
                          '${_weekdays[s.weekday]}, ${s.classGroup} — ${s.startTime} - ${s.endTime}',
                        ),
                        subtitle: Text('ID предмета: ${s.subjectId}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteScheduleEntry(s.id),
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
    );
  }
}
