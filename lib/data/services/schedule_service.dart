import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final SupabaseClient _client;
  ScheduleService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Schedule>>> getScheduleForInstitution(
    String institutionId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('schedule')
          .select('*, subject:subjects(*), group:groups(*), teacher:teachers(*)')
          .eq('institution_id', institutionId);
      if (startDate != null) query = query.gte('date', startDate.toIso8601String());
      if (endDate != null) query = query.lte('date', endDate.toIso8601String());
      final List<dynamic> data = await query as List<dynamic>;
      return AppResult.success(data.map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке расписания учреждения: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить расписание учреждения.');
    }
  }

  Future<AppResult<Schedule?>> getScheduleById(String id) async {
    try {
      final response =
          await _client.from('schedule').select('*, subject:subjects(*), group:groups(*)').eq('id', id).maybeSingle();
      if (response == null) return AppResult.success(null);
      return AppResult.success(Schedule.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке записи расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить запись расписания.');
    }
  }

  Future<AppResult<void>> addScheduleEntry({
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String teacherId,
    required DateTime date,
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
        'weekday': date.weekday,
        'start_time': startTime,
        'end_time': endTime,
      });
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('На это время у группы уже есть урок.');
      }
      return AppResult.failure('Ошибка базы данных при добавлении в расписание: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось добавить запись в расписание.');
    }
  }

  Future<AppResult<void>> deleteScheduleEntry(String id) async {
    try {
      await _client.from('schedule').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить урок: на него есть ссылки в оценках или посещаемости.');
      }
      return AppResult.failure('Ошибка при удалении записи расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить запись расписания.');
    }
  }

  Future<AppResult<List<Schedule>>> getScheduleForStudent(
    String studentId,
    String groupId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('schedule')
          .select('*, subject:subjects(*), teacher:teachers(*), group:groups(*)')
          .eq('group_id', groupId);
      if (startDate != null) query = query.gte('date', startDate.toIso8601String());
      if (endDate != null) query = query.lte('date', endDate.toIso8601String());
      final schedules = (await query as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
      return AppResult.success(schedules);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить расписание.');
    }
  }

  Future<AppResult<List<Schedule>>> getScheduleForTeacher(
    String teacherId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('schedule')
          .select('*, subject:subjects(*), group:groups(*)')
          .eq('teacher_id', teacherId);
      if (startDate != null) query = query.gte('date', startDate.toIso8601String());
      if (endDate != null) query = query.lte('date', endDate.toIso8601String());
      final schedules = (await query as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
      schedules.sort((a, b) {
        if (a.date != null && b.date != null) return a.date!.compareTo(b.date!);
        if (a.date != null) return -1;
        if (b.date != null) return 1;
        final weekdayCompare = a.weekday.compareTo(b.weekday);
        if (weekdayCompare != 0) return weekdayCompare;
        return a.startTime.compareTo(b.startTime);
      });
      return AppResult.success(schedules);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить расписание.');
    }
  }

  Future<AppResult<String?>> checkConflict({
    required String institutionId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String teacherId,
    required String groupId,
    String? excludeId,
  }) async {
    try {
      final dateStr = date.toIso8601String();
      var query = _client
          .from('schedule')
          .select('group_id, teacher_id, start_time, end_time')
          .eq('institution_id', institutionId)
          .eq('date', dateStr)
          .lt('start_time', endTime)
          .gt('end_time', startTime);
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }
      final List<dynamic> conflicts = await query as List<dynamic>;
      for (final lesson in conflicts) {
        final existingTeacher = lesson['teacher_id'] as String;
        final existingGroup = lesson['group_id'] as String;
        if (existingTeacher == teacherId) {
          return AppResult.success('Этот преподаватель уже занят в указанное время!');
        }
        if (existingGroup == groupId) {
          return AppResult.success('У этой группы уже есть урок в указанное время!');
        }
      }
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при проверке конфликтов расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось проверить конфликты расписания.');
    }
  }

  Future<AppResult<({int copied, int skipped})>> copyScheduleToWeek(
    String institutionId,
    DateTime sourceWeekStart,
    DateTime targetWeekStart,
  ) async {
    try {
      final sourceWeekEnd = sourceWeekStart.add(const Duration(days: 6));
      final targetWeekEnd = targetWeekStart.add(const Duration(days: 6));

      final currentData = await _client
          .from('schedule')
          .select()
          .eq('institution_id', institutionId)
          .gte('date', sourceWeekStart.toIso8601String())
          .lte('date', sourceWeekEnd.toIso8601String());
      final List<Map<String, dynamic>> source = (currentData as List).cast<Map<String, dynamic>>();
      if (source.isEmpty) {
        return AppResult.failure('На выбранной неделе нет занятий для копирования.');
      }

      final nextWeekData = await _client
          .from('schedule')
          .select('group_id, teacher_id, date, start_time, end_time')
          .eq('institution_id', institutionId)
          .gte('date', targetWeekStart.toIso8601String())
          .lte('date', targetWeekEnd.toIso8601String());
      final List<Map<String, dynamic>> existing = (nextWeekData as List).cast<Map<String, dynamic>>();
      final offset = targetWeekStart.difference(sourceWeekStart);
      final toInsert = <Map<String, dynamic>>[];
      int skipped = 0;
      for (final item in source) {
        final oldDate = DateTime.parse(item['date'] as String);
        final newDate = oldDate.add(offset);
        final startTime = item['start_time'] as String;
        final endTime = item['end_time'] as String;
        final teacherId = item['teacher_id'] as String;
        final groupId = item['group_id'] as String;

        final hasConflict = existing.any((e) {
          final eDate = DateTime.parse(e['date'] as String);
          if (eDate.year != newDate.year || eDate.month != newDate.month || eDate.day != newDate.day) {
            return false;
          }
          final eStart = e['start_time'] as String;
          final eEnd = e['end_time'] as String;
          if (eStart.compareTo(endTime) >= 0 || eEnd.compareTo(startTime) <= 0) return false;
          return e['teacher_id'] == teacherId || e['group_id'] == groupId;
        });
        if (hasConflict) {
          skipped++;
        } else {
          final newItem = Map<String, dynamic>.from(item);
          newItem.remove('id');
          newItem['date'] = newDate.toIso8601String();
          toInsert.add(newItem);
        }
      }
      if (toInsert.isNotEmpty) {
        await _client.from('schedule').insert(toInsert);
      }
      return AppResult.success((copied: toInsert.length, skipped: skipped));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при копировании расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось скопировать расписание на следующую неделю.');
    }
  }

  Future<AppResult<void>> updateScheduleEntry({
    required String id,
    required String subjectId,
    required String groupId,
    required String teacherId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _client
          .from('schedule')
          .update({
            'subject_id': subjectId,
            'group_id': groupId,
            'teacher_id': teacherId,
            'date': date.toIso8601String(),
            'weekday': date.weekday,
            'start_time': startTime,
            'end_time': endTime,
          })
          .eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при обновлении записи расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить запись расписания.');
    }
  }
}
