import 'package:go_router/go_router.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';
import 'package:edu_track/ui/screens/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
  ],
);