import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/lesson_comment.dart';

class LessonCommentService {
  final _client = Supabase.instance.client;

  Future<List<LessonComment>> getCommentsByLessonId(int lessonId) async {
    try {
      final response = await _client
          .from('lesson_comment')
          .select()
          .eq('lesson_id', lessonId)
          .order('timestamp', ascending: true);
      return (response as List<dynamic>).map((json) => LessonComment.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Ошибка при загрузке комментариев: $e');
      return [];
    }
  }

  Future<bool> addComment(LessonComment comment) async {
    try {
      await _client.from('lesson_comment').insert(comment.toMap());
      return true;
    } catch (e) {
      print('Ошибка при добавлении комментария: $e');
      return false;
    }
  }
}
