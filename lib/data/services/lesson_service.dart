import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/lesson.dart';

class LessonService {
  final SupabaseClient _client;
  LessonService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  Future<void> addLesson(Lesson lesson) async {
    try {
      await _client.from('lessons').insert(lesson.toMap()).select().single();
    } catch (e) {
      throw Exception('Ошибка при добавлении урока: $e');
    }
  }

  Future<List<Lesson>> getLessonsByScheduleId(String scheduleId) async {
    try {
      final response = await _client
          .from('lessons')
          .select()
          .eq('schedule_id', scheduleId)
          .order('id', ascending: true);
      return (response as List<dynamic>).map((e) => Lesson.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при получении уроков: $e');
    }
  }

  Future<Lesson?> getLessonById(int id) async {
    try {
      final response = await _client.from('lessons').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return Lesson.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Ошибка при получении урока: $e');
    }
  }
}
