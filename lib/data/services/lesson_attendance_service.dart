import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient _client;
  AttendanceService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<bool>> addOrUpdateAttendance(LessonAttendance attendance) async {
    try {
      final existing =
          await _client
              .from('lesson_attendances')
              .select('id')
              .eq('lesson_id', attendance.lessonId)
              .eq('student_id', attendance.studentId)
              .maybeSingle();
      if (existing != null) {
        final id = existing['id'] as int;
        await _client.from('lesson_attendances').update({'status': attendance.status}).eq('id', id);
      } else {
        await _client.from('lesson_attendances').insert(attendance.toMap());
      }
      return AppResult.success(true);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при сохранении посещаемости: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось сохранить данные о посещаемости.');
    }
  }

  Future<AppResult<List<LessonAttendance>>> getAttendanceByLesson(String lessonId) async {
    try {
      final response = await _client.from('lesson_attendances').select().eq('lesson_id', lessonId);
      return AppResult.success((response as List).map((map) => LessonAttendance.fromMap(map)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении данных посещаемости: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные о посещаемости.');
    }
  }
}
