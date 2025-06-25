import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/group.dart';

class GroupService {
  final _client = Supabase.instance.client;
  Future<List<Group>> getGroups(String institutionId) async {
    try {
      final response = await _client
          .from('groups')
          .select()
          .eq('institution_id', institutionId);
      if (response == null) return [];
      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => Group.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки групп: $e');
    }
  }

  Future<void> addGroup(Group group) async {
    await _client.from('groups').insert(group.toMap());
  }
}
