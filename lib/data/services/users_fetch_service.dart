import 'package:supabase_flutter/supabase_flutter.dart';

class UsersFetchService {
  final SupabaseClient _client;

  UsersFetchService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTeachers(String institutionId) async {
    final response = await _client
        .from('teachers')
        .select('id, name, surname, email, login')
        .eq('institution_id', institutionId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchScheduleOperators(String institutionId) async {
    final response = await _client
        .from('schedule_operators')
        .select('id, name, surname, email, login')
        .eq('institution_id', institutionId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchStudents(String institutionId) async {
    final response = await _client
        .from('students')
        .select('id, name, surname, email, login, group_id, groups(name)')
        .eq('institution_id', institutionId);
    final List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(response);
    return students.map((student) {
      final group = (student['groups'] as Map<String, dynamic>?);
      return {
        ...student,
        'group_name': group != null ? group['name'] : 'Без группы',
        'class_number': student['group_id'],
      };
    }).toList();
  }

  Future<void> deleteUserById(String id, String role) async {
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
  }
}
