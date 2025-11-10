import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client;

  DashboardService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  Future<int> getStudentCount(String institutionId) async {
    final response = await _client.from('students').select('id').eq('institution_id', institutionId);
    return (response as List).length;
  }

  Future<int> getTeacherCount(String institutionId) async {
    final response = await _client.from('teachers').select('id').eq('institution_id', institutionId);
    return (response as List).length;
  }

  Future<int> getGroupCount(String institutionId) async {
    final response = await _client.from('groups').select('id').eq('institution_id', institutionId);
    return (response as List).length;
  }

  Future<int> getSubjectCount(String institutionId) async {
    final response = await _client.from('subjects').select('id').eq('institution_id', institutionId);
    return (response as List).length;
  }
}
