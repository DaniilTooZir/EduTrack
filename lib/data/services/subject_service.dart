import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectService {
  final SupabaseClient _client;
  SubjectService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Subject>>> getSubjectsByTeacherId(String teacherId) async {
    try {
      final response = await _client.from('schedule').select('subject:subjects(*)').eq('teacher_id', teacherId);
      final List<dynamic> data = response as List<dynamic>;
      final uniqueSubjects = <String, Subject>{};
      for (final item in data) {
        if (item['subject'] != null) {
          final subject = Subject.fromMap(item['subject']);
          uniqueSubjects[subject.id] = subject;
        }
      }
      return AppResult.success(uniqueSubjects.values.toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке предметов преподавателя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить предметы преподавателя.');
    }
  }

  Future<AppResult<List<Subject>>> getSubjectsForInstitution(String institutionId) async {
    try {
      final response = await _client.from('subjects').select().eq('institution_id', institutionId).order('created_at');
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Subject.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке предметов учреждения: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список предметов.');
    }
  }

  Future<AppResult<void>> addSubject({required String name, required String institutionId}) async {
    try {
      await _client.from('subjects').insert({'name': name, 'institution_id': institutionId});
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Предмет с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при добавлении предмета: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось добавить предмет.');
    }
  }

  Future<AppResult<void>> updateSubject({required String id, required String name}) async {
    try {
      await _client.from('subjects').update({'name': name}).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при обновлении предмета: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить предмет.');
    }
  }

  Future<AppResult<void>> deleteSubject(String id) async {
    try {
      await _client.from('subjects').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить предмет: он используется в расписании или оценках.');
      }
      return AppResult.failure('Ошибка при удалении предмета: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить предмет.');
    }
  }
}
