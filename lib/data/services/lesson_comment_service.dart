import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonCommentService {
  final _client = Supabase.instance.client;

  Stream<List<LessonComment>> getCommentsStream(String lessonId) {
    return _client.from('lesson_comment').stream(primaryKey: ['id']).eq('lesson_id', lessonId).order('timestamp').map((
      rows,
    ) {
      final seen = <String>{};
      return rows.where((row) => seen.add(row['id']?.toString() ?? '')).map(LessonComment.fromMap).toList();
    });
  }

  Future<AppResult<List<LessonComment>>> getCommentsByLessonId(String lessonId) async {
    try {
      final response = await _client
          .from('lesson_comment')
          .select()
          .eq('lesson_id', lessonId)
          .order('timestamp', ascending: false);
      return AppResult.success(
        (response as List<dynamic>).map((json) => LessonComment.fromMap(json as Map<String, dynamic>)).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке комментариев урока: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить комментарии урока.');
    }
  }

  Future<AppResult<Map<String, int>>> getTeacherCommentCountsForLessons(List<String> lessonIds) async {
    try {
      if (lessonIds.isEmpty) return AppResult.success({});
      final response = await _client
          .from('lesson_comment')
          .select('lesson_id')
          .inFilter('lesson_id', lessonIds)
          .not('sender_teacher_id', 'is', null);
      final counts = <String, int>{};
      for (final row in response as List<dynamic>) {
        final id = row['lesson_id'] as String;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return AppResult.success(counts);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить счётчики комментариев.');
    }
  }

  Future<AppResult<void>> addComment(LessonComment comment) async {
    try {
      await _client.from('lesson_comment').insert(comment.toMap());
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при добавлении комментария: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось отправить комментарий.');
    }
  }

  Future<String> getSenderName(String userId, String role) async {
    final table = role == 'teacher' ? 'teachers' : 'students';
    try {
      final response = await _client.from(table).select('name, surname').eq('id', userId).single();
      return '${response['surname']} ${response['name']}';
    } catch (_) {
      return role == 'teacher' ? 'Преподаватель' : 'Студент';
    }
  }
}
