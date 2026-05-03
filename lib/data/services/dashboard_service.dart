import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _client;
  DashboardService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<AppResult<int>> getStudentCount(String institutionId) async {
    try {
      final response = await _client
          .from('students')
          .select('id, groups!inner(institution_id)')
          .eq('groups.institution_id', institutionId);
      return AppResult.success((response as List).length);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении количества студентов: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить количество студентов.');
    }
  }

  Future<AppResult<int>> getTeacherCount(String institutionId) async {
    try {
      final response = await _client.from('teachers').select('id').eq('institution_id', institutionId);
      return AppResult.success((response as List).length);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении количества преподавателей: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить количество преподавателей.');
    }
  }

  Future<AppResult<int>> getGroupCount(String institutionId) async {
    try {
      final response = await _client.from('groups').select('id').eq('institution_id', institutionId);
      return AppResult.success((response as List).length);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении количества групп: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить количество групп.');
    }
  }

  Future<AppResult<int>> getSubjectCount(String institutionId) async {
    try {
      final response = await _client.from('subjects').select('id').eq('institution_id', institutionId);
      return AppResult.success((response as List).length);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при получении количества предметов: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить количество предметов.');
    }
  }
}
