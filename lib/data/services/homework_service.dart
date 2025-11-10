import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';

class HomeworkService {
  final SupabaseClient _client;

  HomeworkService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  Future<List<Homework>> getHomeworkByTeacherId(String teacherId) async {
    try {
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*), group:groups(*)')
          .eq('subject.teacher_id', teacherId)
          .order('due_date', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Homework.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки домашних заданий: $e');
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
      if (response == null) return null;
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
  }) async {
    try {
      final Map<String, dynamic> insertData = {
        'institution_id': institutionId,
        'subject_id': subjectId,
        'group_id': groupId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
      };
      final response = await _client.from('homework').insert(insertData).select().single();

      if (response == null) {
        throw Exception('Ошибка при добавлении домашнего задания');
      }
    } catch (e) {
      throw Exception('Ошибка при добавлении домашнего задания: $e');
    }
  }

  Future<void> updateHomework({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? groupId,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (groupId != null) updateData['group_id'] = groupId;
      await _client.from('homework').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Ошибка при обновлении домашнего задания: $e');
    }
  }

  Future<void> deleteHomework(String id) async {
    try {
      await _client.from('homework').delete().eq('id', id);
    } catch (e) {
      throw Exception('Ошибка при удалении домашнего задания: $e');
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
}
