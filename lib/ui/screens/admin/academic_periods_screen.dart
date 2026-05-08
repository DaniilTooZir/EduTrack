import 'package:edu_track/data/services/academic_period_service.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcademicPeriodsScreen extends StatefulWidget {
  const AcademicPeriodsScreen({super.key});

  @override
  State<AcademicPeriodsScreen> createState() => _AcademicPeriodsScreenState();
}

class _AcademicPeriodsScreenState extends State<AcademicPeriodsScreen> {
  final _service = AcademicPeriodService();
  bool _isLoading = true;
  List<AcademicPeriod> _periods = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final instId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (instId == null) {
      setState(() {
        _error = 'Не удалось получить ID учреждения';
        _isLoading = false;
      });
      return;
    }
    if (!_isLoading)
      setState(() {
        _isLoading = true;
        _error = null;
      });
    final result = await _service.getPeriods(instId);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _error = result.errorMessage;
        _isLoading = false;
      });
    } else {
      setState(() {
        _periods = result.data;
        _isLoading = false;
      });
    }
  }

  Future<void> _openPeriodDialog({AcademicPeriod? existing}) async {
    final instId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (instId == null) {
      MessengerHelper.showError('Не удалось получить ID учреждения');
      return;
    }
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    DateTime? startDate = existing?.startDate;
    DateTime? endDate = existing?.endDate;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                title: Text(existing == null ? 'Добавить период' : 'Редактировать период'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          hintText: 'Например: 1 семестр 2024',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DatePickerTile(
                        label: 'Дата начала',
                        date: startDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setDialogState(() => startDate = picked);
                        },
                      ),
                      const SizedBox(height: 8),
                      _DatePickerTile(
                        label: 'Дата окончания',
                        date: endDate,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: endDate ?? startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setDialogState(() => endDate = picked);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
                ],
              );
            },
          ),
    );
    if (confirmed != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty || startDate == null || endDate == null) {
      MessengerHelper.showError('Заполните все поля');
      return;
    }
    final AppResult<void> result;
    if (existing == null) {
      final period = AcademicPeriod(
        id: '',
        institutionId: instId,
        name: name,
        startDate: startDate!,
        endDate: endDate!,
      );
      result = await _service.addPeriod(period);
    } else {
      result = await _service.updatePeriod(existing.copyWith(name: name, startDate: startDate!, endDate: endDate!));
    }
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      MessengerHelper.showSuccess(existing == null ? 'Период добавлен' : 'Период обновлён');
      await _load();
    }
  }

  Future<void> _confirmDelete(AcademicPeriod period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Удалить период?'),
            content: Text('«${period.name}» будет удалён безвозвратно.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _service.deletePeriod(period.id);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      MessengerHelper.showSuccess('Период удалён');
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: _buildBody(colors),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPeriodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить период'),
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: colors.error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Повторить')),
          ],
        ),
      );
    }
    if (_periods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 64, color: colors.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'Периодов пока нет',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите «Добавить период», чтобы создать первый учебный семестр',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.outlineVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _periods.length,
        itemBuilder:
            (context, i) => _PeriodCard(
              period: _periods[i],
              onEdit: () => _openPeriodDialog(existing: _periods[i]),
              onDelete: () => _confirmDelete(_periods[i]),
            ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final AcademicPeriod period;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PeriodCard({required this.period, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCurrent = period.isCurrent();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCurrent ? colors.primaryContainer : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: isCurrent ? colors.primary : colors.onSurfaceVariant,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          period.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Текущий',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmt(period.startDate)} — ${_fmt(period.endDate)}',
                    style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.primary, size: 20),
              tooltip: 'Редактировать',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
              tooltip: 'Удалить',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text =
        date != null
            ? '${date!.day.toString().padLeft(2, '0')}.${date!.month.toString().padLeft(2, '0')}.${date!.year}'
            : 'Не выбрана';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: colors.outline), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: TextStyle(fontSize: 14, color: date != null ? colors.onSurface : colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
