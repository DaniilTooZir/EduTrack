import 'package:go_router/go_router.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';
import 'package:edu_track/ui/screens/splash_screen.dart';
import 'package:edu_track/ui/screens/institution_request_screen.dart';
import 'package:edu_track/ui/screens/check_request_status_screen.dart';
import 'package:edu_track/ui/screens/login_screen.dart';
import 'package:edu_track/ui/screens/admin_home_screen.dart';
import 'package:edu_track/ui/screens/teacher_home_screen.dart';
import 'package:edu_track/ui/screens/student_home_screen.dart';

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
    GoRoute(
      path: '/institution-request',
      builder: (context, state) => const InstitutionRequestScreen(),
    ),
    GoRoute(
      path: '/check-status',
      builder: (context, state) => const CheckRequestStatusScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin-home',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/teacher-home',
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: '/student-home',
      builder: (context, state) => const StudentHomeScreen(),
    ),
  ],
);