import 'package:edu_track/models/lesson_comment.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonCommentService {
  final _client = Supabase.instance.client;

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
}
