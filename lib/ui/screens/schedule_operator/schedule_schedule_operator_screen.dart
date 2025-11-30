import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/teacher_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScheduleOperatorScreen extends StatefulWidget {
  const ScheduleScheduleOperatorScreen({super.key});

  @override
  State<ScheduleScheduleOperatorScreen> createState() =>
      _ScheduleScheduleOperatorScreen();
}

class _ScheduleScheduleOperatorScreen
    extends State<ScheduleScheduleOperatorScreen> {
  late final ScheduleService _scheduleService;
  late final SubjectService _subjectService;
  late final GroupService _groupService;
  late final TeacherService _teacherService;

  late Future<List<Schedule>> _scheduleFuture;
  String? _institutionId;

  final _formKey = GlobalKey<FormState>();

  int? _weekday;
  String? _selectedSubjectId;
  String? _selectedGroupId;
  String? _selectedTeacherId;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isAdding = false;

  List<Subject> _subjects = [];
  List<Group> _groups = [];
  List<Teacher> _teachers = [];

  static const List<String> _weekdays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  Map<String, String> get _teacherNames => {
    for (final t in _teachers)
      if (t.id.isNotEmpty) t.id: '${t.surname} ${t.name}',
  };

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleService();
    _subjectService = SubjectService();
    _groupService = GroupService();
    _teacherService = TeacherService();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;

    if (_institutionId != null) {
      _loadSubjects();
      _loadGroups();
      _loadTeachers();
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
      setState(() => _subjects = subjects);
    } catch (e) {
      debugPrint('Ошибка загрузки предметов: $e');
    }
  }

  void _loadGroups() async {
    try {
      final groups = await _groupService.getGroups(_institutionId!);
      setState(() => _groups = groups);
    } catch (e) {
      debugPrint('Ошибка загрузки групп: $e');
    }
  }

  void _loadTeachers() async {
    try {
      final teachers = await _teacherService.getTeachers(_institutionId!);
      setState(() => _teachers = teachers);
    } catch (e) {
      debugPrint('Ошибка загрузки преподавателей: $e');
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

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _addScheduleEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите время начала и окончания')),
      );
      return;
    }

    if (_timeToMinutes(_endTime!) <= _timeToMinutes(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Время окончания должно быть позже времени начала'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);
    try {
      final now = DateTime.now();
      final todayWeekday = now.weekday;
      final targetWeekday = _weekday! + 1;
      int daysToAdd = (targetWeekday - todayWeekday + 7) % 7;
      if (daysToAdd == 0) daysToAdd = 0;

      final selectedDate = now.add(Duration(days: daysToAdd));
      await _scheduleService.addScheduleEntry(
        institutionId: _institutionId!,
        subjectId: _selectedSubjectId!,
        groupId: _selectedGroupId!,
        teacherId: _selectedTeacherId!,
        weekday: targetWeekday,
        date: selectedDate,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запись успешно добавлена'),
          backgroundColor: Colors.green,
        ),
      );

      _loadSchedule();
      setState(() {
        _selectedSubjectId = null;
        _selectedGroupId = null;
        _selectedTeacherId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при добавлении: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteScheduleEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить запись?'),
            content: const Text(
              'Вы уверены, что хотите удалить этот урок из расписания?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _scheduleService.deleteScheduleEntry(id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Запись удалена')));
        _loadSchedule();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay? time,
    Function(TimeOfDay) onTimePicked,
  ) => InkWell(
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
        helpText: label.toUpperCase(),
      );
      if (picked != null) onTimePicked(picked);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      child: Text(
        time != null ? time.format(context) : 'Выберите время',
        style: TextStyle(color: time == null ? Colors.grey : Colors.black),
      ),
    ),
  );

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
                              border: OutlineInputBorder(),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePicker(
                                  'Начало',
                                  _startTime,
                                  (t) => setState(() => _startTime = t),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimePicker(
                                  'Конец',
                                  _endTime,
                                  (t) => setState(() => _endTime = t),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Предмет',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedSubjectId,
                            isExpanded: true,
                            items:
                                _subjects
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s.id,
                                        child: Text(
                                          s.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                              border: OutlineInputBorder(),
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
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Преподаватель',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTeacherId,
                            isExpanded: true,
                            items:
                                _teachers
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text(
                                          '${t.surname} ${t.name}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) =>
                                    setState(() => _selectedTeacherId = val),
                            validator:
                                (val) =>
                                    val == null
                                        ? 'Выберите преподавателя'
                                        : null,
                          ),
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
                                backgroundColor: const Color(0xFF5E35B1),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _isAdding ? null : _addScheduleEntry,
                              child:
                                  _isAdding
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text('Добавить запись'),
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
                      final Map<int, List<Schedule>> schedulesByDay = {};
                      for (final s in schedules) {
                        schedulesByDay.putIfAbsent(s.weekday, () => []).add(s);
                      }
                      final sortedDays = schedulesByDay.keys.toList()..sort();
                      return ListView.builder(
                        itemCount: sortedDays.length,
                        itemBuilder: (context, index) {
                          final day = sortedDays[index];
                          final daySchedules = schedulesByDay[day]!;
                          daySchedules.sort(
                            (a, b) => a.startTime.compareTo(b.startTime),
                          );
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white.withOpacity(0.9),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _weekdays[day -
                                        1], // day 1..7 -> index 0..6
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF5E35B1),
                                        ),
                                  ),
                                  const Divider(),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 20,
                                      horizontalMargin: 10,
                                      columns: const [
                                        DataColumn(label: Text('Время')),
                                        DataColumn(label: Text('Группа')),
                                        DataColumn(label: Text('Предмет')),
                                        DataColumn(
                                          label: Text('Преподаватель'),
                                        ),
                                        DataColumn(label: Text('')),
                                      ],
                                      rows:
                                          daySchedules.map((s) {
                                            final subjectName =
                                                s.subject?.name ?? '—';
                                            final groupName =
                                                s.group?.name ?? '—';
                                            final teacherName =
                                                _teacherNames[s.teacherId] ??
                                                '—';
                                            final timeRange =
                                                '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}';
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    timeRange,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(Text(groupName)),
                                                DataCell(Text(subjectName)),
                                                DataCell(Text(teacherName)),
                                                DataCell(
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                      size: 20,
                                                    ),
                                                    onPressed:
                                                        () =>
                                                            _deleteScheduleEntry(
                                                              s.id,
                                                            ),
                                                    tooltip: 'Удалить урок',
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }
}
