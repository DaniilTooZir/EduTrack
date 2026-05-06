import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/models/grade.dart';
import 'package:edu_track/models/lesson.dart';
import 'package:edu_track/models/lesson_attendance.dart';
import 'package:edu_track/models/student.dart';
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

  Future<AppResult<Map<String, dynamic>>> getJournalData({required String groupId, required String subjectId}) async {
    try {
      final step1 = await Future.wait([
        _supabase
            .from('schedule')
            .select('id, date, weekday, start_time')
            .eq('group_id', groupId)
            .eq('subject_id', subjectId),
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
