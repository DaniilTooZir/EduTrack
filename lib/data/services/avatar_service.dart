import 'dart:io';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  final _picker = ImagePicker();
  final _supabase = SupabaseConnection.client;

  /// Returns AppResult.success(null) when the user cancelled selection.
  Future<AppResult<File?>> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image == null) return AppResult.success(null);
      return AppResult.success(File(image.path));
    } catch (e) {
      return AppResult.failure('Не удалось открыть галерею. Проверьте разрешения приложения.');
    }
  }

  Future<AppResult<String>> uploadAvatar({required File file, required String userId}) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/avatar.$fileExt';
      await _supabase.storage.from('avatars').upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return AppResult.success('$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}');
    } on StorageException catch (e) {
      return AppResult.failure('Ошибка загрузки аватара: ${e.message}');
    } catch (e) {
      return AppResult.failure('Не удалось загрузить аватар. Попробуйте позже.');
    }
  }
}
