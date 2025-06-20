import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:edu_track/data/database/clean_http_client.dart';
// Класс для инициализации и доступа к Supabase
class SupabaseConnection{
  // Инициализация Supabase с использованием переменных окружения
  static Future<void> initializeSupabase() async{
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      httpClient: CleanHttpClient(),
    );
  }
  // Геттер для получения текущего экземпляра клиента Supabase
  static SupabaseClient get client => Supabase.instance.client;
}