import 'dart:convert';
import 'dart:io';

import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/user_add_service.dart';
import 'package:edu_track/models/group.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/bulk_import_result.dart';
import 'package:edu_track/utils/csv_student_parser.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CsvImportScreen extends StatefulWidget {
  final VoidCallback? onImportDone;
  const CsvImportScreen({super.key, this.onImportDone});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final _groupService = GroupService();
  List<Group> _groups = [];
  bool _groupsLoading = true;

  String? _fileName;
  List<StudentImportRow>? _rows;
  bool _isParsing = false;
  bool _isImporting = false;

  static const _templateText =
      'name,surname,email,login,password,group_name\n'
      'Иван,Иванов,ivan@mail.ru,ivanov_i,pass12345,ИС-21\n'
      'Мария,Петрова,petm@mail.ru,petrova_m,secure99,ИС-21';

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    final result = await _groupService.getGroups(institutionId);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      setState(() => _groupsLoading = false);
      return;
    }
    setState(() {
      _groups = result.data;
      _groupsLoading = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.first;
    setState(() {
      _isParsing = true;
      _fileName = file.name;
      _rows = null;
    });

    String content;
    try {
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        MessengerHelper.showError('Не удалось прочитать файл.');
        setState(() => _isParsing = false);
        return;
      }
      try {
        content = utf8.decode(bytes);
      } on FormatException {
        if (!mounted) return;
        MessengerHelper.showError(
          'Файл сохранён в неподдерживаемой кодировке. '
          'Сохраните CSV в UTF-8: в Excel — «Сохранить как» → «CSV UTF-8», '
          'в Google Таблицах — Файл → Скачать → CSV.',
        );
        setState(() => _isParsing = false);
        return;
      }
    } catch (_) {
      MessengerHelper.showError('Не удалось прочитать файл.');
      setState(() => _isParsing = false);
      return;
    }

    final parseResult = CsvStudentParser.parse(content);
    if (!mounted) return;
    if (parseResult.fatalError != null) {
      MessengerHelper.showError(parseResult.fatalError!);
      setState(() => _isParsing = false);
      return;
    }

    final resolved =
        parseResult.rows.map((row) {
          if (!row.isValid) return row;
          final group = _groups.where((g) => g.name.toLowerCase() == row.groupName.toLowerCase()).firstOrNull;
          if (group == null) return row.withError('Группа "${row.groupName}" не найдена');
          return row.withGroupId(group.id!);
        }).toList();

    setState(() {
      _rows = resolved;
      _isParsing = false;
    });
  }

  Future<void> _import() async {
    final validRows = _rows?.where((r) => r.isValid).toList() ?? [];
    if (validRows.isEmpty) return;

    setState(() => _isImporting = true);

    final students =
        validRows
            .map(
              (r) => {
                'name': r.name,
                'surname': r.surname,
                'email': r.email,
                'login': r.login,
                'password': r.password,
                'group_id': r.groupId!,
              },
            )
            .toList();
    final result = await UserAddService().bulkAddStudents(students: students);
    if (!mounted) return;
    setState(() => _isImporting = false);
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }
    final data = result.data;
    _showResultDialog(data);
  }

  void _showResultDialog(BulkImportResult result) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Результат импорта'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resultLine(Icons.check_circle, Colors.green, 'Добавлено: ${result.imported}'),
                if (result.skipped > 0) ...[
                  const SizedBox(height: 8),
                  _resultLine(Icons.warning, Colors.orange, 'Пропущено: ${result.skipped}'),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            result.skippedReasons
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text('• $r', style: const TextStyle(fontSize: 12)),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (result.imported > 0) {
                    widget.onImportDone?.call();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _resultLine(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: const Text('Импорт студентов из CSV', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child:
            _groupsLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormatCard(colors),
                      const SizedBox(height: AppSpacing.l),
                      _buildPickerCard(colors),
                      if (_isParsing) ...[
                        const SizedBox(height: AppSpacing.l),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      if (_rows != null) ...[
                        const SizedBox(height: AppSpacing.l),
                        _buildStatsRow(colors),
                        const SizedBox(height: AppSpacing.m),
                        _buildPreviewList(colors),
                        const SizedBox(height: AppSpacing.l),
                        _buildImportButton(colors),
                      ],
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildFormatCard(ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Формат CSV-файла', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
              child: Text(
                _templateText,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.onSurface),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Группа указывается по точному названию (например, ИС-21). '
              'Разделитель — запятая. Первая строка — заголовок. '
              'Файл должен быть в кодировке UTF-8.',
              style: TextStyle(fontSize: 12, color: colors.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard(ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_fileName != null) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _fileName!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            ElevatedButton.icon(
              onPressed: _isParsing ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_fileName == null ? 'Выбрать CSV-файл' : 'Выбрать другой файл'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colors) {
    final rows = _rows!;
    final valid = rows.where((r) => r.isValid).length;
    final errors = rows.where((r) => !r.isValid).length;

    return Row(
      children: [
        _statChip('Всего: ${rows.length}', colors.primary, colors.onPrimary),
        const SizedBox(width: 8),
        _statChip('Корректных: $valid', Colors.green, Colors.white),
        if (errors > 0) ...[const SizedBox(width: 8), _statChip('Ошибок: $errors', Colors.red, Colors.white)],
      ],
    );
  }

  Widget _statChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPreviewList(ColorScheme colors) {
    final rows = _rows!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) => _buildRowTile(rows[i], colors),
      ),
    );
  }

  Widget _buildRowTile(StudentImportRow row, ColorScheme colors) {
    final isValid = row.isValid;
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: isValid ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
        child: Icon(isValid ? Icons.check : Icons.close, size: 16, color: isValid ? Colors.green : Colors.red),
      ),
      title: Text('${row.surname} ${row.name}', style: TextStyle(fontSize: 14, color: isValid ? null : colors.error)),
      subtitle: Text(
        isValid ? '${row.login} · ${row.groupName}' : row.error!,
        style: TextStyle(fontSize: 12, color: isValid ? colors.onSurface.withValues(alpha: 0.6) : colors.error),
      ),
      trailing: Text(
        '#${row.rowIndex}',
        style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.4)),
      ),
    );
  }

  Widget _buildImportButton(ColorScheme colors) {
    final validCount = _rows?.where((r) => r.isValid).length ?? 0;
    return ElevatedButton.icon(
      onPressed: (validCount == 0 || _isImporting) ? null : _import,
      icon:
          _isImporting
              ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
              )
              : const Icon(Icons.cloud_upload_outlined),
      label: Text(
        _isImporting ? 'Импортирую...' : 'Импортировать $validCount студентов',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
