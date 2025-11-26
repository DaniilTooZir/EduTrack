import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/data/database/connection_to_database.dart';

class SubjectService {
  final SupabaseClient _client;
  SubjectService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<List<Subject>> getSubjectsByTeacherId(String teacherId) async {
    try {
      final response = await _client.from('subjects').select().eq('teacher_id', teacherId).order('created_at');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Subject.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке предметов: $e');
    }
  }

  Future<List<Subject>> getSubjectsForInstitution(String institutionId) async {
    try {
      final response = await _client.from('subjects').select().eq('institution_id', institutionId).order('created_at');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Subject.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке предметов: $e');
    }
  }

  Future<void> addSubject({required String name, required String institutionId, required String teacherId}) async {
    try {
      await _client.from('subjects').insert({'name': name, 'institution_id': institutionId, 'teacher_id': teacherId});
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Предмет с таким названием уже существует');
      }
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  Future<void> updateSubject({required String id, required String name, required String teacherId}) async {
    try {
      await _client.from('subjects').update({'name': name, 'teacher_id': teacherId}).eq('id', id);
    } catch (e) {
      throw Exception('Ошибка при обновлении предмета: $e');
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _client.from('subjects').delete().eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw Exception('Нельзя удалить предмет: он используется в расписании или оценках');
      }
      throw Exception('Ошибка при удалении: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
