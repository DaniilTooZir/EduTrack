import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/teacher.dart';

class TeacherService {
  final SupabaseClient _client;
  TeacherService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  Future<List<Teacher>> getTeachers(String institutionId) async {
    try {
      final response = await _client
          .from('teachers')
          .select()
          .eq('institution_id', institutionId);
      if (response == null) {
        throw Exception('Пустой ответ при получении преподавателей');
      }
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => Teacher.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки преподавателей: $e');
    }
  }
}
