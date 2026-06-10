import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/bulk_import_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAddService {
  final SupabaseClient _client;
  UserAddService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<AppResult<void>> addStudent({required Map<String, dynamic> userData, required String groupId}) async {
    final dataToInsert = Map<String, dynamic>.from(userData);
    dataToInsert.remove('institution_id');
    final fullData = {...dataToInsert, 'group_id': groupId, 'isheadman': false};
    return _insertUser('students', fullData, 'студента');
  }

  Future<AppResult<void>> addTeacher(Map<String, dynamic> userData) async {
    return _insertUser('teachers', userData, 'преподавателя');
  }

  Future<AppResult<void>> addScheduleOperator(Map<String, dynamic> userData) async {
    return _insertUser('schedule_operators', userData, 'оператора расписания');
  }

  Future<AppResult<BulkImportResult>> bulkAddTeachers({required List<Map<String, dynamic>> teachers}) async {
    if (teachers.isEmpty) return AppResult.success(const BulkImportResult(imported: 0, skippedReasons: []));

    final logins = teachers.map((t) => t['login'] as String).toList();
    final emails = teachers.map((t) => t['email'] as String).toList();
    const tables = ['education_heads', 'teachers', 'students', 'schedule_operators'];

    try {
      final loginResults = await Future.wait(
        tables.map((t) => _client.from(t).select('login').inFilter('login', logins)),
      );
      final emailResults = await Future.wait(
        tables.map((t) => _client.from(t).select('email').inFilter('email', emails)),
      );

      final takenLogins = <String>{};
      for (final res in loginResults) {
        takenLogins.addAll((res as List).map((r) => (r['login'] as String).toLowerCase()));
      }
      final takenEmails = <String>{};
      for (final res in emailResults) {
        takenEmails.addAll((res as List).map((r) => (r['email'] as String).toLowerCase()));
      }
      final toInsert = <Map<String, dynamic>>[];
      final skippedReasons = <String>[];

      for (final t in teachers) {
        final loginKey = (t['login'] as String).toLowerCase();
        final emailKey = (t['email'] as String).toLowerCase();
        if (takenLogins.contains(loginKey)) {
          skippedReasons.add('${t['name']} ${t['surname']}: логин "${t['login']}" уже занят');
        } else if (takenEmails.contains(emailKey)) {
          skippedReasons.add('${t['name']} ${t['surname']}: email "${t['email']}" уже используется');
        } else {
          toInsert.add(t);
          takenLogins.add(loginKey);
          takenEmails.add(emailKey);
        }
      }
      if (toInsert.isNotEmpty) {
        await _client.from('teachers').insert(toInsert);
      }
      return AppResult.success(BulkImportResult(imported: toInsert.length, skippedReasons: skippedReasons));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка базы данных: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось выполнить импорт преподавателей.');
    }
  }

  Future<AppResult<BulkImportResult>> bulkAddStudents({required List<Map<String, dynamic>> students}) async {
    if (students.isEmpty) return AppResult.success(const BulkImportResult(imported: 0, skippedReasons: []));

    final logins = students.map((s) => s['login'] as String).toList();
    final emails = students.map((s) => s['email'] as String).toList();
    const tables = ['education_heads', 'teachers', 'students', 'schedule_operators'];

    try {
      final loginResults = await Future.wait(
        tables.map((t) => _client.from(t).select('login').inFilter('login', logins)),
      );
      final emailResults = await Future.wait(
        tables.map((t) => _client.from(t).select('email').inFilter('email', emails)),
      );

      final takenLogins = <String>{};
      for (final res in loginResults) {
        takenLogins.addAll((res as List).map((r) => (r['login'] as String).toLowerCase()));
      }
      final takenEmails = <String>{};
      for (final res in emailResults) {
        takenEmails.addAll((res as List).map((r) => (r['email'] as String).toLowerCase()));
      }

      final toInsert = <Map<String, dynamic>>[];
      final skippedReasons = <String>[];

      for (final s in students) {
        final loginKey = (s['login'] as String).toLowerCase();
        final emailKey = (s['email'] as String).toLowerCase();
        if (takenLogins.contains(loginKey)) {
          skippedReasons.add('${s['name']} ${s['surname']}: логин "${s['login']}" уже занят');
        } else if (takenEmails.contains(emailKey)) {
          skippedReasons.add('${s['name']} ${s['surname']}: email "${s['email']}" уже используется');
        } else {
          toInsert.add({...s, 'isheadman': false});
          takenLogins.add(loginKey);
          takenEmails.add(emailKey);
        }
      }
      if (toInsert.isNotEmpty) {
        await _client.from('students').insert(toInsert);
      }
      return AppResult.success(BulkImportResult(imported: toInsert.length, skippedReasons: skippedReasons));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка базы данных: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось выполнить импорт.');
    }
  }

  Future<AppResult<void>> _insertUser(String table, Map<String, dynamic> data, String userTypeRu) async {
    final checkResult = await _checkLoginEmailUnique(data['login'] as String, data['email'] as String);
    if (checkResult.isFailure) return checkResult;
    try {
      await _client.from(table).insert(data).select().single();
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Пользователь с таким логином или email уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при добавлении $userTypeRu: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось добавить $userTypeRu.');
    }
  }

  Future<AppResult<void>> _checkLoginEmailUnique(String login, String email) async {
    const tables = ['education_heads', 'teachers', 'students', 'schedule_operators'];
    try {
      final loginResults = await Future.wait(
        tables.map((t) => _client.from(t).select('id').eq('login', login).maybeSingle()),
      );
      if (loginResults.any((r) => r != null)) {
        return AppResult.failure('Логин "$login" уже занят.');
      }
      final emailResults = await Future.wait(
        tables.map((t) => _client.from(t).select('id').eq('email', email).maybeSingle()),
      );
      if (emailResults.any((r) => r != null)) {
        return AppResult.failure('Email "$email" уже используется.');
      }
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка проверки уникальности: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось проверить уникальность логина и email.');
    }
  }
}
