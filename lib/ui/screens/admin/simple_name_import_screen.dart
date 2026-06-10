import 'dart:convert';
import 'dart:io';

import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/bulk_import_result.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimpleNameImportScreen extends StatefulWidget {
  final String title;
  final String entitySingular; // предмет / аудитория
  final IconData entityIcon;
  final String templateExample; // пример строки для подсказки
  final Future<AppResult<BulkImportResult>> Function(List<String> names) onBulkImport;
  final VoidCallback? onImportDone;

  const SimpleNameImportScreen({
    super.key,
    required this.title,
    required this.entitySingular,
    required this.entityIcon,
    required this.templateExample,
    required this.onBulkImport,
    this.onImportDone,
  });

  @override
  State<SimpleNameImportScreen> createState() => _SimpleNameImportScreenState();
}

class _SimpleNameImportScreenState extends State<SimpleNameImportScreen> {
  String? _fileName;
  List<_NameRow>? _rows;
  bool _isParsing = false;
  bool _isImporting = false;

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
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        MessengerHelper.showError('Не удалось прочитать файл.');
        setState(() => _isParsing = false);
        return;
      }
    } catch (_) {
      MessengerHelper.showError('Не удалось прочитать файл.');
      setState(() => _isParsing = false);
      return;
    }

    final rows = _parseContent(content);
    if (!mounted) return;

    if (rows == null) {
      MessengerHelper.showError('Файл пустой или не содержит данных.');
      setState(() => _isParsing = false);
      return;
    }

    setState(() {
      _rows = rows;
      _isParsing = false;
    });
  }

  List<_NameRow>? _parseContent(String content) {
    final noBom = content.startsWith('﻿') ? content.substring(1) : content;
    final lines = noBom.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

    final nonEmpty = lines.where((l) => l.trim().isNotEmpty).toList();
    if (nonEmpty.isEmpty) return null;

    int startIndex = 0;
    final delimiter = nonEmpty[0].contains(';') ? ';' : ',';
    final firstCell = nonEmpty[0].split(delimiter)[0].trim().toLowerCase();
    if (firstCell == 'name') startIndex = 1;

    final seenInFile = <String>{};
    final rows = <_NameRow>[];

    for (int i = startIndex; i < nonEmpty.length; i++) {
      final name = nonEmpty[i].split(delimiter)[0].trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      String? error;
      if (name.length > 100) {
        error = 'Слишком длинное название';
      } else if (seenInFile.contains(key)) {
        error = 'Дубль в файле';
      }

      if (error == null) seenInFile.add(key);
      rows.add(_NameRow(name: name, error: error));
    }

    return rows.isEmpty ? null : rows;
  }

  Future<void> _import() async {
    final validNames = _rows?.where((r) => r.isValid).map((r) => r.name).toList() ?? [];
    if (validNames.isEmpty) return;

    setState(() => _isImporting = true);
    final result = await widget.onBulkImport(validNames);
    if (!mounted) return;
    setState(() => _isImporting = false);

    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
      return;
    }

    _showResultDialog(result.data);
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
                    constraints: const BoxConstraints(maxHeight: 180),
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

  Widget _resultLine(IconData icon, Color color, String text) => Row(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 15)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final validCount = _rows?.where((r) => r.isValid).length ?? 0;
    final errorCount = _rows?.where((r) => !r.isValid).length ?? 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
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
                          Text(
                            'Формат CSV-файла',
                            style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'name\n${widget.templateExample}',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.onSurface),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Одна колонка name, каждая строка — одно название. '
                        'Заголовок name необязателен.',
                        style: TextStyle(fontSize: 12, color: colors.onSurface.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Card(
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
              ),
              if (_isParsing) ...[
                const SizedBox(height: AppSpacing.l),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_rows != null) ...[
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    _statChip('Всего: ${_rows!.length}', colors.primary, colors.onPrimary),
                    const SizedBox(width: 8),
                    _statChip('Корректных: $validCount', Colors.green, Colors.white),
                    if (errorCount > 0) ...[
                      const SizedBox(width: 8),
                      _statChip('Ошибок: $errorCount', Colors.red, Colors.white),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rows!.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final row = _rows![i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              row.isValid ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          child: Icon(
                            row.isValid ? Icons.check : Icons.close,
                            size: 16,
                            color: row.isValid ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(row.name, style: TextStyle(fontSize: 14, color: row.isValid ? null : colors.error)),
                        subtitle:
                            row.error != null
                                ? Text(row.error!, style: TextStyle(fontSize: 12, color: colors.error))
                                : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton.icon(
                  onPressed: (validCount == 0 || _isImporting) ? null : _import,
                  icon:
                      _isImporting
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary),
                          )
                          : Icon(widget.entityIcon),
                  label: Text(
                    _isImporting ? 'Импортирую...' : 'Импортировать $validCount ${widget.entitySingular}(-а/-ов)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

class _NameRow {
  final String name;
  final String? error;

  const _NameRow({required this.name, this.error});

  bool get isValid => error == null;
}
