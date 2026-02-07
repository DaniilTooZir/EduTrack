import 'package:supabase_flutter/supabase_flutter.dart';

class UserAddService {
  final SupabaseClient _client;
  UserAddService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<void> addStudent({required Map<String, dynamic> userData, required String groupId}) async {
    final dataToInsert = Map<String, dynamic>.from(userData);
    dataToInsert.remove('institution_id');
    final fullData = {...dataToInsert, 'group_id': groupId, 'isheadman': false};
    await _insertUser('students', fullData, 'студента');
  }

  Future<void> addTeacher(Map<String, dynamic> userData) async {
    await _insertUser('teachers', userData, 'преподавателя');
  }

  Future<void> addScheduleOperator(Map<String, dynamic> userData) async {
    await _insertUser('schedule_operators', userData, 'оператора расписания');
  }

  Future<void> _insertUser(String table, Map<String, dynamic> data, String userTypeRu) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      print('[UserAddService] Успешно добавлен $userTypeRu: ${response['id']}');
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Пользователь с таким логином или email уже существует');
      }
      print('[UserAddService] Ошибка БД при добавлении $userTypeRu: ${e.message}');
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e, stackTrace) {
      print('[UserAddService] Неизвестная ошибка при добавлении $userTypeRu: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
