import 'package:edu_track/models/group.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<AppResult<void>> addGroup(Group group) async {
    try {
      await _client.from('groups').insert(group.toMap());
      return AppResult.success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return AppResult.failure('Группа с таким названием уже существует.');
      }
      return AppResult.failure('Ошибка базы данных при создании группы: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось создать группу.');
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
