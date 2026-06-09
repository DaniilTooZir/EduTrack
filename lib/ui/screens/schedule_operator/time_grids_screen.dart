import 'package:edu_track/data/services/time_grid_service.dart';
import 'package:edu_track/models/time_grid.dart';
import 'package:edu_track/models/time_slot.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/date_utils.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeGridsScreen extends StatefulWidget {
  const TimeGridsScreen({super.key});

  @override
  State<TimeGridsScreen> createState() => _TimeGridsScreenState();
}

class _TimeGridsScreenState extends State<TimeGridsScreen> {
  final _service = TimeGridService();
  List<TimeGrid> _grids = [];
  bool _isLoading = false;
  String? _institutionId;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    _load();
  }

  Future<void> _load() async {
    if (_institutionId == null) return;
    setState(() => _isLoading = true);
    final result = await _service.getGridsForInstitution(_institutionId!);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      setState(() => _grids = result.data);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createGrid() async {
    final name = await _showNameDialog(title: 'Новая сетка', hint: 'Название сетки');
    if (name == null || !mounted) return;
    final result = await _service.createGrid(_institutionId!, name);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      setState(() {
        _grids.add(result.data);
        _expanded.add(result.data.id);
      });
    }
  }

  Future<void> _renameGrid(TimeGrid grid) async {
    final name = await _showNameDialog(title: 'Переименовать сетку', hint: 'Название сетки', initial: grid.name);
    if (name == null || !mounted) return;
    final result = await _service.updateGridName(grid.id, name);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      setState(() {
        final idx = _grids.indexWhere((g) => g.id == grid.id);
        if (idx != -1) {
          _grids[idx] = TimeGrid(id: grid.id, institutionId: grid.institutionId, name: name, slots: grid.slots);
        }
      });
    }
  }

  Future<void> _deleteGrid(TimeGrid grid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить сетку?'),
            content: Text('Удалить "${grid.name}" и все её слоты?'),
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
    final result = await _service.deleteGrid(grid.id);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      setState(() => _grids.removeWhere((g) => g.id == grid.id));
    }
  }

  Future<void> _addSlot(TimeGrid grid) async {
    final slot = await _showSlotDialog(gridId: grid.id, sortOrder: grid.slots.length);
    if (slot == null || !mounted) return;
    _updateGridSlots(grid.id, [...grid.slots, slot]);
  }

  Future<void> _editSlot(TimeGrid grid, TimeSlot slot) async {
    final updated = await _showSlotDialog(gridId: grid.id, existing: slot, sortOrder: slot.sortOrder);
    if (updated == null || !mounted) return;
    _updateGridSlots(grid.id, grid.slots.map((s) => s.id == updated.id ? updated : s).toList());
  }

  Future<void> _deleteSlot(TimeGrid grid, TimeSlot slot) async {
    final result = await _service.deleteSlot(slot.id);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      _updateGridSlots(grid.id, grid.slots.where((s) => s.id != slot.id).toList());
    }
  }

  void _updateGridSlots(String gridId, List<TimeSlot> newSlots) {
    setState(() {
      final idx = _grids.indexWhere((g) => g.id == gridId);
      if (idx != -1) {
        _grids[idx] = TimeGrid(
          id: _grids[idx].id,
          institutionId: _grids[idx].institutionId,
          name: _grids[idx].name,
          slots: newSlots,
        );
      }
    });
  }

  Future<String?> _showNameDialog({required String title, required String hint, String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: hint, border: const OutlineInputBorder()),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
              },
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              FilledButton(
                onPressed: () {
                  final v = controller.text.trim();
                  if (v.isNotEmpty) Navigator.pop(ctx, v);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
  }

  Future<TimeSlot?> _showSlotDialog({required String gridId, TimeSlot? existing, required int sortOrder}) {
    return showDialog<TimeSlot>(
      context: context,
      builder: (_) => _SlotDialog(service: _service, gridId: gridId, existing: existing, sortOrder: sortOrder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _grids.isEmpty
                  ? _buildEmpty(colors)
                  : _buildList(colors),
        ),
        Positioned(
          right: AppSpacing.l,
          bottom: AppSpacing.l,
          child: FloatingActionButton.extended(
            heroTag: 'time_grids_fab',
            onPressed: _createGrid,
            icon: const Icon(Icons.add),
            label: const Text('Новая сетка'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('Нет сеток времени', style: TextStyle(fontSize: 18, color: colors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              'Создайте сетку и добавьте временны́е слоты.\nОни появятся как быстрый выбор при добавлении урока.',
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, 100),
        children: _grids.map((g) => _buildGridCard(g, colors)).toList(),
      ),
    );
  }

  Widget _buildGridCard(TimeGrid grid, ColorScheme colors) {
    final isExpanded = _expanded.contains(grid.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap:
                () => setState(() {
                  if (isExpanded) {
                    _expanded.remove(grid.id);
                  } else {
                    _expanded.add(grid.id);
                  }
                }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      grid.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primary),
                    ),
                  ),
                  Text('${grid.slots.length} сл.', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 20, color: colors.primary),
                    onPressed: () => _renameGrid(grid),
                    tooltip: 'Переименовать',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: colors.error),
                    onPressed: () => _deleteGrid(grid),
                    tooltip: 'Удалить сетку',
                    visualDensity: VisualDensity.compact,
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child:
                isExpanded
                    ? Column(
                      children: [
                        const Divider(height: 1),
                        if (grid.slots.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            child: Text(
                              'Нет слотов. Добавьте первый.',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          )
                        else
                          ...grid.slots.map((s) => _buildSlotRow(grid, s, colors)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _addSlot(grid),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Добавить слот'),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotRow(TimeGrid grid, TimeSlot slot, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.outlineVariant, width: 0.5))),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(6)),
          child: Text(
            slot.timeRange,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onPrimaryContainer),
          ),
        ),
        title: Text(slot.label ?? '—', style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
              onPressed: () => _editSlot(grid, slot),
              visualDensity: VisualDensity.compact,
              tooltip: 'Редактировать',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
              onPressed: () => _deleteSlot(grid, slot),
              visualDensity: VisualDensity.compact,
              tooltip: 'Удалить',
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDialog extends StatefulWidget {
  final TimeGridService service;
  final String gridId;
  final TimeSlot? existing;
  final int sortOrder;

  const _SlotDialog({required this.service, required this.gridId, this.existing, required this.sortOrder});

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  final _labelController = TextEditingController();
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label ?? '';
      _start = _parseTime(widget.existing!.startTime);
      _end = _parseTime(widget.existing!.endTime);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _save() async {
    if (_start == null || _end == null) {
      MessengerHelper.showError('Укажите время начала и окончания');
      return;
    }
    final startStr = formatTimeOfDaySec(_start!);
    final endStr = formatTimeOfDaySec(_end!);
    final label = _labelController.text.trim().isEmpty ? null : _labelController.text.trim();

    setState(() => _saving = true);

    if (widget.existing == null) {
      final result = await widget.service.addSlot(
        widget.gridId,
        label: label,
        startTime: startStr,
        endTime: endStr,
        sortOrder: widget.sortOrder,
      );
      if (!mounted) return;
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        setState(() => _saving = false);
      } else {
        Navigator.pop(context, result.data);
      }
    } else {
      final result = await widget.service.updateSlot(
        widget.existing!.id,
        label: label,
        startTime: startStr,
        endTime: endStr,
        sortOrder: widget.sortOrder,
      );
      if (!mounted) return;
      if (result.isFailure) {
        MessengerHelper.showError(result.errorMessage);
        setState(() => _saving = false);
      } else {
        Navigator.pop(
          context,
          TimeSlot(
            id: widget.existing!.id,
            gridId: widget.gridId,
            label: label,
            startTime: startStr,
            endTime: endStr,
            sortOrder: widget.sortOrder,
          ),
        );
      }
    }
  }

  Widget _buildTimeTile(String label, TimeOfDay? time, ValueChanged<TimeOfDay> onPicked) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
          helpText: label.toUpperCase(),
        );
        if (picked != null) onPicked(picked);
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Добавить слот' : 'Редактировать слот'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Название (необязательно)',
                  hintText: 'Например: 1 пара',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(child: _buildTimeTile('Начало', _start, (t) => setState(() => _start = t))),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(child: _buildTimeTile('Конец', _end, (t) => setState(() => _end = t))),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сохранить'),
        ),
      ],
    );
  }
}
