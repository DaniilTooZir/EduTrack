import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, purple }

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, surface: Colors.white, background: Colors.grey.shade50),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9575CD),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
    ),
  );

  static final ThemeData purpleTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5E35B1),
      primary: const Color(0xFF5E35B1),
      secondary: const Color(0xFF7E57C2),
      surface: Colors.white.withOpacity(0.9),
      background: const Color(0xFFF3E5F5),
    ),
    scaffoldBackgroundColor: const Color(0xFFF3E5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5E35B1),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );

  static LinearGradient getBackgroundGradient(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeMode.dark:
        return const LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeMode.purple:
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

class ThemeProvider with ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.purple;

  AppThemeMode get mode => _mode;

  ThemeData get currentThemeData {
    switch (_mode) {
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.purple:
        return AppTheme.purpleTheme;
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('theme_mode');
    if (savedMode != null) {
      _mode = AppThemeMode.values.firstWhere((e) => e.toString() == savedMode, orElse: () => AppThemeMode.purple);
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }
}
