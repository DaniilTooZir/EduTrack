import 'package:csv/csv.dart';

class StudentImportRow {
  final int rowIndex;
  final String name;
  final String surname;
  final String email;
  final String login;
  final String password;
  final String groupName;
  final String? error;
  final String? groupId;

  const StudentImportRow({
    required this.rowIndex,
    required this.name,
    required this.surname,
    required this.email,
    required this.login,
    required this.password,
    required this.groupName,
    this.error,
    this.groupId,
  });

  bool get isValid => error == null;

  StudentImportRow withError(String error) => StudentImportRow(
    rowIndex: rowIndex,
    name: name,
    surname: surname,
    email: email,
    login: login,
    password: password,
    groupName: groupName,
    error: error,
    groupId: groupId,
  );

  StudentImportRow withGroupId(String id) => StudentImportRow(
    rowIndex: rowIndex,
    name: name,
    surname: surname,
    email: email,
    login: login,
    password: password,
    groupName: groupName,
    error: error,
    groupId: id,
  );
}

class CsvParseResult {
  final List<StudentImportRow> rows;
  final String? fatalError;

  const CsvParseResult({required this.rows, this.fatalError});

  int get validCount => rows.where((r) => r.isValid).length;
  int get errorCount => rows.where((r) => !r.isValid).length;
}

class CsvStudentParser {
  static const _requiredHeaders = ['name', 'surname', 'email', 'login', 'password', 'group_name'];

  static CsvParseResult parse(String content) {
    final noBom = content.startsWith('﻿') ? content.substring(1) : content;
    final cleaned = noBom.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final firstLine = cleaned.split('\n').first;
    final delimiter = (firstLine.contains(';') && !firstLine.contains(',')) ? ';' : ',';

    List<List<dynamic>> rows;
    try {
      rows = CsvToListConverter(eol: '\n', shouldParseNumbers: false, fieldDelimiter: delimiter).convert(cleaned);
    } catch (_) {
      return const CsvParseResult(rows: [], fatalError: 'Не удалось разобрать CSV-файл. Проверьте формат.');
    }

    if (rows.isEmpty) return const CsvParseResult(rows: [], fatalError: 'Файл пустой.');

    final headers = rows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    final missing = _requiredHeaders.where((h) => !headers.contains(h)).toList();
    if (missing.isNotEmpty) {
      return CsvParseResult(
        rows: [],
        fatalError: 'Отсутствуют колонки: ${missing.join(', ')}.\nОжидаемые колонки: ${_requiredHeaders.join(', ')}',
      );
    }

    int idxOf(String h) => headers.indexOf(h);
    final nameIdx = idxOf('name');
    final surnameIdx = idxOf('surname');
    final emailIdx = idxOf('email');
    final loginIdx = idxOf('login');
    final passwordIdx = idxOf('password');
    final groupIdx = idxOf('group_name');

    final seenLogins = <String>{};
    final seenEmails = <String>{};
    final parsed = <StudentImportRow>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      String get(int idx) => idx < row.length ? row[idx].toString().trim() : '';

      final name = get(nameIdx);
      final surname = get(surnameIdx);
      final email = get(emailIdx);
      final login = get(loginIdx);
      final password = get(passwordIdx);
      final groupName = get(groupIdx);

      String? error;
      if (name.isEmpty) {
        error = 'Не указано имя';
      } else if (surname.isEmpty) {
        error = 'Не указана фамилия';
      } else if (email.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        error = 'Некорректный email';
      } else if (login.isEmpty) {
        error = 'Не указан логин';
      } else if (password.length < 6) {
        error = 'Пароль < 6 символов';
      } else if (groupName.isEmpty) {
        error = 'Не указана группа';
      } else if (seenLogins.contains(login.toLowerCase())) {
        error = 'Дубль логина в файле';
      } else if (seenEmails.contains(email.toLowerCase())) {
        error = 'Дубль email в файле';
      }

      if (login.isNotEmpty) seenLogins.add(login.toLowerCase());
      if (email.isNotEmpty) seenEmails.add(email.toLowerCase());

      parsed.add(
        StudentImportRow(
          rowIndex: i,
          name: name,
          surname: surname,
          email: email,
          login: login,
          password: password,
          groupName: groupName,
          error: error,
        ),
      );
    }

    if (parsed.isEmpty) return const CsvParseResult(rows: [], fatalError: 'В файле нет строк с данными.');

    return CsvParseResult(rows: parsed);
  }
}
