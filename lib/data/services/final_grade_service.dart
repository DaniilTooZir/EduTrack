import 'package:edu_track/models/final_grade.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinalGradeService {
  final SupabaseClient _supabase;
  FinalGradeService({SupabaseClient? client}) : _supabase = client ?? Supabase.instance.client;

  Future<AppResult<List<FinalGrade>>> getFinalGrades({
    required String groupId,
    required String subjectId,
    required String periodId,
  }) async {
    try {
      final response = await _supabase
          .from('final_grade')
          .select()
          .eq('group_id', groupId)
          .eq('subject_id', subjectId)
          .eq('period_id', periodId);
      final grades = (response as List).map((g) => FinalGrade.fromMap(g as Map<String, dynamic>)).toList();
      return AppResult.success(grades);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке итоговых оценок: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить итоговые оценки.');
    }
  }

  Future<AppResult<List<FinalGrade>>> getFinalGradesByStudent({
    required String studentId,
    required String periodId,
  }) async {
    try {
      final response = await _supabase
          .from('final_grade')
          .select()
          .eq('student_id', studentId)
          .eq('period_id', periodId);
      final grades = (response as List).map((g) => FinalGrade.fromMap(g as Map<String, dynamic>)).toList();
      return AppResult.success(grades);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке итоговых оценок студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить итоговые оценки студента.');
    }
  }

  Future<AppResult<String>> setFinalGrade(FinalGrade grade) async {
    try {
      final map = grade.toMap()..remove('id');
      final data =
          await _supabase
              .from('final_grade')
              .upsert(map, onConflict: 'student_id, subject_id, period_id')
              .select('id')
              .single();
      return AppResult.success(data['id'].toString());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при сохранении итоговой оценки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось сохранить итоговую оценку.');
    }
  }

  Future<AppResult<void>> clearFinalGrade({
    required String studentId,
    required String subjectId,
    required String periodId,
  }) async {
    try {
      await _supabase
          .from('final_grade')
          .delete()
          .eq('student_id', studentId)
          .eq('subject_id', subjectId)
          .eq('period_id', periodId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при удалении итоговой оценки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить итоговую оценку.');
    }
  }
}
