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
      if (response == null) {
        throw Exception('Пустой ответ при получении предметов');
      }
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Subject.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке предметов: $e');
    }
  }

  Future<void> addSubject({required String name, required String institutionId, required String teacherId}) async {
    try {
      final response =
          await _client
              .from('subjects')
              .insert({'name': name, 'institution_id': institutionId, 'teacher_id': teacherId})
              .select()
              .single();
      if (response == null) {
        throw Exception('Пустой ответ при добавлении предмета');
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении предмета: $e');
    }
  }
}
