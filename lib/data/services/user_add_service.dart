import 'package:edu_track/utils/app_result.dart';
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
