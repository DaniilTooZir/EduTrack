import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/academic_period.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicPeriodService {
  final SupabaseClient _client;
  AcademicPeriodService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<AcademicPeriod>>> getPeriods(String institutionId) async {
    try {
      final response = await _client
          .from('academic_periods')
          .select()
          .eq('institution_id', institutionId)
          .order('start_date');
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => AcademicPeriod.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке учебных периодов: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить учебные периоды.');
    }
  }

  Future<AppResult<void>> addPeriod(AcademicPeriod period) async {
    if (!period.startDate.isBefore(period.endDate)) {
      return AppResult.failure('Дата начала не может быть позже даты окончания');
    }
    try {
      final map = period.toMap()..remove('id');
      await _client.from('academic_periods').insert(map);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Период с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка при создании периода: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось создать учебный период.');
    }
  }

  Future<AppResult<void>> updatePeriod(AcademicPeriod period) async {
    if (!period.startDate.isBefore(period.endDate)) {
      return AppResult.failure('Дата начала не может быть позже даты окончания');
    }
    try {
      await _client
          .from('academic_periods')
          .update({
            'name': period.name,
            'start_date': period.startDate.toIso8601String(),
            'end_date': period.endDate.toIso8601String(),
          })
          .eq('id', period.id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Период с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка при обновлении периода: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить учебный период.');
    }
  }

  Future<AppResult<void>> deletePeriod(String id) async {
    try {
      await _client.from('academic_periods').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить период: он используется в других записях.');
      }
      return AppResult.failure('Ошибка при удалении периода: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить учебный период.');
    }
  }
}
