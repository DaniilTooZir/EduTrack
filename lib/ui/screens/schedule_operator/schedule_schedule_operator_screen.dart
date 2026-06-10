import 'dart:async';

import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/room_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/data/services/teacher_service.dart';
import 'package:edu_track/data/services/time_grid_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/models/room.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/models/time_grid.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/ui/widgets/period_dropdown.dart';
import 'package:edu_track/ui/widgets/skeleton.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/data_loading_mixin.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScheduleOperatorScreen extends StatefulWidget {
  const ScheduleScheduleOperatorScreen({super.key});

  @override
  State<ScheduleScheduleOperatorScreen> createState() => _ScheduleScheduleOperatorScreen();
}

class _ScheduleScheduleOperatorScreen extends State<ScheduleScheduleOperatorScreen> with DataLoadingMixin {
  late final ScheduleRepository _scheduleService;
  late final SubjectService _subjectService;
  late final GroupService _groupService;
  late final TeacherService _teacherService;
  late final TimeGridService _timeGridService;
  late final RoomService _roomService;

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
  String? _selectedRoomId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isAdding = false;
  bool _isFormExpanded = true;
  List<Subject> _subjects = [];
  List<Group> _groups = [];
  List<Teacher> _teachers = [];
  List<Room> _rooms = [];
  List<TimeGrid> _timeGrids = [];
  String? _selectedGridId;

  String? _filterGroupId;
  String? _filterTeacherId;

  Map<String, List<Schedule>> _groupedSchedule = {};
  Map<String, List<Schedule>> _groupedPastSchedule = {};
  bool _showPastSchedule = false;
  AcademicPeriod? _lastPeriod;

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
    _scheduleService = Provider.of<ScheduleRepository>(context, listen: false);
    _subjectService = SubjectService();
    _groupService = GroupService();
    _teacherService = TeacherService();
    _timeGridService = TimeGridService();
    _roomService = RoomService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _institutionId = userProvider.institutionId;
    _selectedDate = DateTime.now();

