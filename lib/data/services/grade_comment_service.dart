import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradeCommentService {
  final SupabaseClient _supabase;

  GradeCommentService({SupabaseClient? client}) : _supabase = client ?? Supabase.instance.client;

  Future<AppResult<String?>> getComment(String gradeId) async {
    try {
      final data = await _supabase.from('grade_comments').select('message').eq('grade_id', gradeId).maybeSingle();
      return AppResult.success(data?['message']?.toString());
    } catch (_) {
      return AppResult.failure('Не удалось загрузить комментарий.');
    }
  }

  Future<AppResult<Map<String, String>>> getCommentsByGradeIds(List<String> gradeIds) async {
    if (gradeIds.isEmpty) return AppResult.success({});
    try {
      final data = await _supabase.from('grade_comments').select('grade_id, message').inFilter('grade_id', gradeIds);
      final map = <String, String>{};
      for (final row in data as List) {
        final id = row['grade_id']?.toString();
        final msg = row['message']?.toString();
        if (id != null && msg != null && msg.isNotEmpty) map[id] = msg;
      }
      return AppResult.success(map);
    } catch (_) {
      return AppResult.failure('Не удалось загрузить комментарии.');
    }
  }

  Future<AppResult<void>> saveOrUpdate({
    required String gradeId,
    required String teacherId,
    required String message,
  }) async {
    try {
      final existing = await _supabase.from('grade_comments').select('id').eq('grade_id', gradeId).maybeSingle();
      if (existing != null) {
        await _supabase
            .from('grade_comments')
            .update({'message': message, 'timestamp': DateTime.now().toIso8601String()})
            .eq('grade_id', gradeId);
      } else {
        await _supabase.from('grade_comments').insert({
          'grade_id': gradeId,
          'sender_teacher_id': teacherId,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
      return AppResult.success(null);
    } catch (_) {
      return AppResult.failure('Не удалось сохранить комментарий.');
    }
  }

  Future<AppResult<void>> delete(String gradeId) async {
    try {
      await _supabase.from('grade_comments').delete().eq('grade_id', gradeId);
      return AppResult.success(null);
    } catch (_) {
      return AppResult.failure('Не удалось удалить комментарий.');
    }
  }
}
