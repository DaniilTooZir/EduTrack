import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/models/homework.dart';
import 'package:edu_track/models/homework_status.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeworkService {
  final SupabaseClient _client;
  HomeworkService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Homework>>> getHomeworkByTeacherId(String teacherId) async {
    try {
      final subjectService = SubjectService(client: _client);
      final subjectsResult = await subjectService.getSubjectsByTeacherId(teacherId);
      if (subjectsResult.isFailure) {
        return AppResult.failure(subjectsResult.errorMessage);
      }
      final subjects = subjectsResult.data;
      if (subjects.isEmpty) {
        return AppResult.success([]);
      }
      final subjectIds = subjects.map((s) => s.id).toList();
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*), group:groups(*)')
          .filter('subject_id', 'in', '(${subjectIds.join(',')})')
          .order('due_date', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Homework.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке заданий преподавателя: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить домашние задания преподавателя.');
    }
  }

  Future<AppResult<List<Homework>>> getHomeworksByStudentGroup(String studentId) async {
    try {
      final student = await _client.from('students').select('group_id').eq('id', studentId).maybeSingle();
      if (student == null || student['group_id'] == null) {
        return AppResult.failure('Группа студента не найдена.');
      }
      final groupId = student['group_id'] as String;
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*), group:groups(*)')
          .eq('group_id', groupId)
          .order('due_date', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Homework.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке домашних заданий группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить домашние задания группы.');
    }
  }

  Future<AppResult<Map<String, dynamic>?>> getGroupByStudentId(String studentId) async {
    try {
      final response = await _client.from('students').select('groups(id, name)').eq('id', studentId).single();
      return AppResult.success(response['groups'] as Map<String, dynamic>?);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении группы студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось получить группу студента.');
    }
  }

  Future<AppResult<void>> addHomework({
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
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при создании домашнего задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось создать домашнее задание.');
    }
  }

  Future<AppResult<void>> updateHomework({
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
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при обновлении домашнего задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить домашнее задание.');
    }
  }

  Future<AppResult<void>> deleteHomework(String id) async {
    try {
      await _client.from('homework_status').delete().eq('homework_id', id);
      await _client.from('homework').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при удалении домашнего задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить домашнее задание.');
    }
  }

  Future<AppResult<void>> evaluateHomework({
    required String homeworkId,
    required String studentId,
    required bool isCompleted,
    String? teacherComment,
  }) async {
    try {
      final data = {
        'homework_id': homeworkId,
        'student_id': studentId,
        'is_completed': isCompleted,
        'teacher_comment': teacherComment,
        'updated_at': DateTime.now().toIso8601String(),
      };
      final existing =
          await _client
              .from('homework_status')
              .select('id')
              .eq('homework_id', homeworkId)
              .eq('student_id', studentId)
              .maybeSingle();
      if (existing != null) {
        await _client.from('homework_status').update(data).eq('id', existing['id']);
      } else {
        await _client.from('homework_status').insert(data);
      }
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при оценке задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось оценить домашнее задание.');
    }
  }

  Future<AppResult<List<Homework>>> getHomeworksForStudent(String studentId) async {
    try {
      final response = await _client
          .from('homework_status')
          .select('homework_id, homework(*, subject:subjects(*), group:groups(*))')
          .eq('student_id', studentId);
      final List data = response as List;
      return AppResult.success(data.map((item) => Homework.fromMap(item['homework'])).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке домашних заданий студента: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить домашние задания студента.');
    }
  }

  Future<AppResult<List<HomeworkStatus>>> getHomeworkStatusesForStudent(String studentId) async {
    try {
      final response = await _client.from('homework_status').select().eq('student_id', studentId);
      final List data = response as List;
      return AppResult.success(data.map((e) => HomeworkStatus.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке статусов заданий: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить статусы домашних заданий.');
    }
  }

  Future<AppResult<void>> submitHomework({
    required String homeworkId,
    required String studentId,
    String? comment,
    String? fileUrl,
    String? fileName,
  }) async {
    try {
      final existing =
          await _client
              .from('homework_status')
              .select('id')
              .eq('homework_id', homeworkId)
              .eq('student_id', studentId)
              .maybeSingle();
      final data = {
        'homework_id': homeworkId,
        'student_id': studentId,
        'is_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
        'student_comment': comment,
        'file_url': fileUrl,
        'file_name': fileName,
      };
      if (existing != null) {
        await _client.from('homework_status').update(data).eq('id', existing['id']);
      } else {
        await _client.from('homework_status').insert(data);
      }
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при отправке домашнего задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось отправить домашнее задание.');
    }
  }

  Future<AppResult<void>> cancelSubmission({required String homeworkId, required String studentId}) async {
    try {
      await _client
          .from('homework_status')
          .update({
            'is_completed': false,
            'updated_at': DateTime.now().toIso8601String(),
            'student_comment': null,
            'file_url': null,
            'file_name': null,
          })
          .eq('homework_id', homeworkId)
          .eq('student_id', studentId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при отмене сдачи задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось отменить сдачу домашнего задания.');
    }
  }

  Future<AppResult<List<HomeworkStatus>>> getStatusesByHomeworkId(String homeworkId) async {
    try {
      final response = await _client.from('homework_status').select().eq('homework_id', homeworkId);
      final List data = response as List;
      return AppResult.success(data.map((e) => HomeworkStatus.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке статусов домашнего задания: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить статусы домашнего задания.');
    }
  }
}
