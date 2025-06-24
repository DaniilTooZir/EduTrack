import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/group.dart';

class GroupService {
  final _client = Supabase.instance.client;
  Future<List<Group>> getGroups(String institutionId) async {
    final response = await _client
        .from('groups')
        .select()
        .eq('institution_id', institutionId);
    return (response as List)
        .map((map) => Group.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGroup(Group group) async {
    await _client.from('groups').insert(group.toMap());
  }
}
