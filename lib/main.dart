import 'package:edu_track/data/database/connection_to_database.dart';
import 'package:edu_track/data/local/app_database.dart';
import 'package:edu_track/data/repositories/chat_repository.dart';
import 'package:edu_track/data/repositories/debt_repository.dart';
import 'package:edu_track/data/repositories/grade_repository.dart';
import 'package:edu_track/data/repositories/group_repository.dart';
import 'package:edu_track/data/repositories/homework_repository.dart';
import 'package:edu_track/data/repositories/lesson_repository.dart';
import 'package:edu_track/data/repositories/schedule_repository.dart';
import 'package:edu_track/data/repositories/subject_repository.dart';
import 'package:edu_track/data/repositories/user_repository.dart';
import 'package:edu_track/data/services/chat_service.dart';
import 'package:edu_track/data/services/debt_service.dart';
import 'package:edu_track/data/services/grade_service.dart';
import 'package:edu_track/data/services/group_service.dart';
import 'package:edu_track/data/services/homework_service.dart';
import 'package:edu_track/data/services/lesson_service.dart';
import 'package:edu_track/data/services/notification_service.dart';
import 'package:edu_track/data/services/prefetch_service.dart';
import 'package:edu_track/data/services/schedule_service.dart';
import 'package:edu_track/data/services/student_service.dart';
import 'package:edu_track/data/services/subject_service.dart';
import 'package:edu_track/providers/connectivity_provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/route.dart';
import 'package:edu_track/ui/theme/app_theme.dart';
import 'package:edu_track/utils/app_constants.dart';
import 'package:edu_track/utils/messenger_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

typedef _AppData =
    ({
      GoRouter router,
      UserProvider userProvider,
      ThemeProvider themeProvider,
      AppDatabase db,
      ScheduleRepository scheduleRepository,
      LessonRepository lessonRepository,
      GradeRepository gradeRepository,
      HomeworkRepository homeworkRepository,
      SubjectRepository subjectRepository,
      GroupRepository groupRepository,
      UserRepository userRepository,
      DebtRepository debtRepository,
      ChatRepository chatRepository,
    });

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
    await SupabaseConnection.initializeSupabase();
    return _finishInit();
  }

  Future<_AppData> _initializeOffline() async {
    await SupabaseConnection.initializeSupabaseOffline();
    return _finishInit();
  }

  Future<_AppData> _finishInit() async {
    await NotificationService().init();

    final db = AppDatabase();
    final userRepository = UserRepository(local: db);
    final scheduleRepository = ScheduleRepository(remote: ScheduleService(), local: db);
    final lessonRepository = LessonRepository(remote: LessonService(), local: db);
    final gradeRepository = GradeRepository(remote: GradeService(), local: db);
    final homeworkRepository = HomeworkRepository(remote: HomeworkService(), local: db);
    final subjectRepository = SubjectRepository(remote: SubjectService(), local: db);
    final groupRepository = GroupRepository(groupService: GroupService(), studentService: StudentService(), local: db);
    final debtRepository = DebtRepository(remote: DebtService(), local: db);
    final chatRepository = ChatRepository(remote: ChatService(), local: db);
    final prefetchService = PrefetchService(
      scheduleRepo: scheduleRepository,
      hwRepo: homeworkRepository,
      subjectRepo: subjectRepository,
      groupRepo: groupRepository,
      chatRepo: chatRepository,
      gradeRepo: gradeRepository,
      db: db,
    );
    final userProvider = UserProvider(
      userRepository: userRepository,
      homeworkRepository: homeworkRepository,
      prefetchService: prefetchService,
    );
    final themeProvider = ThemeProvider();
    await Future.wait([userProvider.loadSession(), themeProvider.loadTheme()]);

    final router = AppNavigation.createRouter(userProvider);
    return (
      router: router,
      userProvider: userProvider,
      themeProvider: themeProvider,
      db: db,
      scheduleRepository: scheduleRepository,
      lessonRepository: lessonRepository,
      gradeRepository: gradeRepository,
      homeworkRepository: homeworkRepository,
      subjectRepository: subjectRepository,
      groupRepository: groupRepository,
      userRepository: userRepository,
      debtRepository: debtRepository,
      chatRepository: chatRepository,
    );
  }

  void _retry() => setState(() {
    _initFuture = _initialize();
  });

  void _enterOffline() => setState(() {
    _initFuture = _initializeOffline();
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
          final isNoInternet = snapshot.error is NoInternetException;
          final error = snapshot.error.toString().replaceAll('Exception: ', '');
          return _ErrorApp(error: error, onRetry: _retry, onOffline: isNoInternet ? _enterOffline : null);
        }
        final data = snapshot.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: data.userProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: data.themeProvider),
            Provider<AppDatabase>.value(value: data.db),
            Provider<UserRepository>.value(value: data.userRepository),
            Provider<ScheduleRepository>.value(value: data.scheduleRepository),
            Provider<LessonRepository>.value(value: data.lessonRepository),
            Provider<GradeRepository>.value(value: data.gradeRepository),
            Provider<HomeworkRepository>.value(value: data.homeworkRepository),
            Provider<SubjectRepository>.value(value: data.subjectRepository),
            Provider<GroupRepository>.value(value: data.groupRepository),
            Provider<DebtRepository>.value(value: data.debtRepository),
            Provider<ChatRepository>.value(value: data.chatRepository),
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
  final VoidCallback? onOffline;

  const _ErrorApp({required this.error, required this.onRetry, this.onOffline});

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
                Icon(
                  onOffline != null ? Icons.wifi_off : Icons.error_outline,
                  color: onOffline != null ? Colors.orange : Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  onOffline != null ? 'Нет подключения к интернету' : 'Ошибка запуска приложения',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.m),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: onRetry, child: const Text('Попробовать снова')),
                if (onOffline != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  OutlinedButton.icon(
                    onPressed: onOffline,
                    icon: const Icon(Icons.offline_bolt_outlined),
                    label: const Text('Войти офлайн'),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Text(
                    'Доступны только ранее загруженные данные',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
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
    final isSystem = themeProvider.mode == AppThemeMode.system;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduTrack',
      theme: isSystem ? AppTheme.lightTheme : themeProvider.currentThemeData,
      darkTheme: AppTheme.darkTheme,
      themeMode: isSystem ? ThemeMode.system : ThemeMode.light,
      routerConfig: router,
      scaffoldMessengerKey: MessengerHelper.scaffoldMessengerKey,
      builder: (_, child) => _ConnectivityBanner(child: child!),
    );
  }
}

class _ConnectivityBanner extends StatelessWidget {
  final Widget child;
  const _ConnectivityBanner({required this.child});

  @override
  Widget build(BuildContext context) {
    final isOffline = Provider.of<ConnectivityProvider>(context).isOffline;
    final padding = MediaQuery.of(context).padding;
    return Column(
      children: [
        if (isOffline)
          Material(
            color: Colors.deepOrange.shade800,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    children: const [
                      Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Нет подключения — используются кэшированные данные',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child:
              isOffline
                  ? MediaQuery(data: MediaQuery.of(context).copyWith(padding: padding.copyWith(top: 0)), child: child)
                  : child,
        ),
      ],
    );
  }
}
