import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/route.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/local/app_database.dart';

// Точка входа
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await SupabaseConnection.initializeSupabase();
  final savedUserId = await SessionService.getUserId();
  final savedRole = await SessionService.getRole();
  final institutionId = await SessionService.getInstitutionId();
  final savedGroupId = await SessionService.getGroupId();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final appDatabase = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadSession(savedUserId, savedRole, institutionId, savedGroupId),
        ),
        ChangeNotifierProvider.value(value: themeProvider),
        Provider<AppDatabase>.value(value: appDatabase),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
