import 'package:edu_track/data/database/connection_to_database.dart';

class AuthResult {
  final String role;
  final String userId;
  final String institutionId;
  final String? groupId;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? institutionName;
  final String? groupName;
  AuthResult({
    required this.role,
    required this.userId,
    required this.institutionId,
    this.groupId,
    this.name,
    this.email,
    this.avatarUrl,
    this.institutionName,
    this.groupName,
  });
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
                .select('*, groups(name, institution_id, institutions(name))')
                .eq('login', login)
                .maybeSingle();
        data = response;
      } else {
        final response = await client.from(table).select('*, institutions(name)').eq('login', login).maybeSingle();
        data = response;
      }
      if (data != null && data['password'] == password) {
        String instId;
        String? instName;
        String? gName;
        if (role == 'student') {
          final groupData = data['groups'] as Map<String, dynamic>?;
          instId = groupData?['institution_id']?.toString() ?? '';
          instName = groupData?['institutions']?['name'];
          gName = groupData?['name'];
        } else {
          instId = data['institution_id'].toString();
          instName = data['institutions']?['name'];
        }
        return AuthResult(
          role: role,
          userId: data['id'].toString(),
          institutionId: instId,
          groupId: data['group_id']?.toString(),
          name: '${data['surname'] ?? ''} ${data['name'] ?? ''}'.trim(),
          email: data['email'],
          avatarUrl: data['avatar_url'],
          institutionName: instName,
          groupName: gName,
        );
      }
    } catch (e) {
      print('Ошибка авторизации: $e');
    }
    return null;
  }
}
