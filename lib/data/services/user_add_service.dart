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
}
