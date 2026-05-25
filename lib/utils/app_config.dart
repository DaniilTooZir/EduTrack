class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabaseClientVersion = String.fromEnvironment(
    'SUPABASE_CLIENT_VERSION',
    defaultValue: 'Windows 10 Pro 10.0',
  );
}
