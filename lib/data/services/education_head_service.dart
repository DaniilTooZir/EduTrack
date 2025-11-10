import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/education_head.dart';

class EducationHeadService {
  final _client = Supabase.instance.client;
  Future<EducationHead?> getHeadById(String id) async {
    final data = await _client.from('education_heads').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return EducationHead.fromMap(data);
  }

  Future<void> updateHeadData(String id, Map<String, dynamic> updatedFields) async {
    await _client.from('education_heads').update(updatedFields).eq('id', id);
  }
}
