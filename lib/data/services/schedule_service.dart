import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final SupabaseClient _client;

  ScheduleService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Schedule>>> getScheduleForInstitution(String institutionId) async {
    try {
      final response = await _client
          .from('schedule')
          .select('*, subject:subjects(*), group:groups(*), teacher:teachers(*)')
          .eq('institution_id', institutionId)
          .order('weekday', ascending: true)
          .order('start_time', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
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
      return AppResult.failure('Ошибка при удалении записи расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить запись расписания.');
    }
  }

  /// Offline-first: on network failure returns AppResult.success with local data.
  Future<AppResult<List<Schedule>>> getScheduleForStudent(
    String studentId,
    String? groupId,
    AppDatabase db,
  ) async {
    if (groupId == null) {
      return AppResult.failure('ID группы не найден локально.');
    }
    try {
      final response = await _client
          .from('schedule')
          .select('*, subject:subjects(*), teacher:teachers(*), group:groups(*)')
          .eq('group_id', groupId);
      final networkSchedules = (response as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
      await db.saveSchedules(networkSchedules);
      return AppResult.success(networkSchedules);
    } catch (e) {
      final localData = await db.getSchedulesForGroup(groupId);
      return AppResult.success(localData);
    }
  }

  /// Offline-first: on network failure returns AppResult.success with local data.
  Future<AppResult<List<Schedule>>> getScheduleForTeacher(String teacherId, AppDatabase db) async {
    try {
      final response = await _client
          .from('schedule')
          .select('*, subject:subjects(*), group:groups(*)')
          .eq('teacher_id', teacherId);
      final networkSchedules = (response as List).map((e) => Schedule.fromMap(e as Map<String, dynamic>)).toList();
      networkSchedules.sort((a, b) {
        if (a.date != null && b.date != null) {
          return a.date!.compareTo(b.date!);
        }
        if (a.date != null) return -1;
        if (b.date != null) return 1;
        final weekdayCompare = a.weekday.compareTo(b.weekday);
        if (weekdayCompare != 0) return weekdayCompare;
        return a.startTime.compareTo(b.startTime);
      });
      await db.saveSchedules(networkSchedules);
      return AppResult.success(networkSchedules);
    } catch (e) {
      final localData = await db.getSchedulesForTeacher(teacherId);
      return AppResult.success(localData);
    }
  }

  Future<AppResult<String?>> checkConflict({
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

  Future<AppResult<void>> copyScheduleToNextWeek(String institutionId, DateTime startOfCurrentWeek) async {
    try {
      final endOfCurrentWeek = startOfCurrentWeek.add(const Duration(days: 6));
      final response = await _client
          .from('schedule')
          .select()
          .eq('institution_id', institutionId)
          .gte('date', startOfCurrentWeek.toIso8601String())
          .lte('date', endOfCurrentWeek.toIso8601String());
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return AppResult.failure('На этой неделе нет занятий для копирования.');
      }
      final newEntries = data.map((item) {
        final oldDate = DateTime.parse(item['date']);
        final newDate = oldDate.add(const Duration(days: 7));
        final newItem = Map<String, dynamic>.from(item);
        newItem.remove('id');
        newItem['date'] = newDate.toIso8601String();
        return newItem;
      }).toList();
      await _client.from('schedule').insert(newEntries);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при копировании расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось скопировать расписание на следующую неделю.');
    }
  }
}
