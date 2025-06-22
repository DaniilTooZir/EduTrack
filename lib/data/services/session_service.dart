import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveSession(String userId, String role, String institutionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('institutionId', institutionId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getInstitutionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('institutionId');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('institutionId');
  }
}