import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersFetchService {
  final SupabaseClient _client;

  UsersFetchService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<AppResult<List<Map<String, dynamic>>>> fetchTeachers(String institutionId) async {
    try {
      final response = await _client
          .from('teachers')
          .select('id, name, surname, email, login')
          .eq('institution_id', institutionId);
      return AppResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка преподавателей: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список преподавателей.');
    }
  }

  Future<AppResult<List<Map<String, dynamic>>>> fetchScheduleOperators(String institutionId) async {
    try {
      final response = await _client
          .from('schedule_operators')
          .select('id, name, surname, email, login')
          .eq('institution_id', institutionId);
      return AppResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка операторов расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список операторов расписания.');
    }
  }

  Future<AppResult<List<Map<String, dynamic>>>> fetchStudents(String institutionId) async {
    try {
      final response = await _client
          .from('students')
          .select('id, name, surname, email, login, group_id, groups!inner(name, institution_id)')
          .eq('groups.institution_id', institutionId);
      final List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(response);
      return AppResult.success(
        students.map((student) {
          final group = (student['groups'] as Map<String, dynamic>?);
          return {
            ...student,
            'group_name': group != null ? group['name'] : 'Без группы',
            'class_number': student['group_id'],
          };
        }).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка студентов: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список студентов.');
    }
  }

  Future<AppResult<void>> deleteUserById(String id, String role) async {
    try {
      String table;
      switch (role) {
        case 'teacher':
          table = 'teachers';
          break;
        case 'schedule_operator':
          table = 'schedule_operators';
          break;
        default:
          table = 'students';
      }
      await _client.from(table).delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при удалении пользователя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить пользователя.');
    }
  }
}
