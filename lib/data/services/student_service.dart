import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final SupabaseClient _client;

  StudentService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<Student?>> getStudentById(String studentId) async {
    try {
      final response = await _client.from('students').select().eq('id', studentId).single();
      return AppResult.success(Student.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении данных студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные студента.');
    }
  }

  Future<AppResult<List<Student>>> getStudentsByGroupId(String groupId) async {
    try {
      final response = await _client
          .from('students')
          .select('*, groups(*)')
          .eq('group_id', groupId)
          .order('surname', ascending: true);
      return AppResult.success((response as List).map((map) => Student.fromMap(map)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении списка студентов группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить студентов группы.');
    }
  }

  Future<AppResult<Schedule?>> getScheduleById(String scheduleId) async {
    try {
      final response = await _client.from('schedule').select().eq('id', scheduleId).single();
      return AppResult.success(Schedule.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении расписания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить расписание.');
    }
  }

  Future<AppResult<void>> updateStudentData(String studentId, Map<String, dynamic> updatedFields) async {
    try {
      await _client.from('students').update(updatedFields).eq('id', studentId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Пользователь с таким Email или Логином уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при обновлении данных студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить данные студента.');
    }
  }

  Future<AppResult<void>> setHeadman(String groupId, String newHeadmanId) async {
    try {
      await _client.from('students').update({'isheadman': false}).eq('group_id', groupId);
      await _client.from('students').update({'isheadman': true}).eq('id', newHeadmanId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при назначении старосты: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось назначить старосту.');
    }
  }
}
