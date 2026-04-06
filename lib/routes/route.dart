import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/ui/screens/admin/add_user_screen.dart';
import 'package:edu_track/ui/screens/admin/admin_home_screen.dart';
import 'package:edu_track/ui/screens/check_request_status_screen.dart';
import 'package:edu_track/ui/screens/institution_request_screen.dart';
import 'package:edu_track/ui/screens/login_screen.dart';
import 'package:edu_track/ui/screens/schedule_operator/schedule_operator_home_screen.dart';
import 'package:edu_track/ui/screens/splash_screen.dart';
import 'package:edu_track/ui/screens/student/student_home_screen.dart';
import 'package:edu_track/ui/screens/student/student_lesson_comment_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_grade_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_home_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_homework_status_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_lesson_comment_screen.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  // Список публичных путей, доступных без авторизации
  static const publicPaths = ['/login', '/splash', '/', '/institution-request', '/check-status'];

  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: userProvider,
      // Перенаправление в зависимости от состояния авторизации и роли пользователя
      redirect: (context, state) {
        if (!userProvider.isInitialized) return null;
        final bool loggedIn = userProvider.userId != null;
        final bool isGoingToPublic = publicPaths.contains(state.matchedLocation);
        if (!loggedIn && !isGoingToPublic) {
          return '/';
        }
        if (loggedIn && isGoingToPublic) {
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
        return null;
      },

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
        GoRoute(path: '/teacher/lesson_comments', builder: (context, state) => const LessonCommentsScreen()),
        GoRoute(path: '/teacher/grades', builder: (context, state) => const TeacherGradeScreen()),
        GoRoute(path: '/teacher/homework-status', builder: (context, state) => const TeacherHomeworkStatusScreen()),
        GoRoute(path: '/student/lesson_comments', builder: (context, state) => const StudentLessonCommentsScreen()),
      ],

      errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Страница не найдена: ${state.error}'))),
    );
  }
}
