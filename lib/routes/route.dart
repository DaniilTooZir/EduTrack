import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';
import 'package:edu_track/ui/screens/splash_screen.dart';
import 'package:edu_track/ui/screens/institution_request_screen.dart';
import 'package:edu_track/ui/screens/check_request_status_screen.dart';
import 'package:edu_track/ui/screens/login_screen.dart';
import 'package:edu_track/ui/screens/admin/admin_home_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_home_screen.dart';
import 'package:edu_track/ui/screens/student/student_home_screen.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_operator_home_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/institution-request', builder: (context, state) => const InstitutionRequestScreen()),
    GoRoute(path: '/check-status', builder: (context, state) => const CheckRequestStatusScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/admin-home', builder: (context, state) => const AdminHomeScreen()),
    GoRoute(path: '/teacher-home', builder: (context, state) => const TeacherHomeScreen()),
    GoRoute(path: '/student-home', builder: (context, state) => const StudentHomeScreen()),
    GoRoute(path: '/admin-add-user', builder: (context, state) => const AddUserScreen()),
    GoRoute(path: '/schedule-operator-home', builder: (context, state) => const ScheduleOperatorHomeScreen()),
  ],
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loggedIn = userProvider.userId != null && userProvider.role != null;

    final publicPaths = ['/', '/login', '/splash', '/institution-request', '/check-status'];

    if (!loggedIn && !publicPaths.contains(state.matchedLocation)) {
      return '/';
    }

    if (loggedIn) {
      if (publicPaths.contains(state.matchedLocation)) {
        switch (userProvider.role) {
          case 'admin':
            return '/admin-home';
          case 'teacher':
            return '/teacher-home';
          case 'student':
            return '/student-home';
          case 'schedule_operator':
            return '/schedule-operator-home';
          default:
            return '/';
        }
      }
    }
    return null;
  },
);
