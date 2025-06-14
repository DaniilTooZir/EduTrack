import 'package:go_router/go_router.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
  ],
);