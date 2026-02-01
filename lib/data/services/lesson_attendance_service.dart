import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService {
  final SupabaseClient _client;
  AttendanceService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<bool> addOrUpdateAttendance(LessonAttendance attendance) async {
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
      return true;
    } catch (e) {
      print('Ошибка при добавлении посещаемости: $e');
      return false;
    }
  }

  Future<List<LessonAttendance>> getAttendanceByLesson(String lessonId) async {
    try {
      final response = await _client.from('lesson_attendances').select().eq('lesson_id', lessonId);
      return (response as List).map((map) => LessonAttendance.fromMap(map)).toList();
    } catch (e) {
      print('Ошибка при получении посещаемости: $e');
      return [];
    }
  }
}
