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
          return {...student, 'group_name': group != null ? group['name'] : 'Без группы'};
        }).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка студентов: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список студентов.');
    }
  }

  Future<AppResult<List<Map<String, dynamic>>>> fetchTeachersForGroup(String groupId) async {
    try {
      final schedules = await _client.from('schedule').select('teacher_id').eq('group_id', groupId);
      final teacherIds = (schedules as List<dynamic>).map((s) => s['teacher_id'] as String).toSet().toList();
      if (teacherIds.isEmpty) return AppResult.success([]);
      final response = await _client
          .from('teachers')
          .select('id, name, surname, email, login')
          .inFilter('id', teacherIds);
      return AppResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке преподавателей группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить преподавателей группы.');
    }
  }

  Future<AppResult<List<Map<String, dynamic>>>> fetchGroupmates(String groupId) async {
    try {
      final response = await _client
          .from('students')
          .select('id, name, surname, email, login, group_id, groups!inner(name)')
          .eq('group_id', groupId);
      final students = List<Map<String, dynamic>>.from(response);
      return AppResult.success(
        students.map((s) {
          final group = s['groups'] as Map<String, dynamic>?;
          return {...s, 'group_name': group?['name'] ?? 'Без группы'};
        }).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке студентов группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить студентов группы.');
    }
  }

  Future<AppResult<List<Map<String, dynamic>>>> fetchStudentsForTeacher(String teacherId) async {
    try {
      final schedules = await _client.from('schedule').select('group_id').eq('teacher_id', teacherId);
      final groupIds = (schedules as List<dynamic>).map((s) => s['group_id'] as String).toSet().toList();
      if (groupIds.isEmpty) return AppResult.success([]);
      final response = await _client
          .from('students')
          .select('id, name, surname, email, login, group_id, groups!inner(name)')
          .inFilter('group_id', groupIds);
      final students = List<Map<String, dynamic>>.from(response);
      return AppResult.success(
        students.map((s) {
          final group = s['groups'] as Map<String, dynamic>?;
          return {...s, 'group_name': group?['name'] ?? 'Без группы'};
        }).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке студентов преподавателя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить студентов преподавателя.');
    }
  }

  Future<AppResult<void>> updateUser({
    required String id,
    required String role,
    required String name,
    required String surname,
    required String email,
    String? groupId,
  }) async {
    final table = switch (role) {
      'teacher' => 'teachers',
      'schedule_operator' => 'schedule_operators',
      _ => 'students',
    };
    try {
      final data = <String, dynamic>{'name': name, 'surname': surname, 'email': email};
      if (role == 'student' && groupId != null) data['group_id'] = groupId;
      await _client.from(table).update(data).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при обновлении: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось обновить пользователя.');
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
