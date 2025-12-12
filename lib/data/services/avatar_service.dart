import 'dart:io';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  final _picker = ImagePicker();
  final _supabase = SupabaseConnection.client;

  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image == null) return null;
    return File(image.path);
  }

  Future<String?> uploadAvatar({required File file, required String userId}) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/avatar.$fileExt';
      await _supabase.storage.from('avatars').upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Ошибка загрузки аватара: $e');
      return null;
    }
  }
}
