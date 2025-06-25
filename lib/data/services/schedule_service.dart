import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final SupabaseClient _client;
  ScheduleService({SupabaseClient? client})
    : _client = client ?? SupabaseConnection.client;
  Future<List<Schedule>> getScheduleForInstitution(String institutionId) async {
    try {
      final response = await _client
          .from('schedule')
          .select()
          .eq('institution_id', institutionId)
          .order('weekday')
          .order('start_time');

      if (response == null) {
        throw Exception('Пустой ответ при загрузке расписания');
      }
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => Schedule.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки расписания: $e');
    }
  }

  Future<void> addScheduleEntry({
    required String institutionId,
    required String subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
    required String groupId,
  }) async {
    try {
      final response =
          await _client
              .from('schedule')
              .insert({
                'institution_id': institutionId,
                'subject_id': subjectId,
                'weekday': weekday,
                'start_time': startTime,
                'end_time': endTime,
                'group_id': groupId,
              })
              .select()
              .single();
      if (response == null) {
        throw Exception('Пустой ответ при добавлении расписания');
      }
    } catch (e) {
      throw Exception('Ошибка добавления расписания: $e');
    }
  }

  Future<void> deleteScheduleEntry(String id) async {
    try {
      final response = await _client.from('schedule').delete().eq('id', id);
      if (response == null) {
        throw Exception('Пустой ответ при удалении записи расписания');
      }
    } catch (e) {
      throw Exception('Ошибка удаления записи расписания: $e');
    }
  }

  Future<List<Schedule>> getScheduleForStudent(String studentId) async {
    final student =
        await _client
            .from('students')
            .select('group_id')
            .eq('id', studentId)
            .single();
    final groupId = student['group_id'] as String;
    final response = await _client
        .from('schedule')
        .select('*, subject:subjects(*)')
        .eq('group_id', groupId);
    return (response as List)
        .map((e) => Schedule.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Schedule>> getScheduleForTeacher(String teacherId) async {
    final subjectsResponse = await _client
        .from('subjects')
        .select('id')
        .eq('teacher_id', teacherId);
    final subjectIds =
        (subjectsResponse as List).map((s) => s['id'] as String).toList();
    final response = await _client
        .from('schedule')
        .select('*, subject:subjects(*), group:groups(*)')
        .filter('subject_id', 'in', '(${subjectIds.join(',')})');
    return (response as List)
        .map((e) => Schedule.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
