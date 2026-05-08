import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
import 'package:edu_track/models/subject.dart';
import 'package:edu_track/models/subject_analytics.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradeService {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  GradeService({required AppDatabase db, SupabaseClient? client})
    : _db = db,
      _supabase = client ?? Supabase.instance.client;

  Future<AppResult<bool>> addOrUpdateGrade(Grade grade) async {
    try {
      final existing =
          await _supabase
              .from('grade')
              .select()
              .eq('lessons_id', grade.lessonId)
              .eq('student_id', grade.studentId)
              .maybeSingle();
      if (existing != null) {
        final id = existing['id'];
        await _supabase.from('grade').update({'value': grade.value}).eq('id', id);
      } else {
        await _supabase.from('grade').insert(grade.toMap());
      }
      return AppResult.success(true);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при сохранении оценки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось сохранить оценку. Попробуйте позже.');
    }
  }

  Future<AppResult<List<Grade>>> getGradesByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('grade')
          .select()
          .eq('student_id', studentId)
          .order('lessons_id', ascending: false);
      final grades = (response as List).map((map) => Grade.fromMap(map)).toList();
      await _db.saveGrades(grades);
      return AppResult.success(grades);
    } on PostgrestException catch (e) {
      final cached = await _db.getGradesByStudent(studentId);
      if (cached.isNotEmpty) return AppResult.success(cached);
      return AppResult.failure('Ошибка при получении оценок студента: ${e.message}');
    } catch (e) {
      final cached = await _db.getGradesByStudent(studentId);
      if (cached.isNotEmpty) return AppResult.success(cached);
      return AppResult.failure('Не удалось загрузить оценки студента.');
    }
  }

  Future<AppResult<List<Grade>>> getGradesByLesson(String lessonId) async {
    try {
      final response = await _supabase.from('grade').select().eq('lessons_id', lessonId);
      final grades = (response as List).map((map) => Grade.fromMap(map)).toList();
      await _db.saveGrades(grades);
      return AppResult.success(grades);
    } on PostgrestException catch (e) {
      final cached = await _db.getGradesByLesson(lessonId);
      if (cached.isNotEmpty) return AppResult.success(cached);
      return AppResult.failure('Ошибка при получении оценок урока: ${e.message}');
    } catch (e) {
      final cached = await _db.getGradesByLesson(lessonId);
      if (cached.isNotEmpty) return AppResult.success(cached);
      return AppResult.failure('Не удалось загрузить оценки урока.');
    }
  }

  Future<AppResult<Map<String, dynamic>>> getJournalData({
    required String groupId,
    required String subjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var scheduleQuery = _supabase
          .from('schedule')
          .select('id, date, weekday, start_time')
          .eq('group_id', groupId)
          .eq('subject_id', subjectId);
      if (startDate != null) scheduleQuery = scheduleQuery.gte('date', startDate.toIso8601String());
      if (endDate != null) scheduleQuery = scheduleQuery.lte('date', endDate.toIso8601String());
      final step1 = await Future.wait([
        scheduleQuery,
        _supabase.from('students').select().eq('group_id', groupId).order('surname', ascending: true),
      ]);
      final scheduleRaw = step1[0] as List;
      final scheduleIds = scheduleRaw.map((s) => s['id'].toString()).toList();
      final schedules = scheduleRaw.map((s) => s as Map<String, dynamic>).toList();
      final students = (step1[1] as List).map((s) => Student.fromMap(s as Map<String, dynamic>)).toList();
      if (scheduleIds.isEmpty) {
        return AppResult.success({
          'lessons': <Lesson>[],
          'students': students,
          'grades': <Grade>[],
          'attendances': <LessonAttendance>[],
          'schedules': <Map<String, dynamic>>[],
        });
      }
      final lessonsResponse = await _supabase
          .from('lessons')
          .select()
          .inFilter('schedule_id', scheduleIds)
          .order('id', ascending: true);
      final lessons = (lessonsResponse as List).map((l) => Lesson.fromMap(l as Map<String, dynamic>)).toList();
      if (lessons.isEmpty) {
        return AppResult.success({
          'lessons': <Lesson>[],
          'students': students,
          'grades': <Grade>[],
          'attendances': <LessonAttendance>[],
          'schedules': schedules,
        });
      }
      final lessonIds = lessons.where((l) => l.id != null).map((l) => l.id!).toList();
      final step3 = await Future.wait([
        _supabase.from('grade').select().inFilter('lessons_id', lessonIds),
        _supabase.from('lesson_attendances').select().inFilter('lesson_id', lessonIds),
      ]);
      final grades = (step3[0] as List).map((g) => Grade.fromMap(g as Map<String, dynamic>)).toList();
      final attendances = (step3[1] as List).map((a) => LessonAttendance.fromMap(a as Map<String, dynamic>)).toList();
      return AppResult.success({
        'lessons': lessons,
        'students': students,
        'grades': grades,
        'attendances': attendances,
        'schedules': schedules,
      });
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке журнала успеваемости: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить данные журнала.');
    }
  }

  Future<AppResult<List<SubjectAnalytics>>> getStudentAnalytics(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final gradesRaw = await _supabase.from('grade').select().eq('student_id', studentId);
      final grades = (gradesRaw as List).map((g) => Grade.fromMap(g as Map<String, dynamic>)).toList();
      if (grades.isEmpty) return AppResult.success([]);

      final lessonIds = grades.map((g) => g.lessonId).toSet().toList();
      final lessonsRaw = await _supabase.from('lessons').select('id, schedule_id').inFilter('id', lessonIds);
      final lessonScheduleMap = <String, String>{};
      for (final l in lessonsRaw as List) {
        lessonScheduleMap[l['id'].toString()] = l['schedule_id'].toString();
      }

      final scheduleIds = lessonScheduleMap.values.toSet().toList();
      final schedulesRaw = await _supabase
          .from('schedule')
          .select('id, subject_id, date, subject:subjects(*)')
          .inFilter('id', scheduleIds);
      final scheduleSubjectIdMap = <String, String>{};
      final scheduleIdToDate = <String, DateTime>{};
      final subjectsById = <String, Subject>{};
      for (final s in schedulesRaw as List) {
        final scheduleId = s['id'].toString();
        final subjectId = s['subject_id'].toString();
        scheduleSubjectIdMap[scheduleId] = subjectId;
        if (s['date'] != null) {
          final date = DateTime.tryParse(s['date'].toString());
          if (date != null) scheduleIdToDate[scheduleId] = date;
        }
        if (s['subject'] != null) {
          subjectsById[subjectId] = Subject.fromMap(s['subject'] as Map<String, dynamic>);
        }
      }

      final lessonSubjectMap = <String, String>{};
      final lessonDateMap = <String, DateTime>{};
      for (final entry in lessonScheduleMap.entries) {
        final subjectId = scheduleSubjectIdMap[entry.value];
        if (subjectId != null) lessonSubjectMap[entry.key] = subjectId;
        final date = scheduleIdToDate[entry.value];
        if (date != null) lessonDateMap[entry.key] = date;
      }

      final filteredGrades =
          (startDate == null && endDate == null)
              ? grades
              : grades.where((g) {
                final date = lessonDateMap[g.lessonId];
                if (date == null) return true;
                if (startDate != null && date.isBefore(startDate)) return false;
                if (endDate != null && date.isAfter(endDate)) return false;
                return true;
              }).toList();
      final analytics =
          subjectsById.values
              .map(
                (subject) => SubjectAnalytics.fromGrades(
                  subject,
                  filteredGrades,
                  lessonSubjectMap,
                  lessonDateMap: lessonDateMap,
                ),
              )
              .toList()
            ..sort((a, b) => a.subject.name.compareTo(b.subject.name));
      return AppResult.success(analytics);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке аналитики: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить аналитику студента.');
    }
  }

  Future<AppResult<void>> clearJournalCell({required String studentId, required String lessonId}) async {
    try {
      await Future.wait([
        _supabase.from('grade').delete().eq('student_id', studentId).eq('lessons_id', lessonId),
        _supabase.from('lesson_attendances').delete().eq('student_id', studentId).eq('lesson_id', lessonId),
      ]);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при очистке ячейки: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось очистить данные.');
    }
  }
}
