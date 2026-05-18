import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/route.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

typedef _AppData = ({GoRouter router, UserProvider userProvider, ThemeProvider themeProvider, AppDatabase db});

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<_AppData> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<_AppData> _initialize() async {
    try {
      await dotenv.load();
    } catch (_) {
      throw Exception('Файл конфигурации .env не найден. Обратитесь к разработчику.');
    }

    await SupabaseConnection.initializeSupabase();
    await NotificationService().init();

    final db = AppDatabase();
    final userProvider = UserProvider(appDatabase: db);
    final themeProvider = ThemeProvider();
    await Future.wait([userProvider.loadSession(), themeProvider.loadTheme()]);

    final router = AppNavigation.createRouter(userProvider);
    return (router: router, userProvider: userProvider, themeProvider: themeProvider, db: db);
  }

  void _retry() => setState(() {
    _initFuture = _initialize();
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppData>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        if (snapshot.hasError) {
          return _ErrorApp(error: snapshot.error.toString().replaceAll('Exception: ', ''), onRetry: _retry);
        }
        final data = snapshot.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: data.userProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: data.themeProvider),
            Provider<AppDatabase>.value(value: data.db),
          ],
          child: MyApp(router: data.router),
        );
      },
    );
  }
}

class _ErrorApp extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorApp({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: onRetry, child: const Text('Попробовать снова')),
              ],
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
      scaffoldMessengerKey: MessengerHelper.scaffoldMessengerKey,
    );
  }
}
