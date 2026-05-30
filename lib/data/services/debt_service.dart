import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/student_debt_info.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebtService {
  final SupabaseClient _client;
  DebtService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<({String id, String name})>>> getTeacherGroups(String teacherId) async {
    try {
      final response = await _client
          .from('schedule')
          .select('group_id, group:groups(id, name)')
          .eq('teacher_id', teacherId);
      final seen = <String>{};
      final groups = <({String id, String name})>[];
      for (final item in response as List) {
        final groupId = item['group_id']?.toString() ?? '';
        if (groupId.isEmpty || !seen.add(groupId)) continue;
        final g = item['group'] as Map<String, dynamic>?;
        groups.add((id: groupId, name: g?['name']?.toString() ?? groupId));
      }
      groups.sort((a, b) => a.name.compareTo(b.name));
      return AppResult.success(groups);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке групп: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось загрузить список групп.');
    }
  }

  Future<AppResult<List<StudentDebtInfo>>> getGroupDebts({
    required String groupId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final studentsRaw = await _client
          .from('students')
          .select()
          .eq('group_id', groupId)
          .order('surname', ascending: true);
      final students = (studentsRaw as List).map((s) => Student.fromMap(s as Map<String, dynamic>)).toList();
      if (students.isEmpty) return AppResult.success([]);
      final studentIds = students.map((s) => s.id).toList();
      final gradesRaw = await _client.from('grade').select().inFilter('student_id', studentIds);
      final allGrades = (gradesRaw as List).map((g) => Grade.fromMap(g as Map<String, dynamic>)).toList();

      final Map<String, DateTime> lessonDateMap = {};
      if ((startDate != null || endDate != null) && allGrades.isNotEmpty) {
        final lessonIds = allGrades.map((g) => g.lessonId).toSet().toList();
        final lessonsRaw = await _client.from('lessons').select('id, schedule_id').inFilter('id', lessonIds);
        final scheduleIds = (lessonsRaw as List).map((l) => l['schedule_id'].toString()).toSet().toList();
        if (scheduleIds.isNotEmpty) {
          final schedulesRaw = await _client.from('schedule').select('id, date').inFilter('id', scheduleIds);
          final schedDateMap = {for (final s in schedulesRaw as List) s['id'].toString(): s['date']?.toString()};
          for (final l in lessonsRaw) {
            final dateStr = schedDateMap[l['schedule_id'].toString()];
            if (dateStr != null) {
              final date = DateTime.tryParse(dateStr);
              if (date != null) lessonDateMap[l['id'].toString()] = date;
            }
          }
        }
      }

      final hwRaw = await _client.from('homework').select('id, title').eq('group_id', groupId);
      final hwList = (hwRaw as List).map((h) => (id: h['id'].toString(), title: h['title'].toString())).toList();

      final Map<String, Map<String, bool>> hwStatusMap = {};
      if (hwList.isNotEmpty) {
        final hwIds = hwList.map((h) => h.id).toList();
        final statusRaw = await _client
            .from('homework_status')
            .select('student_id, homework_id, is_completed')
            .inFilter('homework_id', hwIds)
            .inFilter('student_id', studentIds);
        for (final s in statusRaw as List) {
          final sid = s['student_id'].toString();
          final hwid = s['homework_id'].toString();
          hwStatusMap.putIfAbsent(sid, () => {})[hwid] = s['is_completed'] as bool? ?? false;
        }
      }
      final results =
          students.map((student) {
            var studentGrades = allGrades.where((g) => g.studentId == student.id).toList();
            if ((startDate != null || endDate != null) && lessonDateMap.isNotEmpty) {
              studentGrades =
                  studentGrades.where((g) {
                    final date = lessonDateMap[g.lessonId];
                    if (date == null) return true;
                    if (startDate != null && date.isBefore(startDate)) return false;
                    if (endDate != null && date.isAfter(endDate)) return false;
                    return true;
                  }).toList();
            }
            final avg =
                studentGrades.isEmpty
                    ? 0.0
                    : studentGrades.fold<int>(0, (acc, g) => acc + g.value) / studentGrades.length;
            final studentHwStatuses = hwStatusMap[student.id] ?? {};
            int pendingCount = 0;
            final pendingTitles = <String>[];
            for (final hw in hwList) {
              final isCompleted = studentHwStatuses[hw.id];
              if (isCompleted == null || !isCompleted) {
                pendingCount++;
                pendingTitles.add(hw.title);
              }
            }

            return StudentDebtInfo(
              student: student,
              averageGrade: avg,
              pendingHomeworkCount: pendingCount,
              pendingHomeworkTitles: pendingTitles,
            );
          }).toList();
      return AppResult.success(results);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке задолженностей: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось загрузить данные о задолженностях.');
    }
  }

  Future<AppResult<double>> getStudentOverallAverage(String studentId) async {
    try {
      final raw = await _client.from('grade').select('value').eq('student_id', studentId);
      final grades = raw as List;
      if (grades.isEmpty) return AppResult.success(0.0);
      final avg = grades.fold<int>(0, (acc, g) => acc + (g['value'] as int)) / grades.length;
      return AppResult.success(avg);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке оценок: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось загрузить оценки.');
    }
  }
}
