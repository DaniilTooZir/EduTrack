import 'package:edu_track/models/group.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BulkGroupResult {
  final List<Map<String, String>> createdGroups;
  final List<String> skippedReasons;

  const BulkGroupResult({required this.createdGroups, required this.skippedReasons});

  int get imported => createdGroups.length;
  int get skipped => skippedReasons.length;
}

class GroupService {
  final _client = Supabase.instance.client;

  Future<AppResult<List<Group>>> getGroups(String institutionId) async {
    try {
      final response = await _client
          .from('groups')
          .select('*, teacher:teachers(*)')
          .eq('institution_id', institutionId)
          .order('name', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return AppResult.success(data.map((e) => Group.fromMap(e as Map<String, dynamic>)).toList());
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при загрузке списка групп: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить список групп.');
    }
  }

  Future<AppResult<String>> addGroup(Group group) async {
    try {
      final response = await _client.from('groups').insert(group.toMap()).select('id').single();
      return AppResult.success(response['id'] as String);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Группа с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при создании группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось создать группу.');
    }
  }

  Future<AppResult<BulkGroupResult>> bulkAddGroups({
    required List<Map<String, dynamic>> groups,
    required String institutionId,
  }) async {
    if (groups.isEmpty) {
      return AppResult.success(const BulkGroupResult(createdGroups: [], skippedReasons: []));
    }
    try {
      final existing = await _client.from('groups').select('name').eq('institution_id', institutionId);
      final existingNames = (existing as List).map((e) => (e['name'] as String).toLowerCase()).toSet();

      final toInsert = <Map<String, dynamic>>[];
      final skippedReasons = <String>[];
      final seenInFile = <String>{};

      for (final g in groups) {
        final key = (g['name'] as String).toLowerCase();
        if (existingNames.contains(key)) {
          skippedReasons.add('"${g['name']}" уже существует');
        } else if (seenInFile.contains(key)) {
          skippedReasons.add('"${g['name']}" дубль в файле');
        } else {
          toInsert.add({...g, 'institution_id': institutionId});
          seenInFile.add(key);
        }
      }
      final createdGroups = <Map<String, String>>[];
      if (toInsert.isNotEmpty) {
        final response = await _client.from('groups').insert(toInsert).select('id, name');
        for (final row in response as List) {
          createdGroups.add({'id': row['id'].toString(), 'name': row['name'].toString()});
        }
      }
      return AppResult.success(BulkGroupResult(createdGroups: createdGroups, skippedReasons: skippedReasons));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка базы данных: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось выполнить импорт групп.');
    }
  }

  Future<AppResult<void>> updateGroup(String id, String newName, String? curatorId) async {
    try {
      await _client.from('groups').update({'name': newName, 'curator_id': curatorId}).eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Группа с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка при обновлении группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось обновить группу.');
    }
  }

  Future<AppResult<Group?>> getGroupByCurator(String teacherId) async {
    try {
      final response = await _client.from('groups').select().eq('curator_id', teacherId).maybeSingle();
      if (response == null) return AppResult.success(null);
      return AppResult.success(Group.fromMap(response));
    } on PostgrestException catch (e) {
      return AppResult.failure('Ошибка при поиске группы куратора: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось получить группу куратора.');
    }
  }

  Future<AppResult<void>> deleteGroup(String id) async {
    try {
      await _client.from('groups').delete().eq('id', id);
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        return AppResult.failure('Нельзя удалить группу: в ней есть студенты или связанные данные.');
      }
      return AppResult.failure('Ошибка при удалении группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось удалить группу.');
    }
  }
}
