import 'dart:async';

import 'package:edu_track/data/database/clean_http_client.dart';
import 'package:edu_track/utils/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NoInternetException implements Exception {
  const NoInternetException(this.message);
  final String message;
  @override
  String toString() => message;
}

class SupabaseConnection {
  static bool _initialized = false;

  static Future<void> initializeSupabase() async {
    if (_initialized) return;
    await _checkInternetConnection();
    await _initClient();
    _initialized = true;
  }

  static Future<void> initializeSupabaseOffline() async {
    if (_initialized) return;
    await _initClient();
    _initialized = true;
  }

  static Future<void> _initClient() async {
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
      throw Exception('Не удалось инициализировать клиент. Проверьте конфигурацию приложения.');
    }
  }

  static Future<void> _checkInternetConnection() async {
    try {
      await http.head(Uri.parse('https://supabase.com')).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw const NoInternetException('Превышено время ожидания подключения. Проверьте интернет-соединение.');
    } catch (_) {
      throw const NoInternetException('Отсутствует интернет-соединение. Проверьте сеть и попробуйте снова.');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
