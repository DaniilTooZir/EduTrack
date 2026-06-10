import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/models/room.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:edu_track/utils/bulk_import_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomService {
  final SupabaseClient _client;
  RoomService({SupabaseClient? client}) : _client = client ?? SupabaseConnection.client;

  Future<AppResult<List<Room>>> getRoomsForInstitution(String institutionId) async {
    try {
      final response = await _client.from('rooms').select().eq('institution_id', institutionId).order('name');
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Room.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке аудиторий: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список аудиторий.');
    }
  }

  Future<AppResult<void>> addRoom({required String name, required String institutionId}) async {
    try {
      await _client.from('rooms').insert({'name': name, 'institution_id': institutionId});
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Аудитория с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при добавлении аудитории: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось добавить аудиторию.');
    }
  }

  Future<AppResult<void>> updateRoom({required String id, required String name}) async {
    try {
      await _client.from('rooms').update({'name': name}).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Аудитория с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка при обновлении аудитории: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить аудиторию.');
    }
  }

  Future<AppResult<BulkImportResult>> bulkAddRooms({required List<String> names, required String institutionId}) async {
    if (names.isEmpty) return AppResult.success(const BulkImportResult(imported: 0, skippedReasons: []));
    try {
      final existing = await _client.from('rooms').select('name').eq('institution_id', institutionId);
      final existingNames = (existing as List).map((e) => (e['name'] as String).toLowerCase()).toSet();

      final toInsert = <String>[];
      final skippedReasons = <String>[];
      final seenInFile = <String>{};

      for (final name in names) {
        final key = name.toLowerCase();
        if (existingNames.contains(key)) {
          skippedReasons.add('"$name" уже существует');
        } else if (seenInFile.contains(key)) {
          skippedReasons.add('"$name" дубль в файле');
        } else {
          toInsert.add(name);
          seenInFile.add(key);
        }
      }
      if (toInsert.isNotEmpty) {
        await _client.from('rooms').insert(toInsert.map((n) => {'name': n, 'institution_id': institutionId}).toList());
      }
      return AppResult.success(BulkImportResult(imported: toInsert.length, skippedReasons: skippedReasons));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка базы данных: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось выполнить импорт аудиторий.');
    }
  }

  Future<AppResult<void>> deleteRoom(String id) async {
    try {
      await _client.from('rooms').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить аудиторию: она используется в расписании.');
      }
      return AppResult.failure('Ошибка при удалении аудитории: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить аудиторию.');
    }
  }
}
