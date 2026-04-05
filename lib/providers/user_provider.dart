import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/realtime_listener.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _role;
  String? _institutionId;
  String? _groupId;

  String? _userName;
  String? _userEmail;
  String? _avatarUrl;
  String? _institutionName;
  String? _groupName;

  bool _isInitialized = false;

  final _realtimeListener = RealtimeListener();

  String? get userId => _userId;

  String? get role => _role;

  String? get institutionId => _institutionId;

  String? get groupId => _groupId;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get avatarUrl => _avatarUrl;

  String? get institutionName => _institutionName;

  String? get groupName => _groupName;

  bool get isInitialized => _isInitialized;

  // Сохраняет данные пользователя и уведомляет слушателей
  void setUser({
    required String userId,
    required String role,
    required String institutionId,
    String? groupId,
    String? name,
    String? email,
    String? avatar,
    String? instName,
    String? groupName,
  }) {
    _userId = userId;
    _role = role;
    _institutionId = institutionId;
    _groupId = groupId;
    _userName = name;
    _userEmail = email;
    _avatarUrl = avatar;
    _institutionName = instName;
    _groupName = groupName;
    SessionService.saveSession(userId, role, institutionId, groupId);
    _setupRealtime();
    notifyListeners();
  }

  // Загружает данные пользователя из сессии
  Future<void> loadSession() async {
    try {
      _userId = await SessionService.getUserId();
      _role = await SessionService.getRole();
      _institutionId = await SessionService.getInstitutionId();
      _groupId = await SessionService.getGroupId();
      if (_userId != null && _role != null) {
        await _fetchFullProfile();
        _setupRealtime();
      }
    } catch (e) {
      debugPrint('Ошибка инициализации: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Внутренний метод для получения данных профиля
  Future<void> _fetchFullProfile() async {
    if (_userId == null || _role == null) return;
    final client = SupabaseConnection.client;
    String table = '';
    switch (_role) {
      case 'admin':
        table = 'education_heads';
        break;
      case 'teacher':
        table = 'teachers';
        break;
      case 'student':
        table = 'students';
        break;
      case 'schedule_operator':
        table = 'schedule_operators';
        break;
    }
    try {
      final data =
          await client
              .from(table)
              .select('*, institutions(name)${_role == 'student' ? ', groups(name)' : ''}')
              .eq('id', _userId!)
              .maybeSingle();
      if (data != null) {
        _userName = '${data['surname'] ?? ''} ${data['name'] ?? ''}'.trim();
        _userEmail = data['email'];
        _avatarUrl = data['avatar_url'];
        _institutionName = data['institutions']?['name'];
        if (_role == 'student') {
          _groupName = data['groups']?['name'];
        }
      }
    } catch (e) {
      debugPrint('Ошибка fetchFullProfile: $e');
    }
  }

  void _setupRealtime() {
    _realtimeListener.stopListening();
    if (_role == 'student' && _groupId != null && _userId != null) {
      _realtimeListener.startListening(_userId!, _groupId!);
    }
  }

  // Очищает данные пользователя и уведомляет слушателей
  void clearUser() {
    _realtimeListener.stopListening();
    _userId = null;
    _role = null;
    _institutionId = null;
    _groupId = null;
    _userName = null;
    _userEmail = null;
    _avatarUrl = null;
    _institutionName = null;
    _groupName = null;
    SessionService.clearSession();
    notifyListeners();
  }
}
