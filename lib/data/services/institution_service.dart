import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_track/models/institution.dart';

class InstitutionService {
  final _client = Supabase.instance.client;
  Future<Institution?> getInstitutionById(String id) async {
    try {
      final data = await _client.from('institutions').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Institution.fromMap(data);
    } catch (e) {
      print('[InstitutionService] Ошибка при получении учреждения: $e');
      return null;
    }
  }
}
