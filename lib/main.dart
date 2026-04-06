import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/route.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Точка входа
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
    await SupabaseConnection.initializeSupabase();
    await NotificationService().init();

    final userProvider = UserProvider();
    final themeProvider = ThemeProvider();
    final appDatabase = AppDatabase();

    await Future.wait([userProvider.loadSession(), themeProvider.loadTheme()]);

    final router = AppNavigation.createRouter(userProvider);
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          Provider<AppDatabase>.value(value: appDatabase),
        ],
        child: MyApp(router: router),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  const Text('Ошибка запуска приложения', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    e.toString().replaceAll('Exception:', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(onPressed: () {}, child: const Text('Попробовать снова')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduTrack',
      theme: themeProvider.currentThemeData,
      routerConfig: router,
    );
  }
}
