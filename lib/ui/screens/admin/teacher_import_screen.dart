import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:edu_track/data/services/user_add_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/bulk_import_result.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:edu_track/utils/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherImportScreen extends StatefulWidget {
  final VoidCallback? onImportDone;
  const TeacherImportScreen({super.key, this.onImportDone});

  @override
  State<TeacherImportScreen> createState() => _TeacherImportScreenState();
}

class _TeacherImportScreenState extends State<TeacherImportScreen> {
  String? _fileName;
  List<_TeacherRow>? _rows;
  bool _isParsing = false;
  bool _isImporting = false;

  static const _templateText =
      'name,surname,email,login,password\n'
      'Иван,Иванов,ivan@mail.ru,ivanov_i,pass12345\n'
      'Мария,Петрова,petm@mail.ru,petrova_m,secure99';

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

    final parseResult = _parse(content);
    if (!mounted) return;

    if (parseResult == null) {
      MessengerHelper.showError('Файл пустой или неверный формат.');
      setState(() => _isParsing = false);
      return;
    }

    setState(() {
      _rows = parseResult;
      _isParsing = false;
    });
  }

  List<_TeacherRow>? _parse(String content) {
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
    const required = ['name', 'surname', 'email', 'login', 'password'];
    final missing = required.where((h) => !headers.contains(h)).toList();
    if (missing.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MessengerHelper.showError('Отсутствуют колонки: ${missing.join(', ')}.\nОжидаемые: ${required.join(', ')}');
      });
      return null;
    }

    int idx(String h) => headers.indexOf(h);
    final nameIdx = idx('name');
    final surnameIdx = idx('surname');
    final emailIdx = idx('email');
    final loginIdx = idx('login');
    final passwordIdx = idx('password');

    final seenLogins = <String>{};
    final seenEmails = <String>{};
    final rows = <_TeacherRow>[];
    final nameReg = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s-]+$');

    for (int i = 1; i < csvRows.length; i++) {
      final row = csvRows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      String get(int ix) => ix < row.length ? row[ix].toString().trim() : '';

      final name = get(nameIdx);
      final surname = get(surnameIdx);
      final email = get(emailIdx);
      final login = get(loginIdx);
      final password = get(passwordIdx);

      String? error;
      if (name.isEmpty) {
        error = 'Не указано имя';
      } else if (!nameReg.hasMatch(name)) {
        error = 'Имя должно содержать только буквы';
      } else if (surname.isEmpty) {
        error = 'Не указана фамилия';
      } else if (!nameReg.hasMatch(surname)) {
        error = 'Фамилия должна содержать только буквы';
      } else if (Validators.validateEmail(email) != null) {
        error = 'Некорректный email';
      } else if (login.isEmpty) {
        error = 'Не указан логин';
      } else if (login.length < 3) {
        error = 'Логин < 3 символов';
      } else if (password.length < 6) {
        error = 'Пароль < 6 символов';
      } else if (seenLogins.contains(login.toLowerCase())) {
        error = 'Дубль логина в файле';
      } else if (seenEmails.contains(email.toLowerCase())) {
        error = 'Дубль email в файле';
      }

      if (error == null) {
        seenLogins.add(login.toLowerCase());
        seenEmails.add(email.toLowerCase());
      }

      rows.add(
        _TeacherRow(
          rowIndex: i,
          name: name,
          surname: surname,
          email: email,
          login: login,
          password: password,
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

    final teachers =
        validRows
            .map(
              (r) => {
                'name': r.name,
                'surname': r.surname,
                'email': r.email,
                'login': r.login,
                'password': r.password,
                'institution_id': institutionId,
              },
            )
            .toList();

    final result = await UserAddService().bulkAddTeachers(teachers: teachers);
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
        title: const Text('Импорт преподавателей из CSV', style: TextStyle(fontWeight: FontWeight.w600)),
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
                          _templateText,
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: colors.onSurface),
                        ),
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
                        title: Text(
                          '${row.surname} ${row.name}',
                          style: TextStyle(fontSize: 14, color: row.isValid ? null : colors.error),
                        ),
                        subtitle: Text(
                          row.isValid ? '${row.login} · ${row.email}' : row.error!,
                          style: TextStyle(
                            fontSize: 12,
                            color: row.isValid ? colors.onSurface.withValues(alpha: 0.6) : colors.error,
                          ),
                        ),
                        trailing: Text(
                          '#${row.rowIndex}',
                          style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.4)),
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
                          : const Icon(Icons.school_outlined),
                  label: Text(
                    _isImporting ? 'Импортирую...' : 'Импортировать $validCount преподавателей',
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

class _TeacherRow {
  final int rowIndex;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String? error;

  const _TeacherRow({
    required this.rowIndex,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    this.error,
  });

  bool get isValid => error == null;
}
