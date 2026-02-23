import 'package:edu_track/data/database/connection_to_database.dart';

class AuthResult {
  final String role;
  final String userId;
  final String institutionId;
  final String? groupId;

  AuthResult({required this.role, required this.userId, required this.institutionId, this.groupId});
}

class AuthService {
  static Future<AuthResult?> login(String login, String password) async {
    var result = await _checkUser(table: 'education_heads', role: 'admin', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'teachers', role: 'teacher', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'students', role: 'student', login: login, password: password);
    if (result != null) return result;

    result = await _checkUser(table: 'schedule_operators', role: 'schedule_operator', login: login, password: password);
    if (result != null) return result;
    return null;
  }

  static Future<AuthResult?> _checkUser({
    required String table,
    required String role,
    required String login,
    required String password,
  }) async {
    final client = SupabaseConnection.client;
    try {
      Map<String, dynamic>? data;
      if (role == 'student') {
        final response =
            await client
                .from(table)
                .select('id, password, group_id, groups(institution_id)')
                .eq('login', login)
                .maybeSingle();
        data = response;
      } else {
        final response =
            await client.from(table).select('id, password, institution_id').eq('login', login).maybeSingle();
        data = response;
      }
      if (data != null && data['password'] == password) {
        String institutionId;
        String? groupId;
        if (role == 'student') {
          final groupData = data['groups'] as Map<String, dynamic>?;
          if (groupData != null && groupData['institution_id'] != null) {
            institutionId = groupData['institution_id'].toString();
          } else {
            throw Exception('Студент не привязан к группе или учреждению');
          }
          groupId = data['group_id']?.toString();
        } else {
          institutionId = data['institution_id'].toString();
        }
        return AuthResult(role: role, userId: data['id'].toString(), institutionId: institutionId, groupId: groupId);
      }
    } catch (e) {
      print('Инфо: Пользователь не найден в $table ($e)');
    }
    return null;
  }
}
