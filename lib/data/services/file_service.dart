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
      final safeName = _sanitizeFileName(file.name);
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
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

  String _sanitizeFileName(String name) {
    const ru = 'а-б-в-г-д-е-ё-ж-з-и-й-к-л-м-н-о-п-р-с-т-у-ф-х-ц-ч-ш-щ-ъ-ы-ь-э-ю-я';
    const en = 'a-b-v-g-d-e-yo-zh-z-i-y-k-l-m-n-o-p-r-s-t-u-f-kh-ts-ch-sh-shch--y--e-yu-ya';
    final ruList = ru.split('-');
    final enList = en.split('-');
    String res = name.toLowerCase();
    for (int i = 0; i < ruList.length; i++) {
      res = res.replaceAll(ruList[i], enList[i]);
    }
    res = res.replaceAll(' ', '_');
    res = res.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return res;
  }
}
