import 'package:flutter/foundation.dart';
import 'package:edu_track/data/services/session_service.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _role;

  String? get userId => _userId;
  String? get role => _role;

  void setUser(String userId, String role) {
    _userId = userId;
    _role = role;
    SessionService.saveSession(userId, role);
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _role = null;
    SessionService.clearSession();
    notifyListeners();
  }

  void loadSession(String? userId, String? role) {
    if (userId != null && role != null) {
      _userId = userId;
      _role = role;
      notifyListeners();
    }
  }
}