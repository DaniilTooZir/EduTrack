import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherService {
  final SupabaseClient _client;
  TeacherService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Teacher>>> getTeachers(String institutionId) async {
    try {
      final response = await _client.from('teachers').select().eq('institution_id', institutionId);
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Teacher.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка преподавателей: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список преподавателей.');
    }
  }

  Future<AppResult<Teacher?>> getTeacherById(String id) async {
    try {
      final response = await _client.from('teachers').select().eq('id', id).single();
      return AppResult.success(Teacher.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке данных преподавателя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные преподавателя.');
    }
  }

  Future<AppResult<void>> updateTeacherData(String id, Map<String, dynamic> updatedData) async {
    try {
      await _client.from('teachers').update(updatedData).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Пользователь с таким Email или Логином уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при обновлении данных преподавателя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить данные преподавателя.');
    }
  }
}
