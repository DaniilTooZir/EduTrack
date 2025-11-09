import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/grade.dart';

class GradeService {
  final SupabaseClient _client;
  GradeService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  Future<void> addOrUpdateGrade(Grade grade) async {
    try {
      final existing =
          await _client
              .from('grades')
              .select()
              .eq('lessons_id', grade.lessonId)
              .eq('student_id', grade.studentId)
              .maybeSingle();
      if (existing != null) {
        final id = existing['id'] as int;
        await _client.from('grades').update({'value': grade.value}).eq('id', id);
      } else {
        await _client.from('grades').insert(grade.toMap());
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении/обновлении оценки: $e');
    }
  }

  Future<List<Grade>> getGradesByStudent(String studentId) async {
    try {
      final response = await _client
          .from('grades')
          .select()
          .eq('student_id', studentId)
          .order('lessons_id', ascending: true);

      return (response as List<dynamic>).map((e) => Grade.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при получении оценок студента: $e');
    }
  }

  Future<List<Grade>> getGradesByLesson(int lessonId) async {
    try {
      final response = await _client.from('grades').select().eq('lessons_id', lessonId);

      return (response as List<dynamic>).map((e) => Grade.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при получении оценок урока: $e');
    }
  }
}
