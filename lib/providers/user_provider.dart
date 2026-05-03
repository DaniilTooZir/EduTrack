import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/auth_service.dart';
import 'package:edu_track/data/services/realtime_listener.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  final AppDatabase _appDatabase;

  UserProvider({required AppDatabase appDatabase}) : _appDatabase = appDatabase;

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

  Future<void> setUser(AuthResult auth) async {
    _userId = auth.userId;
    _role = auth.role;
    _institutionId = auth.institutionId;
    _groupId = auth.groupId;
    _userName = auth.name;
    _userEmail = auth.email;
    _avatarUrl = auth.avatarUrl;
    _institutionName = auth.institutionName;
    _groupName = auth.groupName;
    await SessionService.saveSession(auth.userId, auth.role, auth.institutionId, auth.groupId);
    await _appDatabase.saveUserProfile(auth);
    _setupRealtime();
    notifyListeners();
  }

  Future<void> loadSession() async {
    try {
      _userId = await SessionService.getUserId();
      _role = await SessionService.getRole();
      _institutionId = await SessionService.getInstitutionId();
      _groupId = await SessionService.getGroupId();
      if (_userId != null && _role != null) {
        final onlineSuccess = await _fetchFullProfile();
        if (!onlineSuccess) {
          await _loadCachedProfile();
        }
        _setupRealtime();
      }
    } catch (e) {
      debugPrint('Ошибка инициализации: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> _fetchFullProfile() async {
    if (_userId == null || _role == null) return false;
    final client = SupabaseConnection.client;
    final String table = switch (_role) {
      'admin' => 'education_heads',
      'teacher' => 'teachers',
      'student' => 'students',
      'schedule_operator' => 'schedule_operators',
      _ => '',
    };
    if (table.isEmpty) return false;
    try {
      final selectString = _role == 'student' ? '*, groups(name, institutions(name))' : '*, institutions(name)';
      final data = await client.from(table).select(selectString).eq('id', _userId!).maybeSingle();
      if (data == null) return false;
      _userName = '${data['surname'] ?? ''} ${data['name'] ?? ''}'.trim();
      _userEmail = data['email']?.toString();
      _avatarUrl = data['avatar_url']?.toString();
      if (_role == 'student') {
        final groupData = data['groups'] as Map<String, dynamic>?;
        _groupName = groupData?['name']?.toString();
        _institutionName = groupData?['institutions']?['name']?.toString();
      } else {
        _institutionName = data['institutions']?['name']?.toString();
      }
      return true;
    } catch (e) {
      debugPrint('Ошибка fetchFullProfile: $e');
      return false;
    }
  }

  Future<void> _loadCachedProfile() async {
    final cached = await _appDatabase.getUserProfile();
    if (cached == null) return;
    _userId = cached.userId;
    _role = cached.role;
    _institutionId = cached.institutionId;
    _groupId = cached.groupId;
    _userName = cached.name;
    _userEmail = cached.email;
    _avatarUrl = cached.avatarUrl;
    _institutionName = cached.institutionName;
    _groupName = cached.groupName;
    debugPrint('Профиль загружен из локального кэша (офлайн-режим)');
  }

  void _setupRealtime() {
    _realtimeListener.stopListening();
    if (_userId != null && _role == 'student' && _groupId != null) {
      _realtimeListener.startListening(_userId!, _groupId!);
    }
  }

  Future<void> clearUser() async {
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
    await Future.wait([SessionService.clearSession(), _appDatabase.clearAll()]);
    notifyListeners();
  }
}
