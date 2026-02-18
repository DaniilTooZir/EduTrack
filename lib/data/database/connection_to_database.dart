import 'package:edu_track/data/database/clean_http_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Класс для инициализации и доступа к Supabase
class SupabaseConnection {
  // Инициализация Supabase с использованием переменных окружения
  static Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      httpClient: CleanHttpClient(),
      headers: {'X-Supabase-Client-Platform-Version': 'Windows 10 Pro 10.0'},
    );
  }

  // Геттер для получения текущего экземпляра клиента Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
