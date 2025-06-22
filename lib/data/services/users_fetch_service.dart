import 'package:supabase_flutter/supabase_flutter.dart';

class UsersFetchService {
  final SupabaseClient _client;

  UsersFetchService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTeachers(String institutionId) async {
    final response = await _client
        .from('teachers')
        .select('id, name, surname, email, login')
        .eq('institution_id', institutionId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchStudents(String institutionId) async {
    final response = await _client
        .from('students')
        .select('id, name, surname, email, login, class_number')
        .eq('institution_id', institutionId);
    return List<Map<String, dynamic>>.from(response);
  }
}