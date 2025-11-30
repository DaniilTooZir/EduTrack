import 'package:edu_track/models/lesson_comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonCommentService {
  final _client = Supabase.instance.client;
  Future<List<LessonComment>> getCommentsByLessonId(int lessonId) async {
    try {
      final response = await _client
          .from('lesson_comment')
          .select()
          .eq('lesson_id', lessonId)
          .order('timestamp', ascending: false);
      return (response as List<dynamic>).map((json) => LessonComment.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Ошибка при загрузке комментариев: $e');
      throw Exception('Не удалось загрузить чат');
    }
  }

  Future<void> addComment(LessonComment comment) async {
    try {
      await _client.from('lesson_comment').insert(comment.toMap());
    } catch (e) {
      print('Ошибка при добавлении комментария: $e');
      throw Exception('Не удалось отправить сообщение');
    }
  }
}
