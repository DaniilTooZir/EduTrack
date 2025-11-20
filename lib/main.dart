import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/routes/route.dart';
import 'package:edu_track/data/services/moderation_timer.dart';
import 'package:edu_track/data/services/session_service.dart';
import 'package:edu_track/providers/user_provider.dart';

// Точка входа
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConnection.initializeSupabase();
  ModerationTimer.start();

  final savedUserId = await SessionService.getUserId();
  final savedRole = await SessionService.getRole();
  final institutionId = await SessionService.getInstitutionId();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadSession(savedUserId, savedRole, institutionId),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduTrack',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      routerConfig: router,
    );
  }
}
