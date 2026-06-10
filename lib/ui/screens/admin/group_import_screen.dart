import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/teacher_service.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupImportScreen extends StatefulWidget {
  final VoidCallback? onImportDone;
  const GroupImportScreen({super.key, this.onImportDone});

  @override
  State<GroupImportScreen> createState() => _GroupImportScreenState();
}

class _GroupImportScreenState extends State<GroupImportScreen> {
  final _groupService = GroupService();
  final _teacherService = TeacherService();
  final _chatService = ChatService();

  List<Teacher> _teachers = [];
  bool _teachersLoading = true;

  String? _fileName;
  List<_GroupRow>? _rows;
  bool _isParsing = false;
  bool _isImporting = false;

  static const _templateText =
      'name,curator_login\n'
      'ИС-21,ivanov_i\n'
      'ФМ-22,\n'
      'КС-11';

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) return;
    final result = await _teacherService.getTeachers(institutionId);
    if (!mounted) return;
    if (result.isFailure) {
      MessengerHelper.showError(result.errorMessage);
    } else {
      _teachers = result.data;
    }
    setState(() => _teachersLoading = false);
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

    final rows = _parse(content);
    if (!mounted) return;

    if (rows == null) {
      MessengerHelper.showError('Файл пустой или неверный формат.');
      setState(() => _isParsing = false);
      return;
    }

    setState(() {
      _rows = rows;
      _isParsing = false;
    });
  }

  List<_GroupRow>? _parse(String content) {
    final noBom = content.startsWith('﻿') ? content.substring(1) : content;
    final cleaned = noBom.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final firstLine = cleaned.split('\n').first;
    final delimiter = (firstLine.contains(';') && !firstLine.contains(',')) ? ';' : ',';

    List<List<dynamic>> csvRows;
    try {
      csvRows = CsvToListConverter(eol: '\n', shouldParseNumbers: false, fieldDelimiter: delimiter).convert(cleaned);
    } catch (_) {
      return null;
    }

    if (csvRows.isEmpty) return null;

    final headers = csvRows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    if (!headers.contains('name')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessengerHelper.showError('Отсутствует колонка "name".');
      });
      return null;
    }

    final nameIdx = headers.indexOf('name');
    final curatorIdx = headers.contains('curator_login') ? headers.indexOf('curator_login') : -1;

    final seenInFile = <String>{};
    final rows = <_GroupRow>[];
    final groupNameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ0-9-]+$');

    for (int i = 1; i < csvRows.length; i++) {
      final row = csvRows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      String get(int ix) => ix >= 0 && ix < row.length ? row[ix].toString().trim() : '';

      final name = get(nameIdx);
      final curatorLogin = curatorIdx >= 0 ? get(curatorIdx) : '';

      String? error;
      String? resolvedCuratorId;
      String? resolvedCuratorName;

      if (name.isEmpty) {
        error = 'Не указано название';
      } else if (name.length > 10) {
        error = 'Название > 10 символов';
      } else if (!groupNameRegex.hasMatch(name)) {
        error = 'Только буквы, цифры и "-"';
      } else if (seenInFile.contains(name.toLowerCase())) {
        error = 'Дубль в файле';
      } else if (curatorLogin.isNotEmpty) {
        final teacher = _teachers.where((t) => t.login.toLowerCase() == curatorLogin.toLowerCase()).firstOrNull;
        if (teacher == null) {
          error = 'Куратор "$curatorLogin" не найден';
        } else {
          resolvedCuratorId = teacher.id;
          resolvedCuratorName = '${teacher.surname} ${teacher.name}';
        }
      }

      if (error == null) seenInFile.add(name.toLowerCase());

      rows.add(
        _GroupRow(
          name: name,
          curatorLogin: curatorLogin.isEmpty ? null : curatorLogin,
          curatorId: resolvedCuratorId,
          curatorName: resolvedCuratorName,
          error: error,
        ),
      );
    }

    return rows.isEmpty ? null : rows;
  }

  Future<void> _import() async {
    final validRows = _rows?.where((r) => r.isValid).toList() ?? [];
    if (validRows.isEmpty) return;

    final institutionId = Provider.of<UserProvider>(context, listen: false).institutionId;
    if (institutionId == null) {
      MessengerHelper.showError('Не удалось получить ID учреждения.');
      return;
    }

    setState(() => _isImporting = true);

    final groups =
        validRows.map((r) {
          final map = <String, dynamic>{'name': r.name};
          if (r.curatorId != null) map['curator_id'] = r.curatorId;
          return map;
        }).toList();

    final result = await _groupService.bulkAddGroups(groups: groups, institutionId: institutionId);
    if (!mounted) return;

    if (result.isFailure) {
      setState(() => _isImporting = false);
      MessengerHelper.showError(result.errorMessage);
      return;
    }

    for (final g in result.data.createdGroups) {
      await _chatService.getOrCreateGroupChat(g['id']!, g['name']!);
    }

    if (!mounted) return;
    setState(() => _isImporting = false);

    _showResultDialog(result.data);
  }

  void _showResultDialog(BulkGroupResult result) {
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
        title: const Text('Импорт групп из CSV', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(themeProvider.mode)),
        child:
            _teachersLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                                  _templateText,
                                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.onSurface),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Text(
                                'Колонка curator_login необязательна. '
                                'Если куратор указан, он должен уже существовать в системе.',
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
                              final subtitle =
                                  row.error ??
                                  (row.curatorName != null ? 'Куратор: ${row.curatorName}' : 'Без куратора');
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      row.isValid
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.red.withValues(alpha: 0.15),
                                  child: Icon(
                                    row.isValid ? Icons.check : Icons.close,
                                    size: 16,
                                    color: row.isValid ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  row.name,
                                  style: TextStyle(fontSize: 14, color: row.isValid ? null : colors.error),
                                ),
                                subtitle: Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: row.isValid ? colors.onSurface.withValues(alpha: 0.6) : colors.error,
                                  ),
                                ),
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
                                  : const Icon(Icons.groups_outlined),
                          label: Text(
                            _isImporting ? 'Импортирую...' : 'Импортировать $validCount групп',
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

class _GroupRow {
  final String name;
  final String? curatorLogin;
  final String? curatorId;
  final String? curatorName;
  final String? error;

  const _GroupRow({required this.name, this.curatorLogin, this.curatorId, this.curatorName, this.error});

  bool get isValid => error == null;
}