    if (_institutionId != null) {
      _loadSubjects();
      _loadGroups();
      _loadTeachers();
      _loadRooms();
      _loadSchedule();
      _loadTimeGrids();
    }
  }

  @override
  void dispose() {
    _conflictDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    if (period != _lastPeriod) {
      _lastPeriod = period;
      _loadSchedule();
    }
  }

  void _rebuildGrouped() {
    var filtered = _schedules;
    if (_filterGroupId != null) {
      filtered = filtered.where((s) => s.groupId == _filterGroupId).toList();
    }
    if (_filterTeacherId != null) {
      filtered = filtered.where((s) => s.teacherId == _filterTeacherId).toList();
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final grouped = <String, List<Schedule>>{};
    final groupedPast = <String, List<Schedule>>{};
    for (final s in filtered) {
      final header =
          s.date != null ? '${_getWeekdayName(s.weekday)}, ${formatDate(s.date!)}' : _getWeekdayName(s.weekday);
      final isPast = s.date != null && s.date!.isBefore(todayDate);
      if (isPast) {
        groupedPast.putIfAbsent(header, () => []).add(s);
      } else {
        grouped.putIfAbsent(header, () => []).add(s);
      }
    }
    _groupedSchedule = grouped;
    _groupedPastSchedule = groupedPast;
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

  void _loadRooms() async {
    final result = await _roomService.getRoomsForInstitution(_institutionId!);
    if (!mounted) return;
    if (result.isSuccess) setState(() => _rooms = result.data);
  }

  void _loadTimeGrids() async {
    final result = await _timeGridService.getGridsForInstitution(_institutionId!);
    if (!mounted) return;
    if (result.isSuccess) setState(() => _timeGrids = result.data);
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildSlotChips(ColorScheme colors) {
    if (_timeGrids.isEmpty) return const SizedBox.shrink();
    final activeGrid = _timeGrids.firstWhere(
      (g) => g.id == (_selectedGridId ?? _timeGrids.first.id),
      orElse: () => _timeGrids.first,
    );
    if (activeGrid.slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_timeGrids.length > 1) ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Сетка времени', border: OutlineInputBorder(), isDense: true),
            initialValue: _selectedGridId ?? _timeGrids.first.id,
            items: _timeGrids.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
            onChanged: (val) => setState(() => _selectedGridId = val),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        Text('Быстрый выбор:', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children:
              activeGrid.slots.map((slot) {
                final chipLabel = slot.label != null ? '${slot.label}\n${slot.timeRange}' : slot.timeRange;
                return ActionChip(
                  label: Text(chipLabel, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  onPressed: () {
                    setState(() {
                      _startTime = _parseTimeOfDay(slot.startTime);
                      _endTime = _parseTimeOfDay(slot.endTime);
                    });
                    _scheduleConflictValidation();
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }

  Future<void> _loadSchedule() async {
    if (_institutionId == null) return;
    final period = Provider.of<UserProvider>(context, listen: false).selectedPeriod;
    await loadAsync(
      _scheduleService.getScheduleForInstitution(
        _institutionId!,
        startDate: period?.startDate,
        endDate: period?.endDate,
      ),
      onSuccess: (data) {
        data.sort((a, b) {
          if (a.date != null && b.date != null) {
            final d = a.date!.compareTo(b.date!);
            if (d != 0) return d;
          }
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.startTime.compareTo(b.startTime);
        });
        _schedules = data;
        _rebuildGrouped();
      },
    );
  }

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

    final sTime = formatTimeOfDaySec(_startTime!);
    final eTime = formatTimeOfDaySec(_endTime!);

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
      date: _selectedDate!,
      startTime: sTime,
      endTime: eTime,
      roomId: _selectedRoomId,
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
        _selectedRoomId = null;
        _currentConflictError = null;
        _conflictChecked = false;
        _isAdding = false;
        _autovalidateMode = AutovalidateMode.disabled;
      });
    }
    await _loadSchedule();
  }

  Future<void> _duplicateSchedule() async {
    final result = await showDialog<(DateTime, DateTime)>(context: context, builder: (_) => const _CopyWeekDialog());
    if (result == null || !mounted) return;

    final (sourceDate, targetDate) = result;
    final startOfSource = sourceDate.subtract(Duration(days: sourceDate.weekday - 1));
    final startOfTarget = targetDate.subtract(Duration(days: targetDate.weekday - 1));

    if (startOfTarget == startOfSource) {
      MessengerHelper.showError('Нельзя скопировать неделю саму на себя');
      return;
    }

    setState(() => _isCloning = true);
    final cloneResult = await _scheduleService.copyScheduleToWeek(_institutionId!, startOfSource, startOfTarget);
    if (cloneResult.isFailure) {
      MessengerHelper.showError(cloneResult.errorMessage);
    } else {
      final (:copied, :skipped) = cloneResult.data;
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
    if (confirmed != true || !mounted) return;
    final result = await _scheduleService.deleteScheduleEntry(id);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    MessengerHelper.showSuccess('Запись удалена');
    await _loadSchedule();
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
            rooms: _rooms,
            institutionId: _institutionId!,
            scheduleService: _scheduleService,
            timeGrids: _timeGrids,
          ),
    );
    if (updated == true && mounted) await _loadSchedule();
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
      startTime: formatTimeOfDaySec(_startTime!),
      endTime: formatTimeOfDaySec(_endTime!),
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
            ? '${formatDate(_selectedDate!)} (${_getWeekdayName(_selectedDate!.weekday)})'
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

  SliverPadding _buildScheduleSliver(ColorScheme colors, ThemeData theme) {
    final entries = _groupedSchedule.entries.toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      sliver: SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final header = entries[index].key;
          final items = entries[index].value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: colors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          header,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...items.asMap().entries.map(
                    (e) => _buildLessonTile(e.value, colors, isLast: e.key == items.length - 1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPastScheduleSection(ColorScheme colors, ThemeData theme) {
    final entries = _groupedPastSchedule.entries.toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _showPastSchedule = !_showPastSchedule),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      _showPastSchedule ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Прошедшие занятия',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_groupedPastSchedule.values.fold(0, (sum, l) => sum + l.length)}',
                        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child:
                  _showPastSchedule
                      ? Opacity(
                        opacity: 0.6,
                        child: Column(
                          children:
                              entries.map((entry) {
                                final header = entry.key;
                                final items = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: colors.surface,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.history, size: 18, color: colors.onSurfaceVariant),
                                              const SizedBox(width: 8),
                                              Text(
                                                header,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        ...items.asMap().entries.map(
                                          (e) => _buildLessonTile(e.value, colors, isLast: e.key == items.length - 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile(Schedule s, ColorScheme colors, {required bool isLast}) {
    final timeRange = '${s.startTime.substring(0, 5)} – ${s.endTime.substring(0, 5)}';
    final subjectName = s.subject?.name ?? '—';
    final groupName = s.group?.name ?? '—';
    final teacherName = s.teacherName;
    final roomName = s.roomName;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  timeRange,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subjectName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$groupName · $teacherName${roomName != null ? ' · $roomName' : ''}',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colors.primary, size: 20),
                onPressed: () => _showEditDialog(s),
                tooltip: 'Редактировать',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                onPressed: () => _deleteScheduleEntry(s.id),
                tooltip: 'Удалить',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 12, endIndent: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadSchedule,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 0),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                      clipBehavior: Clip.antiAlias,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autovalidateMode,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _isFormExpanded = !_isFormExpanded),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.l),
                                child: Row(
                                  children: [
                                    Text(
                                      'Добавить урок',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: colors.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    AnimatedRotation(
                                      turns: _isFormExpanded ? 0.5 : 0.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(Icons.expand_more, color: colors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child:
                                  _isFormExpanded
                                      ? Padding(
                                        padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.l),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildDatePicker(colors),
                                            const SizedBox(height: AppSpacing.m),
                                            _buildSlotChips(colors),
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
                                                const SizedBox(width: AppSpacing.m),
                                                Expanded(
                                                  child: _buildTimePicker(
                                                    'Конец',
                                                    _endTime,
                                                    (t) => setState(() => _endTime = t),
                                                    colors,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSpacing.m),
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
                                                    validator: (val) => val == null ? 'Выберите предмет' : null,
                                                  ),
                                                ),
                                                const SizedBox(width: AppSpacing.m),
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
                                                    validator: (val) => val == null ? 'Выберите группу' : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppSpacing.m),
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
                                                          child: Text(
                                                            '${t.surname} ${t.name}',
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              onChanged: (val) {
                                                setState(() => _selectedTeacherId = val);
                                                _scheduleConflictValidation();
                                              },
                                              validator: (val) => val == null ? 'Выберите преподавателя' : null,
                                            ),
                                            const SizedBox(height: AppSpacing.m),
                                            DropdownButtonFormField<String?>(
                                              decoration: const InputDecoration(
                                                labelText: 'Аудитория (необязательно)',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                              initialValue: _selectedRoomId,
                                              isExpanded: true,
                                              items: [
                                                const DropdownMenuItem(child: Text('Не указана')),
                                                ..._rooms.map(
                                                  (r) => DropdownMenuItem(
                                                    value: r.id,
                                                    child: Text(r.name, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (val) => setState(() => _selectedRoomId = val),
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
                                                    border: Border.all(
                                                      color: _isCheckingConflict ? colors.outline : colors.error,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      _isCheckingConflict
                                                          ? const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: CircularProgressIndicator(strokeWidth: 2),
                                                          )
                                                          : Icon(
                                                            Icons.warning_amber_rounded,
                                                            color: colors.onErrorContainer,
                                                          ),
                                                      const SizedBox(width: AppSpacing.m),
                                                      Expanded(
                                                        child: Text(
                                                          _isCheckingConflict
                                                              ? 'Проверка наложений...'
                                                              : _currentConflictError!,
                                                          style: TextStyle(
                                                            color:
                                                                _isCheckingConflict
                                                                    ? colors.onSurfaceVariant
                                                                    : colors.onErrorContainer,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: AppSpacing.l),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  backgroundColor: colors.primary,
                                                  foregroundColor: colors.onPrimary,
                                                ),
                                                onPressed:
                                                    (_isAdding || _currentConflictError != null)
                                                        ? null
                                                        : _addScheduleEntry,
                                                icon:
                                                    _isAdding
                                                        ? SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: colors.onPrimary,
                                                          ),
                                                        )
                                                        : const Icon(Icons.add),
                                                label: const Text('Добавить в расписание'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  TextButton.icon(
                                    onPressed: _duplicateSchedule,
                                    icon: const Icon(Icons.copy_all, size: 18),
                                    label: const Text('Копировать'),
                                  )
                                else
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (_groups.isNotEmpty || _teachers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                if (_groups.isNotEmpty)
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Группа',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          value: _filterGroupId,
                                          isExpanded: true,
                                          isDense: true,
                                          items: [
                                            const DropdownMenuItem(child: Text('Все группы')),
                                            ..._groups.map(
                                              (g) => DropdownMenuItem(
                                                value: g.id,
                                                child: Text(g.name, overflow: TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ],
                                          onChanged:
                                              (val) => setState(() {
                                                _filterGroupId = val;
                                                _rebuildGrouped();
                                              }),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_groups.isNotEmpty && _teachers.isNotEmpty) const SizedBox(width: AppSpacing.m),
                                if (_teachers.isNotEmpty)
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Преподаватель',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          value: _filterTeacherId,
                                          isExpanded: true,
                                          isDense: true,
                                          items: [
                                            const DropdownMenuItem(child: Text('Все преп.')),
                                            ..._teachers.map(
                                              (t) => DropdownMenuItem(
                                                value: t.id,
                                                child: Text('${t.surname} ${t.name}', overflow: TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ],
                                          onChanged:
                                              (val) => setState(() {
                                                _filterTeacherId = val;
                                                _rebuildGrouped();
                                              }),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (_filterGroupId != null || _filterTeacherId != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed:
                                  () => setState(() {
                                    _filterGroupId = null;
                                    _filterTeacherId = null;
                                    _rebuildGrouped();
                                  }),
                              icon: const Icon(Icons.filter_alt_off, size: 16),
                              label: const Text('Сбросить фильтры'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    sliver: SliverToBoxAdapter(child: _buildScheduleListSkeleton()),
                  )
                else if (_groupedSchedule.isEmpty && _groupedPastSchedule.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          _schedules.isEmpty && _lastPeriod == null
                              ? 'Расписание пустое'
                              : (_filterGroupId != null || _filterTeacherId != null)
                              ? 'Нет занятий по выбранным фильтрам'
                              : 'Нет занятий в выбранном периоде',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  )
                else ...[
                  if (_groupedSchedule.isNotEmpty)
                    _buildScheduleSliver(colors, theme)
                  else if (!isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Нет предстоящих занятий', style: TextStyle(color: colors.onSurfaceVariant)),
                          ),
                        ),
                      ),
                    ),
                  if (_groupedPastSchedule.isNotEmpty && !isLoading) _buildPastScheduleSection(colors, theme),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.l)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleListSkeleton() {
    final surface = Theme.of(context).colorScheme.surface;
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12)),
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
      ),
    );
  }
}

class _EditLessonDialog extends StatefulWidget {
  final Schedule lesson;
  final List<Subject> subjects;
  final List<Group> groups;
  final List<Teacher> teachers;
  final List<Room> rooms;
  final String institutionId;
  final ScheduleRepository scheduleService;
  final List<TimeGrid> timeGrids;

  const _EditLessonDialog({
    required this.lesson,
    required this.subjects,
    required this.groups,
    required this.teachers,
    required this.rooms,
    required this.institutionId,
    required this.scheduleService,
    required this.timeGrids,
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
  String? _roomId;
  String? _selectedGridId;

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
    _roomId = l.roomId;
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
      startTime: formatTimeOfDaySec(_startTime),
      endTime: formatTimeOfDaySec(_endTime),
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

    final startTime = formatTimeOfDaySec(_startTime);
    final endTime = formatTimeOfDaySec(_endTime);

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
      startTime: startTime,
      endTime: endTime,
      roomId: _roomId,
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

  Widget _buildSlotChips(ColorScheme colors) {
    if (widget.timeGrids.isEmpty) return const SizedBox.shrink();
    final activeGrid = widget.timeGrids.firstWhere(
      (g) => g.id == (_selectedGridId ?? widget.timeGrids.first.id),
      orElse: () => widget.timeGrids.first,
    );
    if (activeGrid.slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.timeGrids.length > 1) ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Сетка времени', border: OutlineInputBorder(), isDense: true),
            initialValue: _selectedGridId ?? widget.timeGrids.first.id,
            items: widget.timeGrids.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
            onChanged: (val) => setState(() => _selectedGridId = val),
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        Text('Быстрый выбор:', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children:
              activeGrid.slots.map((slot) {
                final chipLabel = slot.label != null ? '${slot.label}\n${slot.timeRange}' : slot.timeRange;
                return ActionChip(
                  label: Text(chipLabel, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  onPressed: () {
                    setState(() {
                      _startTime = _parseTime(slot.startTime);
                      _endTime = _parseTime(slot.endTime);
                    });
                    _scheduleConflictValidation();
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
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
                  child: Text(formatDate(_date)),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildSlotChips(colors),
              Row(
                children: [
                  Expanded(child: _buildTimePicker('Начало', _startTime, (t) => setState(() => _startTime = t))),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(child: _buildTimePicker('Конец', _endTime, (t) => setState(() => _endTime = t))),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
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
              const SizedBox(height: AppSpacing.m),
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
              const SizedBox(height: AppSpacing.m),
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
              const SizedBox(height: AppSpacing.m),
              DropdownButtonFormField<String?>(
                decoration: const InputDecoration(
                  labelText: 'Аудитория (необязательно)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                initialValue: _roomId,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(child: Text('Не указана')),
                  ...widget.rooms.map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.name, overflow: TextOverflow.ellipsis)),
                  ),
                ],
                onChanged: (val) => setState(() => _roomId = val),
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
                        const SizedBox(width: AppSpacing.m),
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

class _CopyWeekDialog extends StatefulWidget {
  const _CopyWeekDialog();

  @override
  State<_CopyWeekDialog> createState() => _CopyWeekDialogState();
}

class _CopyWeekDialogState extends State<_CopyWeekDialog> {
  DateTime? _sourceDate;
  DateTime? _targetDate;

  String _weekRange(DateTime anyDay) {
    final mon = anyDay.subtract(Duration(days: anyDay.weekday - 1));
    final sun = mon.add(const Duration(days: 6));
    String f(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    return '${f(mon)} – ${f(sun)}';
  }

  Widget _weekTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month, color: colors.primary),
        ),
        child: Text(
          date != null ? _weekRange(date) : 'Нажмите для выбора',
          style: TextStyle(color: date == null ? colors.onSurfaceVariant : colors.onSurface),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Копировать неделю'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _weekTile(
              label: 'Неделя-источник',
              date: _sourceDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _sourceDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  helpText: 'Выберите любой день недели-источника',
                );
                if (picked != null) setState(() => _sourceDate = picked);
              },
              colors: colors,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: Icon(Icons.arrow_downward, color: colors.onSurfaceVariant),
            ),
            _weekTile(
              label: 'Неделя-назначение',
              date: _targetDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate ?? (_sourceDate?.add(const Duration(days: 7)) ?? DateTime.now()),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  helpText: 'Выберите любой день недели-назначения',
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
              colors: colors,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed:
              (_sourceDate != null && _targetDate != null)
                  ? () => Navigator.pop(context, (_sourceDate!, _targetDate!))
                  : null,
          child: const Text('Копировать'),
        ),
      ],
    );
  }
}
