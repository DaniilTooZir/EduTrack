import 'package:supabase_flutter/supabase_flutter.dart';

class UserAddService {
  final SupabaseClient _client;

  UserAddService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<void> addStudent({
    required String name,
    required String surname,
    required String email,
    required String login,
    required String password,
    required String institutionId,
    required String groupId,
  }) async {
    try {
      final response = await _client.from('students').insert({
        'name': name,
        'surname': surname,
        'email': email,
        'login': login,
        'password': password,
        'institution_id': institutionId,
        'group_id': groupId,
      }).select().single();

      if (response == null) {
        throw Exception('Пустой ответ от сервера при добавлении студента');
      }
      print('[UserAddService] Студент успешно добавлен: $response');
    } catch (e, stackTrace) {
      print('[UserAddService] Ошибка при добавлении студента: $e');
      print('[UserAddService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addTeacher({
    required String name,
    required String surname,
    required String email,
    required String login,
    required String password,
    required String institutionId,
  }) async {
    try {
      final response = await _client.from('teachers').insert({
        'name': name,
        'surname': surname,
        'email': email,
        'login': login,
        'password': password,
        'institution_id': institutionId,
      }).select().single();

      if (response == null) {
        throw Exception('Пустой ответ от сервера при добавлении преподавателя');
      }
      print('[UserAddService] Преподаватель успешно добавлен: $response');
    } catch (e, stackTrace) {
      print('[UserAddService] Ошибка при добавлении преподавателя: $e');
      print('[UserAddService] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addScheduleOperator({
    required String name,
    required String surname,
    required String email,
    required String login,
    required String password,
    required String institutionId,
  }) async {
    try {
      final response = await _client.from('schedule_operators').insert({
        'name': name,
        'surname': surname,
        'email': email,
        'login': login,
        'password': password,
        'institution_id': institutionId,
      }).select().single();

      if (response == null) {
        throw Exception('Пустой ответ от сервера при добавлении оператора');
      }
      print('[UserAddService] Оператор расписания успешно добавлен: $response');
    } catch (e, stackTrace) {
      print('[UserAddService] Ошибка при добавлении оператора расписания: $e');
      print('[UserAddService] StackTrace: $stackTrace');
      rethrow;
    }
  }
}