import 'dart:async';

import 'package:edu_track/data/database/clean_http_client.dart';
import 'package:edu_track/utils/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnection {
  static bool _initialized = false;

  static Future<void> initializeSupabase() async {
    if (_initialized) return;

    await _checkInternetConnection();

    final url = AppConfig.supabaseUrl;
    final anonKey = AppConfig.supabaseAnonKey;
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Ошибка конфигурации: ключи доступа не найдены в .env файле.');
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        httpClient: CleanHttpClient(),
        headers: {'X-Supabase-Client-Platform-Version': AppConfig.supabaseClientVersion},
      );
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу. Проверьте соединение и попробуйте снова.');
    }

    _initialized = true;
  }

  static Future<void> _checkInternetConnection() async {
    try {
      await http.head(Uri.parse('https://supabase.com')).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Превышено время ожидания подключения. Проверьте интернет-соединение.');
    } catch (_) {
      throw Exception('Отсутствует интернет-соединение. Проверьте сеть и попробуйте снова.');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
