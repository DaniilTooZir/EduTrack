import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeworkService {
  final SupabaseClient _client;
  HomeworkService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<List<Homework>> getHomeworkByTeacherId(String teacherId) async {
    try {
      final subjectService = SubjectService(client: _client);
      final subjects = await subjectService.getSubjectsByTeacherId(teacherId);
      if (subjects.isEmpty) {
        return [];
      }
      final subjectIds = subjects.map((s) => s.id).toList();
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*), group:groups(*)')
          .filter('subject_id', 'in', '(${subjectIds.join(',')})')
          .order('due_date', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Homework.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Ошибка при загрузке ДЗ учителя: $e');
      throw Exception('Не удалось загрузить задания');
    }
  }

  Future<List<Homework>> getHomeworksByStudentGroup(String studentId) async {
    try {
      final student = await _client.from('students').select('group_id').eq('id', studentId).maybeSingle();
      if (student == null || student['group_id'] == null) {
        throw Exception('Группа студента не найдена');
      }
      final groupId = student['group_id'] as String;
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*), group:groups(*)')
          .eq('group_id', groupId)
          .order('due_date', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Homework.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки домашних заданий по группе: $e');
    }
  }

  Future<Map<String, dynamic>?> getGroupByStudentId(String studentId) async {
    try {
      final response = await _client.from('students').select('groups(id, name)').eq('id', studentId).single();
      return response['groups'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Ошибка получения группы студента: $e');
    }
  }

  Future<void> addHomework({
    required String institutionId,
    required String subjectId,
    required String groupId,
    required String title,
    String? description,
    DateTime? dueDate,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      await _client.from('homework').insert({
        'subject_id': subjectId,
        'group_id': groupId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'file_url': fileUrl,
        'file_name': fileName,
      });
    } catch (e) {
      throw Exception('Ошибка при создании ДЗ: $e');
    }
  }

  Future<void> updateHomework({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? groupId,
    String? fileUrl,
    String? fileName,
    bool deleteFile = false,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (groupId != null) updateData['group_id'] = groupId;
      if (deleteFile) {
        updateData['file_url'] = null;
        updateData['file_name'] = null;
      } else {
        if (fileUrl != null) updateData['file_url'] = fileUrl;
        if (fileName != null) updateData['file_name'] = fileName;
      }
      await _client.from('homework').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Ошибка при обновлении домашнего задания: $e');
    }
  }

  Future<void> deleteHomework(String id) async {
    try {
      await _client.from('homework_status').delete().eq('homework_id', id);
      await _client.from('homework').delete().eq('id', id);
    } catch (e) {
      throw Exception('Ошибка при удалении: $e');
    }
  }

  Future<List<Homework>> getHomeworksForStudent(String studentId) async {
    try {
      final response = await _client
          .from('homework_status')
          .select('homework_id, homework(*, subject:subjects(*), group:groups(*))')
          .eq('student_id', studentId);
      final List data = response as List;
      return data.map((item) => Homework.fromMap(item['homework'])).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке домашних заданий: $e');
    }
  }

  Future<List<HomeworkStatus>> getHomeworkStatusesForStudent(String studentId) async {
    try {
      final response = await _client.from('homework_status').select().eq('student_id', studentId);
      final List data = response as List;
      return data.map((e) => HomeworkStatus.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке статусов: $e');
    }
  }

  Future<void> setHomeworkCompletion({
    required String homeworkId,
    required String studentId,
    required bool isCompleted,
  }) async {
    try {
      final existing =
          await _client
              .from('homework_status')
              .select('id')
              .eq('homework_id', homeworkId)
              .eq('student_id', studentId)
              .maybeSingle();
      if (existing != null) {
        await _client
            .from('homework_status')
            .update({'is_completed': isCompleted, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', existing['id']);
      } else {
        await _client.from('homework_status').insert({
          'homework_id': homeworkId,
          'student_id': studentId,
          'is_completed': isCompleted,
        });
      }
    } catch (e) {
      throw Exception('Ошибка при обновлении статуса: $e');
    }
  }

  Future<List<HomeworkStatus>> getStatusesByHomeworkId(String homeworkId) async {
    try {
      final response = await _client.from('homework_status').select().eq('homework_id', homeworkId);
      final List data = response as List;
      return data.map((e) => HomeworkStatus.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки статусов ДЗ: $e');
    }
  }
}
