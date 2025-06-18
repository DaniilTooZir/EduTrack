import 'package:supabase_flutter/supabase_flutter.dart';

class InstitutionRequestStatusService {
  static Future<Map<String, dynamic>?> getRequestDetailsByEmail(String email) async {
    final request = await Supabase.instance.client
        .from('institution_requests')
        .select('status')
        .eq('email', email)
        .maybeSingle();

    if (request == null) {
      return null;
    }

    final status = request['status'] as String;
    if (status != 'approved') {
      return {'status': status};
    }

    final head = await Supabase.instance.client
        .from('education_heads')
        .select('email, password')
        .eq('email', email)
        .maybeSingle();

    if (head == null) {
      return {'status': status};
    }

    return {
      'status': status,
      'login': head['email'],
      'password': head['password'],
    };
  }
}