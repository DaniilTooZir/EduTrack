import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/lesson_comment.dart';

class LessonCommentService {
  final SupabaseClient _client;
  LessonCommentService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  Future<List<LessonComment>> getCommentsByLessonId(int lessonId) async {
    try {
      final response = await _client
          .from('lesson_comments')
          .select()
          .eq('lesson_id', lessonId)
          .order('timestamp', ascending: true);
      return (response as List<dynamic>).map((e) => LessonComment.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке комментариев: $e');
    }
  }

  Future<void> addComment(LessonComment comment) async {
    try {
      await _client.from('lesson_comments').insert(comment.toMap());
    } catch (e) {
      throw Exception('Ошибка при добавлении комментария: $e');
    }
  }
}
