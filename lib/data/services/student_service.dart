import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/schedule.dart';
import 'package:edu_track/models/student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final SupabaseClient _client;

  StudentService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await _client.from('students').select().eq('id', studentId).single();
      return Student.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка при получении данных студента: $e');
    }
  }

  Future<List<Student>> getStudentsByGroupId(String groupId) async {
    try {
      final response = await _client
          .from('students')
          .select('*, groups(*)')
          .eq('group_id', groupId)
          .order('surname', ascending: true);
      return (response as List).map((map) => Student.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Ошибка при получении студентов группы: $e');
    }
  }

  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      final response = await _client.from('schedule').select().eq('id', scheduleId).single();
      return Schedule.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка при получении расписания: $e');
    }
  }

  Future<void> updateStudentData(String studentId, Map<String, dynamic> updatedFields) async {
    try {
      await _client.from('students').update(updatedFields).eq('id', studentId);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Пользователь с таким Email или Логином уже существует');
      }
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка при обновлении: $e');
    }
  }

  Future<void> setHeadman(String groupId, String newHeadmanId) async {
    try {
      await _client.from('students').update({'isheadman': false}).eq('group_id', groupId);
      await _client.from('students').update({'isheadman': true}).eq('id', newHeadmanId);
    } catch (e) {
      throw Exception('Не удалось назначить старосту: $e');
    }
  }
}
