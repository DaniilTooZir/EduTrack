import 'dart:io';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  final _supabase = SupabaseConnection.client;
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip', 'rar'],
    );

    if (result == null) return null;
    return result.files.first;
  }

  Future<String?> uploadFile({required PlatformFile file, required String folderName}) async {
    try {
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final path = '$folderName/$uniqueName';
      final fileBytes = file.path != null ? File(file.path!) : null;
      if (fileBytes == null) return null;
      await _supabase.storage.from('homework_files').upload(path, fileBytes);
      return _supabase.storage.from('homework_files').getPublicUrl(path);
    } catch (e) {
      print('Ошибка загрузки файла: $e');
      return null;
    }
  }
}
