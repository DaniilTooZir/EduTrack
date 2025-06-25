import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/student.dart';

class StudentService {
  final SupabaseClient _client;
  StudentService({SupabaseClient? client})
    : _client = client ?? SupabaseConnection.client;
  Future<Student?> getStudentById(String studentId) async {
    try {
      final response =
          await _client.from('students').select().eq('id', studentId).single();
      if (response == null) return null;
      return Student.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка при получении данных студента: $e');
    }
  }

  Future<void> updateStudentData(
    String studentId,
    Map<String, dynamic> updatedFields,
  ) async {
    try {
      final response =
          await _client
              .from('students')
              .update(updatedFields)
              .eq('id', studentId)
              .select()
              .single();
      if (response == null) {
        throw Exception('Обновление не удалось: пустой ответ');
      }
    } catch (e) {
      throw Exception('Ошибка при обновлении данных студента: $e');
    }
  }
}
