import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/grade.dart';

class GradeService {
  final _supabase = Supabase.instance.client;

  Future<bool> addOrUpdateGrade(Grade grade) async {
    try {
      final existing =
          await _supabase
              .from('grade')
              .select()
              .eq('lessons_id', grade.lessonId)
              .eq('student_id', grade.studentId)
              .maybeSingle();
      if (existing != null) {
        final id = existing['id'];
        await _supabase.from('grade').update({'value': grade.value}).eq('id', id);
      } else {
        await _supabase.from('grade').insert(grade.toMap());
      }
      return true;
    } catch (e) {
      print('Ошибка при добавлении/обновлении оценки: $e');
      return false;
    }
  }

  Future<List<Grade>> getGradesByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('grade')
          .select()
          .eq('student_id', studentId)
          .order('lessons_id', ascending: false);
      return (response as List).map((map) => Grade.fromMap(map)).toList();
    } catch (e) {
      print('Ошибка при получении оценок: $e');
      return [];
    }
  }

  Future<List<Grade>> getGradesByLesson(int lessonId) async {
    try {
      final response = await _supabase.from('grade').select().eq('lessons_id', lessonId);
      return (response as List).map((map) => Grade.fromMap(map)).toList();
    } catch (e) {
      print('Ошибка при получении оценок по уроку: $e');
      return [];
    }
  }
}
