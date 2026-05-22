import 'dart:async';

import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/teacher_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/messenger_helper.dart';
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

  bool _isLoading = true;
  List<Schedule> _schedules = [];

  String? _institutionId;
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _currentConflictError;
  bool _isCheckingConflict = false;
  bool _conflictChecked = false;
  Timer? _conflictDebounceTimer;
  bool _isCloning = false;

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

  String? _filterGroupId;
  String? _filterTeacherId;

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
    }
  }

  @override
  void dispose() {
    _conflictDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadSubjects() async {
    final result = await _subjectService.getSubjectsForInstitution(_institutionId!);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    setState(() => _subjects = result.data);
  }

  void _loadGroups() async {
    final result = await _groupService.getGroups(_institutionId!);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    setState(() => _groups = result.data);
  }

  void _loadTeachers() async {
    final result = await _teacherService.getTeachers(_institutionId!);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    setState(() => _teachers = result.data);
  }

  Future<void> _loadSchedule() async {
    if (_institutionId == null) return;
    setState(() => _isLoading = true);
    final result = await _scheduleService.getScheduleForInstitution(_institutionId!);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _schedules = result.data;
        _isLoading = false;
      });
    }
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
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      MessengerHelper.showError('Выберите время начала и окончания');
      return;
    }
    if (_timeToMinutes(_endTime!) <= _timeToMinutes(_startTime!)) {
      MessengerHelper.showError('Время окончания должно быть позже времени начала');
      return;
    }
    if (_selectedDate == null) {
      MessengerHelper.showError('Выберите дату занятия');
      return;
    }
    final periods = Provider.of<UserProvider>(context, listen: false).periods;
    if (periods.isNotEmpty) {
      final inPeriod = periods.any((p) => !_selectedDate!.isBefore(p.startDate) && !_selectedDate!.isAfter(p.endDate));
      if (!inPeriod) {
        MessengerHelper.showError(
          'Выбранная дата не входит ни в один учебный период. '
          'Создайте период в настройках или измените дату.',
        );
        return;
      }
    }
    setState(() => _isAdding = true);

    final sTime = _formatTimeOfDay(_startTime!);
    final eTime = _formatTimeOfDay(_endTime!);

    if (!_conflictChecked) {
      final conflictResult = await _scheduleService.checkConflict(
        institutionId: _institutionId!,
        date: _selectedDate!,
        startTime: sTime,
        endTime: eTime,
        teacherId: _selectedTeacherId!,
        groupId: _selectedGroupId!,
      );
      if (conflictResult.isFailure) {
        MessengerHelper.showError(conflictResult.errorMessage);
        if (mounted) setState(() => _isAdding = false);
        return;
      }
      final conflictError = conflictResult.data;
      if (conflictError != null) {
        MessengerHelper.showWarning(conflictError);
        if (mounted) {
          setState(() {
            _currentConflictError = conflictError;
            _isAdding = false;
          });
        }
        return;
      }
    }

    final addResult = await _scheduleService.addScheduleEntry(
      institutionId: _institutionId!,
      subjectId: _selectedSubjectId!,
      groupId: _selectedGroupId!,
      teacherId: _selectedTeacherId!,
      weekday: _selectedDate!.weekday,
      date: _selectedDate!,
      startTime: sTime,
      endTime: eTime,
    );
    if (addResult.isFailure) {
      MessengerHelper.showError(addResult.errorMessage);
      if (mounted) setState(() => _isAdding = false);
      return;
    }

    MessengerHelper.showSuccess('Урок добавлен');
    if (mounted) {
      setState(() {
        _selectedSubjectId = null;
        _selectedGroupId = null;
        _selectedTeacherId = null;
        _currentConflictError = null;
        _conflictChecked = false;
        _isAdding = false;
        _autovalidateMode = AutovalidateMode.disabled;
      });
    }
    await _loadSchedule();
  }

  Future<void> _duplicateSchedule() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Выберите любой день недели-источника',
    );
    if (picked == null || !mounted) return;

    final startOfSource = picked.subtract(Duration(days: picked.weekday - 1));
    final endOfSource = startOfSource.add(const Duration(days: 6));
    final startOfTarget = startOfSource.add(const Duration(days: 7));
    final endOfTarget = startOfSource.add(const Duration(days: 13));

    String fmt(DateTime d) => '${d.day}.${d.month}';
    final sourceRange = '${fmt(startOfSource)}–${fmt(endOfSource)}';
    final targetRange = '${fmt(startOfTarget)}–${fmt(endOfTarget)}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Копирование недели'),
            content: Text('Скопировать занятия с $sourceRange на $targetRange?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Да, копировать')),
            ],
          ),
    );
    if (confirmed != true) return;

    setState(() => _isCloning = true);
    final result = await _scheduleService.copyScheduleToNextWeek(_institutionId!, startOfSource);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      final (:copied, :skipped) = result.data;
      if (skipped > 0) {
        MessengerHelper.showWarning('Скопировано $copied занятий. Пропущено $skipped (конфликт времени).');
      } else {
        MessengerHelper.showSuccess('Расписание скопировано ($copied занятий).');
      }
      await _loadSchedule();
    }
    if (mounted) setState(() => _isCloning = false);
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
                child: Text('Удалить', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      final result = await _scheduleService.deleteScheduleEntry(id);
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        return;
      }
      MessengerHelper.showSuccess('Запись удалена');
      await _loadSchedule();
    }
  }

  Future<void> _showEditDialog(Schedule lesson) async {
    final updated = await showDialog<bool>(
      context: context,
      builder:
          (_) => _EditLessonDialog(
            lesson: lesson,
            subjects: _subjects,
            groups: _groups,
            teachers: _teachers,
            institutionId: _institutionId!,
            scheduleService: _scheduleService,
          ),
    );
    if (updated == true) await _loadSchedule();
  }

  void _scheduleConflictValidation() {
    _conflictDebounceTimer?.cancel();
    _conflictDebounceTimer = Timer(const Duration(milliseconds: 400), _validateConflict);
  }

  Future<void> _validateConflict() async {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _selectedTeacherId == null ||
        _selectedGroupId == null ||
        _institutionId == null) {
      setState(() {
        _currentConflictError = null;
        _conflictChecked = false;
      });
      return;
    }
    if (_timeToMinutes(_endTime!) <= _timeToMinutes(_startTime!)) {
      setState(() {
        _currentConflictError = 'Конец не может быть раньше начала';
        _conflictChecked = false;
      });
      return;
    }
    setState(() {
      _isCheckingConflict = true;
      _conflictChecked = false;
    });
    final result = await _scheduleService.checkConflict(
      institutionId: _institutionId!,
      date: _selectedDate!,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      teacherId: _selectedTeacherId!,
      groupId: _selectedGroupId!,
    );
    if (mounted) {
      setState(() {
        _currentConflictError = result.isSuccess ? result.data : null;
        _isCheckingConflict = false;
        _conflictChecked = result.isSuccess;
      });
    }
  }

  Widget _buildDatePicker(ColorScheme colors) => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        setState(() => _selectedDate = picked);
        _scheduleConflictValidation();
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: 'Дата занятия',
        border: const OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_month, color: colors.primary),
      ),
      child: Text(
        _selectedDate != null
            ? '${_formatDate(_selectedDate!)} (${_getWeekdayName(_selectedDate!.weekday)})'
            : 'Выберите дату',
        style: TextStyle(color: _selectedDate == null ? colors.onSurfaceVariant : colors.onSurface, fontSize: 16),
      ),
    ),
  );

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onTimePicked, ColorScheme colors) =>
      InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
            helpText: label.toUpperCase(),
          );
          if (picked != null) {
            onTimePicked(picked);
            _scheduleConflictValidation();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: Icon(Icons.access_time, color: colors.primary),
          ),
          child: Text(
            time != null ? time.format(context) : '--:--',
            style: TextStyle(color: time == null ? colors.onSurfaceVariant : colors.onSurface),
          ),
        ),
      );

  Widget _buildScheduleList(List<Schedule> source, ColorScheme colors, ThemeData theme) {
    final schedules = List<Schedule>.from(source)..sort((a, b) {
      if (a.date != null && b.date != null) {
        final d = a.date!.compareTo(b.date!);
        if (d != 0) return d;
      }
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.startTime.compareTo(b.startTime);
    });
    final grouped = <String, List<Schedule>>{};
    for (final s in schedules) {
      final header =
          s.date != null ? '${_getWeekdayName(s.weekday)}, ${_formatDate(s.date!)}' : _getWeekdayName(s.weekday);
      grouped.putIfAbsent(header, () => []).add(s);
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final header = grouped.keys.elementAt(index);
        final items = grouped[header]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: colors.surface,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      header,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
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
                          final timeRange = '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}';
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(timeRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              DataCell(Text(groupName)),
                              DataCell(Text(subjectName)),
                              DataCell(SizedBox(width: 100, child: Text(teacherName, overflow: TextOverflow.ellipsis))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: colors.primary, size: 20),
                                      onPressed: () => _showEditDialog(s),
                                      tooltip: 'Редактировать',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: colors.error, size: 20),
                                      onPressed: () => _deleteScheduleEntry(s.id),
                                      tooltip: 'Удалить',
                                    ),
                                  ],
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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedPeriod = Provider.of<UserProvider>(context).selectedPeriod;
    var displayedSchedules =
        selectedPeriod == null
            ? _schedules
            : _schedules
                .where(
                  (s) =>
                      s.date != null &&
                      !s.date!.isBefore(selectedPeriod.startDate) &&
                      !s.date!.isAfter(selectedPeriod.endDate),
                )
                .toList();
    if (_filterGroupId != null) {
      displayedSchedules = displayedSchedules.where((s) => s.groupId == _filterGroupId).toList();
    }
    if (_filterTeacherId != null) {
      displayedSchedules = displayedSchedules.where((s) => s.teacherId == _filterTeacherId).toList();
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
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
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Добавление урока',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primary),
                          ),
                          const SizedBox(height: 16),
                          _buildDatePicker(colors),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePicker(
                                  'Начало',
                                  _startTime,
                                  (t) => setState(() => _startTime = t),
                                  colors,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimePicker('Конец', _endTime, (t) => setState(() => _endTime = t), colors),
                              ),
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
                                  initialValue: _selectedSubjectId,
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
                                  initialValue: _selectedGroupId,
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
                                  onChanged: (val) {
                                    setState(() => _selectedGroupId = val);
                                    _scheduleConflictValidation();
                                  },
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
                            initialValue: _selectedTeacherId,
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
                            onChanged: (val) {
                              setState(() => _selectedTeacherId = val);
                              _scheduleConflictValidation();
                            },
                            validator: (val) => val == null ? 'Преподаватель?' : null,
                          ),
                          if (_isCheckingConflict || _currentConflictError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      _isCheckingConflict
                                          ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                                          : colors.errorContainer.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _isCheckingConflict ? colors.outline : colors.error),
                                ),
                                child: Row(
                                  children: [
                                    _isCheckingConflict
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                        : Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _isCheckingConflict ? 'Проверка наложений...' : _currentConflictError!,
                                        style: TextStyle(
                                          color:
                                              _isCheckingConflict ? colors.onSurfaceVariant : colors.onErrorContainer,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                              ),
                              onPressed: (_isAdding || _currentConflictError != null) ? null : _addScheduleEntry,
                              icon:
                                  _isAdding
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Расписание занятий',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PeriodDropdown(),
                        if (!_isCloning)
                          IconButton.filledTonal(
                            onPressed: _duplicateSchedule,
                            icon: const Icon(Icons.copy_all, size: 20),
                            tooltip: 'Копировать неделю',
                          )
                        else
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_groups.isNotEmpty || _teachers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (_groups.isNotEmpty)
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              decoration: const InputDecoration(
                                labelText: 'Группа',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              initialValue: _filterGroupId,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(child: Text('Все группы')),
                                ..._groups.map(
                                  (g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.name, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _filterGroupId = val),
                            ),
                          ),
                        if (_groups.isNotEmpty && _teachers.isNotEmpty) const SizedBox(width: 12),
                        if (_teachers.isNotEmpty)
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              decoration: const InputDecoration(
                                labelText: 'Преподаватель',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              initialValue: _filterTeacherId,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem(child: Text('Все преп.')),
                                ..._teachers.map(
                                  (t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text('${t.surname} ${t.name}', overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setState(() => _filterTeacherId = val),
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadSchedule,
                    child:
                        _isLoading
                            ? _buildScheduleListSkeleton()
                            : displayedSchedules.isEmpty
                            ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Text(
                                      _schedules.isEmpty
                                          ? 'Расписание пустое'
                                          : (_filterGroupId != null || _filterTeacherId != null)
                                          ? 'Нет занятий по выбранным фильтрам'
                                          : 'Нет занятий в выбранном периоде',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : _buildScheduleList(displayedSchedules, colors, theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleListSkeleton() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Skeleton(height: 18, width: 18, borderRadius: 4),
                      SizedBox(width: 8),
                      Skeleton(height: 16, width: 180),
                    ],
                  ),
                  const Divider(),
                  ...List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Skeleton(height: 13, width: 65),
                          SizedBox(width: 15),
                          Skeleton(height: 13, width: 55),
                          SizedBox(width: 15),
                          Skeleton(height: 13, width: 90),
                          SizedBox(width: 15),
                          Skeleton(height: 13, width: 110),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _EditLessonDialog extends StatefulWidget {
  final Schedule lesson;
  final List<Subject> subjects;
  final List<Group> groups;
  final List<Teacher> teachers;
  final String institutionId;
  final ScheduleService scheduleService;

  const _EditLessonDialog({
    required this.lesson,
    required this.subjects,
    required this.groups,
    required this.teachers,
    required this.institutionId,
    required this.scheduleService,
  });

  @override
  State<_EditLessonDialog> createState() => _EditLessonDialogState();
}

class _EditLessonDialogState extends State<_EditLessonDialog> {
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _subjectId;
  late String _groupId;
  late String _teacherId;

  String? _conflictError;
  bool _isCheckingConflict = false;
  bool _conflictChecked = false;
  bool _isSaving = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final l = widget.lesson;
    _date = l.date ?? DateTime.now();
    _startTime = _parseTime(l.startTime);
    _endTime = _parseTime(l.endTime);
    _subjectId = l.subjectId;
    _groupId = l.groupId;
    _teacherId = l.teacherId;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  void _scheduleConflictValidation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _validateConflict);
  }

  Future<void> _validateConflict() async {
    if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
      setState(() {
        _conflictError = 'Конец не может быть раньше начала';
        _conflictChecked = false;
      });
      return;
    }
    setState(() {
      _isCheckingConflict = true;
      _conflictChecked = false;
    });
    final result = await widget.scheduleService.checkConflict(
      institutionId: widget.institutionId,
      date: _date,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      teacherId: _teacherId,
      groupId: _groupId,
      excludeId: widget.lesson.id,
    );
    if (mounted) {
      setState(() {
        _conflictError = result.isSuccess ? result.data : null;
        _isCheckingConflict = false;
        _conflictChecked = result.isSuccess;
      });
    }
  }

  Future<void> _save() async {
    if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
      MessengerHelper.showError('Время окончания должно быть позже времени начала');
      return;
    }
    setState(() => _isSaving = true);

    final startTime = _formatTimeOfDay(_startTime);
    final endTime = _formatTimeOfDay(_endTime);

    if (!_conflictChecked) {
      final conflictResult = await widget.scheduleService.checkConflict(
        institutionId: widget.institutionId,
        date: _date,
        startTime: startTime,
        endTime: endTime,
        teacherId: _teacherId,
        groupId: _groupId,
        excludeId: widget.lesson.id,
      );
      if (!mounted) return;
      if (conflictResult.isFailure) {
        MessengerHelper.showError(conflictResult.errorMessage);
        setState(() => _isSaving = false);
        return;
      }
      final conflict = conflictResult.data;
      if (conflict != null) {
        MessengerHelper.showWarning(conflict);
        setState(() {
          _conflictError = conflict;
          _isSaving = false;
        });
        return;
      }
    }

    final result = await widget.scheduleService.updateScheduleEntry(
      id: widget.lesson.id,
      subjectId: _subjectId,
      groupId: _groupId,
      teacherId: _teacherId,
      date: _date,
      weekday: _date.weekday,
      startTime: startTime,
      endTime: endTime,
    );
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      setState(() => _isSaving = false);
      return;
    }
    MessengerHelper.showSuccess('Урок обновлён');
    Navigator.pop(context, true);
  }

  Widget _buildTimePicker(String label, TimeOfDay time, ValueChanged<TimeOfDay> onPicked) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time, helpText: label.toUpperCase());
        if (picked != null) {
          onPicked(picked);
          _scheduleConflictValidation();
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time, color: colors.primary),
        ),
        child: Text(time.format(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Редактировать урок'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && mounted) {
                    setState(() => _date = picked);
                    _scheduleConflictValidation();
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Дата',
                    border: const OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month, color: colors.primary),
                  ),
                  child: Text(
                    '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Начало', _startTime, (t) => setState(() => _startTime = t))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Конец', _endTime, (t) => setState(() => _endTime = t))),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Предмет', border: OutlineInputBorder(), isDense: true),
                initialValue: _subjectId,
                isExpanded: true,
                items:
                    widget.subjects
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _subjectId = val);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Группа', border: OutlineInputBorder(), isDense: true),
                initialValue: _groupId,
                isExpanded: true,
                items:
                    widget.groups
                        .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _groupId = val);
                    _scheduleConflictValidation();
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Преподаватель',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                initialValue: _teacherId,
                isExpanded: true,
                items:
                    widget.teachers
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('${t.surname} ${t.name}', overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _teacherId = val);
                    _scheduleConflictValidation();
                  }
                },
              ),
              if (_isCheckingConflict || _conflictError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _isCheckingConflict
                              ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                              : colors.errorContainer.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isCheckingConflict ? colors.outline : colors.error),
                    ),
                    child: Row(
                      children: [
                        _isCheckingConflict
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isCheckingConflict ? 'Проверка наложений...' : _conflictError!,
                            style: TextStyle(
                              color: _isCheckingConflict ? colors.onSurfaceVariant : colors.onErrorContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(
          onPressed: (_isSaving || _conflictError != null || _isCheckingConflict) ? null : _save,
          child:
              _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сохранить'),
        ),
      ],
    );
  }
}
