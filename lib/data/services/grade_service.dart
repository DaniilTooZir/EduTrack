import 'package:edu_track/models/grade.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradeService {
  final _supabase = Supabase.instance.client;

  Future<AppResult<bool>> addOrUpdateGrade(Grade grade) async {
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
      return AppResult.success(true);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при сохранении оценки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось сохранить оценку. Попробуйте позже.');
    }
  }

  Future<AppResult<List<Grade>>> getGradesByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('grade')
          .select()
          .eq('student_id', studentId)
          .order('lessons_id', ascending: false);
      return AppResult.success((response as List).map((map) => Grade.fromMap(map)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении оценок студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить оценки студента.');
    }
  }

  Future<AppResult<List<Grade>>> getGradesByLesson(String lessonId) async {
    try {
      final response = await _supabase.from('grade').select().eq('lessons_id', lessonId);
      return AppResult.success((response as List).map((map) => Grade.fromMap(map)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении оценок урока: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить оценки урока.');
    }
  }
}
