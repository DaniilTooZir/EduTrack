import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonService {
  final SupabaseClient _client;
  LessonService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<void>> addLesson(Lesson lesson) async {
    try {
      await _client.from('lessons').insert(lesson.toMap());
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при добавлении урока: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось добавить урок.');
    }
  }

  Future<AppResult<List<Lesson>>> getLessonsByScheduleId(String scheduleId) async {
    try {
      final response = await _client
          .from('lessons')
          .select()
          .eq('schedule_id', scheduleId)
          .order('id', ascending: true);
      return AppResult.success(
        (response as List<dynamic>).map((e) => Lesson.fromMap(e as Map<String, dynamic>)).toList(),
      );
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке уроков расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить уроки.');
    }
  }

  Future<AppResult<Lesson?>> getLessonById(String id) async {
    try {
      final response = await _client.from('lessons').select().eq('id', id).maybeSingle();
      if (response == null) return AppResult.success(null);
      return AppResult.success(Lesson.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении урока: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить урок.');
    }
  }
}
