import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/time_grid.dart';
import 'package:edu_track/models/time_slot.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimeGridService {
  final SupabaseClient _client;

  TimeGridService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<TimeGrid>>> getGridsForInstitution(String institutionId) async {
    try {
      final data = await _client
          .from('time_grids')
          .select('*, time_slots(*)')
          .eq('institution_id', institutionId)
          .order('created_at');
      return AppResult.success((data as List).map((e) => TimeGrid.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка загрузки сеток времени: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось загрузить сетки времени.');
    }
  }

  Future<AppResult<TimeGrid>> createGrid(String institutionId, String name) async {
    try {
      final row =
          await _client.from('time_grids').insert({'institution_id': institutionId, 'name': name}).select().single();
      return AppResult.success(TimeGrid.fromMap({...row, 'time_slots': []}));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка создания сетки: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось создать сетку.');
    }
  }

  Future<AppResult<void>> updateGridName(String gridId, String name) async {
    try {
      await _client.from('time_grids').update({'name': name}).eq('id', gridId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка обновления сетки: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось обновить сетку.');
    }
  }

  Future<AppResult<void>> deleteGrid(String gridId) async {
    try {
      await _client.from('time_grids').delete().eq('id', gridId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить сетку: сначала удалите все её слоты.');
      }
      return AppResult.failure('Ошибка удаления сетки: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось удалить сетку.');
    }
  }

  Future<AppResult<TimeSlot>> addSlot(
    String gridId, {
    String? label,
    required String startTime,
    required String endTime,
    required int sortOrder,
  }) async {
    try {
      final row =
          await _client
              .from('time_slots')
              .insert({
                'grid_id': gridId,
                if (label != null) 'label': label,
                'start_time': startTime,
                'end_time': endTime,
                'sort_order': sortOrder,
              })
              .select()
              .single();
      return AppResult.success(TimeSlot.fromMap(row));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка добавления слота: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось добавить слот.');
    }
  }

  Future<AppResult<void>> updateSlot(
    String slotId, {
    String? label,
    required String startTime,
    required String endTime,
    required int sortOrder,
  }) async {
    try {
      await _client
          .from('time_slots')
          .update({'label': label, 'start_time': startTime, 'end_time': endTime, 'sort_order': sortOrder})
          .eq('id', slotId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка обновления слота: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось обновить слот.');
    }
  }

  Future<AppResult<void>> deleteSlot(String slotId) async {
    try {
      await _client.from('time_slots').delete().eq('id', slotId);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка удаления слота: ${e.message}');
    } catch (_) {
      return AppResult.failure('Не удалось удалить слот.');
    }
  }
}
