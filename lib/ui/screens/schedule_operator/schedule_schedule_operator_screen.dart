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
  State<ScheduleScheduleOperatorScreen> createState() => _ScheduleScheduleOperatorScreen();
}

class _ScheduleScheduleOperatorScreen extends State<ScheduleScheduleOperatorScreen> {
  late final ScheduleService _scheduleService;
  late final SubjectService _subjectService;
  late final GroupService _groupService;
  late final TeacherService _teacherService;

  late Future<List<Schedule>> _scheduleFuture;
  String? _institutionId;

  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
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

  @override
  void initState() {
    super.initState();
    _scheduleService = ScheduleService();
    _subjectService = SubjectService();
    _groupService = GroupService();
    _teacherService = TeacherService();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;
    _selectedDate = DateTime.now();

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
      final subjects = await _subjectService.getSubjectsForInstitution(_institutionId!);
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
      _scheduleFuture = _scheduleService.getScheduleForInstitution(_institutionId!);
    }
    setState(() {});
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  String _getWeekdayName(int weekday) {
    if (weekday >= 1 && weekday <= 7) return _weekdays[weekday - 1];
    return 'Неизвестно';
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _addScheduleEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите время начала и окончания')));
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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите дату занятия')));
      return;
    }
    setState(() => _isAdding = true);
    try {
      final sTime = _formatTimeOfDay(_startTime!);
      final eTime = _formatTimeOfDay(_endTime!);
      final conflictError = await _scheduleService.checkConflict(
        institutionId: _institutionId!,
        date: _selectedDate!,
        startTime: sTime,
        endTime: eTime,
        teacherId: _selectedTeacherId!,
        groupId: _selectedGroupId!,
      );
      if (conflictError != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(conflictError)),
              ],
            ),
            backgroundColor: Colors.orange[800],
          ),
        );
        setState(() => _isAdding = false);
        return;
      }

      final int targetWeekday = _selectedDate!.weekday;
      await _scheduleService.addScheduleEntry(
        institutionId: _institutionId!,
        subjectId: _selectedSubjectId!,
        groupId: _selectedGroupId!,
        teacherId: _selectedTeacherId!,
        weekday: targetWeekday,
        date: _selectedDate!,
        startTime: _formatTimeOfDay(_startTime!),
        endTime: _formatTimeOfDay(_endTime!),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Урок добавлен'), backgroundColor: Colors.green));
      _loadSchedule();
      setState(() {
        _selectedSubjectId = null;
        _selectedGroupId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при добавлении: $e'), backgroundColor: Colors.redAccent));
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
            content: const Text('Вы уверены, что хотите удалить этот урок?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _scheduleService.deleteScheduleEntry(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Запись удалена')));
        _loadSchedule();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Widget _buildDatePicker() => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) setState(() => _selectedDate = picked);
    },
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Дата занятия',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_month, color: Color(0xFF5E35B1)),
      ),
      child: Text(
        _selectedDate != null
            ? '${_formatDate(_selectedDate!)} (${_getWeekdayName(_selectedDate!.weekday)})'
            : 'Выберите дату',
        style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black, fontSize: 16),
      ),
    ),
  );

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onTimePicked) => InkWell(
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
        time != null ? time.format(context) : '--:--',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Добавление урока',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5E35B1)),
                          ),
                          const SizedBox(height: 16),
                          _buildDatePicker(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePicker('Начало', _startTime, (t) => setState(() => _startTime = t)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTimePicker('Конец', _endTime, (t) => setState(() => _endTime = t))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Предмет',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  value: _selectedSubjectId,
                                  isExpanded: true,
                                  items:
                                      _subjects
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.name, overflow: TextOverflow.ellipsis),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) => setState(() => _selectedSubjectId = val),
                                  validator: (val) => val == null ? 'Предмет?' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Группа',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  value: _selectedGroupId,
                                  isExpanded: true,
                                  items:
                                      _groups
                                          .map(
                                            (g) => DropdownMenuItem(
                                              value: g.id,
                                              child: Text(g.name, overflow: TextOverflow.ellipsis),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) => setState(() => _selectedGroupId = val),
                                  validator: (val) => val == null ? 'Группа?' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Преподаватель',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            value: _selectedTeacherId,
                            isExpanded: true,
                            items:
                                _teachers
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text('${t.surname} ${t.name}', overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) => setState(() => _selectedTeacherId = val),
                            validator: (val) => val == null ? 'Преподаватель?' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: const Color(0xFF5E35B1),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _isAdding ? null : _addScheduleEntry,
                              icon:
                                  _isAdding
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                      : const Icon(Icons.add),
                              label: const Text('Добавить в расписание'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Расписание занятий',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<Schedule>>(
                    future: _scheduleFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                        );
                      }
                      final schedules = snapshot.data ?? [];
                      if (schedules.isEmpty) {
                        return const Center(child: Text('Расписание пустое', style: TextStyle(color: Colors.grey)));
                      }
                      schedules.sort((a, b) {
                        if (a.date != null && b.date != null) {
                          final d = a.date!.compareTo(b.date!);
                          if (d != 0) return d;
                        }
                        if (a.date == null) return 1;
                        if (b.date == null) return -1;

                        return a.startTime.compareTo(b.startTime);
                      });
                      final Map<String, List<Schedule>> grouped = {};
                      for (final s in schedules) {
                        String header;
                        final String dayName = _getWeekdayName(s.weekday);
                        if (s.date != null) {
                          header = '$dayName, ${_formatDate(s.date!)}';
                        } else {
                          header = dayName;
                        }
                        grouped.putIfAbsent(header, () => []).add(s);
                      }
                      return ListView.builder(
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final header = grouped.keys.elementAt(index);
                          final items = grouped[header]!;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white.withOpacity(0.9),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18, color: Color(0xFF5E35B1)),
                                      const SizedBox(width: 8),
                                      Text(
                                        header,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF5E35B1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 15,
                                      horizontalMargin: 5,
                                      headingRowHeight: 30,
                                      dataRowMinHeight: 40,
                                      columns: const [
                                        DataColumn(label: Text('Время')),
                                        DataColumn(label: Text('Группа')),
                                        DataColumn(label: Text('Предмет')),
                                        DataColumn(label: Text('Препод.')),
                                        DataColumn(label: Text('')),
                                      ],
                                      rows:
                                          items.map((s) {
                                            final subjectName = s.subject?.name ?? '—';
                                            final groupName = s.group?.name ?? '—';
                                            final teacherName = s.teacherName;
                                            final timeRange =
                                                '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}';
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    timeRange,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ),
                                                DataCell(Text(groupName)),
                                                DataCell(Text(subjectName)),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(teacherName, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                                DataCell(
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                    onPressed: () => _deleteScheduleEntry(s.id),
                                                    tooltip: 'Удалить',
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
