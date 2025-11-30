import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/teacher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherService {
  final SupabaseClient _client;
  TeacherService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<List<Teacher>> getTeachers(String institutionId) async {
    try {
      final response = await _client.from('teachers').select().eq('institution_id', institutionId);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Teacher.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки преподавателей: $e');
    }
  }

  Future<Teacher?> getTeacherById(String id) async {
    try {
      final response = await _client.from('teachers').select().eq('id', id).single();
      return Teacher.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка загрузки данных преподавателя: $e');
    }
  }

  Future<void> updateTeacherData(String id, Map<String, dynamic> updatedData) async {
    try {
      await _client.from('teachers').update(updatedData).eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Пользователь с таким Email или Логином уже существует');
      }
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка при обновлении: $e');
    }
  }
}
