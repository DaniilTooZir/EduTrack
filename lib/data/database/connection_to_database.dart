import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edu_track/data/database/clean_http_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Класс для инициализации и доступа к Supabase
class SupabaseConnection {
  // Инициализация Supabase с использованием переменных окружения
  static Future<void> initializeSupabase() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception('Отсутствует интернет-соединение. Проверьте сеть и перезапустите приложение.');
    }

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    // Проверка на наличие ключей
    if (url == null || anonKey == null || url.isEmpty || anonKey.isEmpty) {
      throw Exception('Ошибка конфигурации: Ключи доступа не найдены в .env файле.');
    }
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        httpClient: CleanHttpClient(),
        headers: {'X-Supabase-Client-Platform-Version': 'Windows 10 Pro 10.0'},
      );
      print('--- Supabase успешно инициализирован ---');
    } catch (e) {
      throw Exception('не удалось подключиться к серверу Supabase: $e');
    }
  }

  // Геттер для получения текущего экземпляра клиента Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
