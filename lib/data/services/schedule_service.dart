import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final SupabaseClient _client;

  ScheduleService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<List<Schedule>> getScheduleForInstitution(String institutionId) async {
    try {
      final response = await _client
          .from('schedule')
          .select('*, subject:subjects(*), group:groups(*), teacher:teachers(*)')
          .eq('institution_id', institutionId)
          .order('weekday', ascending: true)
          .order('start_time', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки расписания: $e');
    }
  }

  Future<Schedule?> getScheduleById(String id) async {
    try {
      final response =
          await _client.from('schedule').select('*, subject:subjects(*), group:groups(*)').eq('id', id).maybeSingle();
      if (response == null) return null;
      return Schedule.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка при загрузке расписания по id: $e');
    }
  }

  Future<void> addScheduleEntry({
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String teacherId,
    required DateTime date,
    required int weekday,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _client.from('schedule').insert({
        'institution_id': institutionId,
        'subject_id': subjectId,
        'group_id': groupId,
        'teacher_id': teacherId,
        'date': date.toIso8601String(),
        'weekday': weekday,
        'start_time': startTime,
        'end_time': endTime,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('На это время у группы уже есть урок');
      }
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  Future<void> deleteScheduleEntry(String id) async {
    try {
      await _client.from('schedule').delete().eq('id', id);
    } catch (e) {
      throw Exception('Ошибка удаления записи расписания: $e');
    }
  }

  Future<List<Schedule>> getScheduleForStudent(String studentId) async {
    final student = await _client.from('students').select('group_id').eq('id', studentId).single();
    final groupId = student['group_id'] as String;
    final response = await _client.from('schedule').select('*, subject:subjects(*)').eq('group_id', groupId);
    return (response as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Schedule>> getScheduleForTeacher(String teacherId) async {
    final subjectsResponse = await _client.from('subjects').select('id').eq('teacher_id', teacherId);
    final subjectIds = (subjectsResponse as List).map((s) => s['id'].toString()).toList();
    if (subjectIds.isEmpty) return [];
    final response = await _client
        .from('schedule')
        .select('*, subject:subjects(*), group:groups(*)')
        .filter('subject_id', 'in', '(${subjectIds.join(',')})');
    final schedules = (response as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
    schedules.sort((a, b) {
      if (a.date != null && b.date != null) {
        return a.date!.compareTo(b.date!);
      }
      if (a.date != null) return -1;
      if (b.date != null) return 1;
      final weekdayCompare = a.weekday.compareTo(b.weekday);
      if (weekdayCompare != 0) return weekdayCompare;
      return a.startTime.compareTo(b.startTime);
    });

    return schedules;
  }

  Future<String?> checkConflict({
    required String institutionId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String teacherId,
    required String groupId,
  }) async {
    try {
      final dateStr = date.toIso8601String();
      final response = await _client
          .from('schedule')
          .select('group_id, teacher_id, start_time, end_time')
          .eq('institution_id', institutionId)
          .eq('date', dateStr)
          .lt('start_time', endTime)
          .gt('end_time', startTime);
      final List<dynamic> conflicts = response as List<dynamic>;
      for (final lesson in conflicts) {
        final existingTeacher = lesson['teacher_id'] as String;
        final existingGroup = lesson['group_id'] as String;
        if (existingTeacher == teacherId) {
          return 'Этот преподаватель уже занят в указанное время!';
        }
        if (existingGroup == groupId) {
          return 'У этой группы уже есть урок в указанное время!';
        }
      }
      return null;
    } catch (e) {
      print('Ошибка при проверке конфликтов: $e');
      return null;
    }
  }
}
