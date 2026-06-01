import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/auth_service.dart';

class UserRepository {
  final AppDatabase _local;

  UserRepository({required AppDatabase local}) : _local = local;

  Future<void> saveProfile(AuthResult auth) => _local.saveUserProfile(auth);

  Future<AuthResult?> getCachedProfile() => _local.getUserProfile();

  Future<void> clearAll() => _local.clearAll();
}
