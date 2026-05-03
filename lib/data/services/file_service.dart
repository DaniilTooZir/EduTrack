import 'dart:io';

import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/utils/app_result.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  final _supabase = SupabaseConnection.client;

  /// Returns AppResult.success(null) when the user cancelled selection.
  Future<AppResult<PlatformFile?>> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip', 'rar'],
      );
      if (result == null) return AppResult.success(null);
      return AppResult.success(result.files.first);
    } catch (e) {
      return AppResult.failure('Не удалось открыть файловый менеджер. Проверьте разрешения приложения.');
    }
  }

  Future<AppResult<String>> uploadFile({required PlatformFile file, required String folderName}) async {
    try {
      final safeName = _sanitizeFileName(file.name);
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final path = '$folderName/$uniqueName';
      final fileBytes = file.path != null ? File(file.path!) : null;
      if (fileBytes == null) {
        return AppResult.failure('Не удалось прочитать файл. Попробуйте выбрать его заново.');
      }
      await _supabase.storage.from('homework_files').upload(path, fileBytes);
      return AppResult.success(_supabase.storage.from('homework_files').getPublicUrl(path));
    } catch (e) {
      return AppResult.failure('Не удалось загрузить файл. Проверьте соединение и попробуйте снова.');
    }
  }

  String _sanitizeFileName(String name) {
    const ruToEn = {
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shch',
      'ъ': '',
      'ы': 'y',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
    };
    String result = name.toLowerCase();
    String transliterated = '';
    for (int i = 0; i < result.length; i++) {
      transliterated += ruToEn[result[i]] ?? result[i];
    }
    result = transliterated.replaceAll(' ', '_');
    result = result.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    if (result.length > 100) {
      final ext = result.contains('.') ? result.split('.').last : '';
      result = result.substring(0, 80) + (ext.isNotEmpty ? '.$ext' : '');
    }
    return result;
  }
}
