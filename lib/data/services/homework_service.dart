import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/homework.dart';

class HomeworkService {
  final SupabaseClient _client;

  HomeworkService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  Future<List<Homework>> getHomeworkByTeacherId(String teacherId) async {
    try {
      final response = await _client
          .from('homework')
          .select('*, subject:subjects(*)')
          .eq('subject.teacher_id', teacherId)
          .order('due_date', ascending: true);
      if (response == null) {
        return [];
      }
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((e) => Homework.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки домашних заданий: $e');
    }
  }

  Future<void> addHomework({
    required String institutionId,
    required String subjectId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    try {
      final Map<String, dynamic> insertData = {
        'institution_id': institutionId,
        'subject_id': subjectId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
      };
      final response =
          await _client.from('homework').insert(insertData).select().single();
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
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
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
}
