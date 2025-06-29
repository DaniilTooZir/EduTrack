import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/group_service.dart';

class ScheduleAdminScreen extends StatefulWidget {
  const ScheduleAdminScreen({super.key});

  @override
  State<ScheduleAdminScreen> createState() => _ScheduleAdminScreenState();
}

class _ScheduleAdminScreenState extends State<ScheduleAdminScreen> {
  late final ScheduleService _scheduleService;
  late final SubjectService _subjectService;
  late final GroupService _groupService;

  late Future<List<Schedule>> _scheduleFuture;
  String? _institutionId;

  final _formKey = GlobalKey<FormState>();

  int? _weekday;
  String? _selectedSubjectId;
  String? _selectedGroupId;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  static const List<String> _weekdays = [
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];

  List<Subject> _subjects = [];
  List<Group> _groups = [];
  Map<String, String> get _subjectNames {
    final map = <String, String>{};
    for (var s in _subjects) {
      if (s.id != null) {
        map[s.id!] = s.name;
      }
    }
    return map;
  }

  Map<String, String> get _groupNames {
    final map = <String, String>{};
    for (var g in _groups) {
      if (g.id != null) {
        map[g.id!] = g.name;
      }
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleService();
    _subjectService = SubjectService();
    _groupService = GroupService();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;

    if (_institutionId != null) {
      _loadSubjects();
      _loadGroups();
      _loadSchedule();
    } else {
      _scheduleFuture = Future.error('ID учреждения не найден');
    }
  }

  void _loadSubjects() async {
    try {
      final subjects = await _subjectService.getSubjectsForInstitution(
        _institutionId!,
      );
      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки предметов: $e');
    }
  }

  void _loadGroups() async {
    try {
      final groups = await _groupService.getGroups(_institutionId!);
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки групп: $e');
    }
  }

  void _loadSchedule() {
    if (_institutionId == null) {
      _scheduleFuture = Future.error('ID учреждения не найден');
    } else {
      _scheduleFuture = _scheduleService.getScheduleForInstitution(
        _institutionId!,
      );
    }
    setState(() {});
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _addScheduleEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_institutionId == null ||
        _selectedSubjectId == null ||
        _selectedGroupId == null ||
        _weekday == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    try {
      await _scheduleService.addScheduleEntry(
        institutionId: _institutionId!,
        subjectId: _selectedSubjectId!,
        weekday: _weekday!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
        groupId: _selectedGroupId!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запись успешно добавлена')));
      _loadSchedule();
      setState(() {
        _formKey.currentState!.reset();
        _weekday = null;
        _selectedSubjectId = null;
        _selectedGroupId = null;
        _startTime = null;
        _endTime = null;
      });
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
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    }
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay) onTimePicked,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
        );
        if (picked != null) onTimePicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time != null ? time.format(context) : 'Выберите время'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'День недели',
                            ),
                            value: _weekday,
                            items: List.generate(
                              _weekdays.length,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text(_weekdays[index]),
                              ),
                            ),
                            onChanged: (val) => setState(() => _weekday = val),
                            validator:
                                (val) =>
                                    val == null ? 'Выберите день недели' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Предмет',
                            ),
                            value: _selectedSubjectId,
                            items:
                                _subjects
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text(s.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) =>
                                    setState(() => _selectedSubjectId = val),
                            validator:
                                (val) =>
                                    val == null ? 'Выберите предмет' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Группа',
                            ),
                            value: _selectedGroupId,
                            items:
                                _groups
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g.id,
                                        child: Text(g.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) => setState(() => _selectedGroupId = val),
                            validator:
                                (val) => val == null ? 'Выберите группу' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTimePicker('Время начала', _startTime, (time) {
                            setState(() => _startTime = time);
                          }),
                          const SizedBox(height: 12),
                          _buildTimePicker('Время окончания', _endTime, (time) {
                            setState(() => _endTime = time);
                          }),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _addScheduleEntry,
                              child: const Text('Добавить запись'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          child: Text(
                            'Ошибка загрузки: ${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }
                      final schedules = snapshot.data ?? [];
                      if (schedules.isEmpty) {
                        return Center(
                          child: Text(
                            'Расписание пустое',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }
                      Map<int, List<Schedule>> schedulesByDay = {};
                      for (var s in schedules) {
                        schedulesByDay.putIfAbsent(s.weekday, () => []).add(s);
                      }
                      return ListView(
                        children: List.generate(7, (day) {
                          final daySchedules = schedulesByDay[day] ?? [];
                          if (daySchedules.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          daySchedules.sort(
                            (a, b) => a.startTime.compareTo(b.startTime),
                          );
                          return ExpansionTile(
                            title: Text(
                              _weekdays[day],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children:
                                daySchedules.map((s) {
                                  final subjectName =
                                      _subjectNames[s.subjectId] ?? s.subjectId;
                                  final groupName =
                                      _groupNames[s.groupId] ?? s.groupId;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(
                                        '$groupName — ${s.startTime} - ${s.endTime}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(subjectName),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed:
                                            () => _deleteScheduleEntry(s.id),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
