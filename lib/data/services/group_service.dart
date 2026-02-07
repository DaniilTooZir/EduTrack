import 'package:edu_track/models/group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final _client = Supabase.instance.client;
  Future<List<Group>> getGroups(String institutionId) async {
    try {
      final response = await _client
          .from('groups')
          .select('*, teacher:teachers(*)')
          .eq('institution_id', institutionId)
          .order('name', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Group.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Ошибка загрузки групп: $e');
      throw Exception('Не удалось загрузить список групп');
    }
  }

  Future<void> addGroup(Group group) async {
    try {
      await _client.from('groups').insert(group.toMap());
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Группа с таким названием уже существует');
      }
      print('Ошибка БД при создании группы: ${e.message}');
      throw Exception('Ошибка базы данных: ${e.message}');
    } catch (e) {
      print('Неизвестная ошибка при создании группы: $e');
      rethrow;
    }
  }

  Future<void> updateGroup(String id, String newName, String? curatorId) async {
    try {
      await _client.from('groups').update({'name': newName, 'curator_id': curatorId}).eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Группа с таким названием уже существует');
      }
      throw Exception('Ошибка при обновлении: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Group?> getGroupByCurator(String teacherId) async {
    try {
      final response = await _client.from('groups').select().eq('curator_id', teacherId).maybeSingle();

      if (response == null) return null;
      return Group.fromMap(response);
    } catch (e) {
      print('Ошибка при поиске группы куратора: $e');
      return null;
    }
  }

  Future<void> deleteGroup(String id) async {
    try {
      await _client.from('groups').delete().eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw Exception('Нельзя удалить группу: в ней есть студенты или данные');
      }
      throw Exception('Ошибка при удалении: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
