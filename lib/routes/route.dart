import 'package:edu_track/providers/user_provider.dart';
import 'package:edu_track/routes/app_routes.dart';
import 'package:edu_track/ui/screens/admin/academic_periods_screen.dart';
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
import 'package:edu_track/ui/screens/teacher/teacher_journal_screen.dart';
import 'package:edu_track/ui/screens/teacher/teacher_lesson_comment_screen.dart';
import 'package:edu_track/ui/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  // Список публичных путей, доступных без авторизации
  static const publicPaths = [
    AppRoutes.login,
    AppRoutes.splash,
    AppRoutes.welcome,
    AppRoutes.institutionRequest,
    AppRoutes.checkStatus,
  ];

  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: userProvider,
      // Перенаправление в зависимости от состояния авторизации и роли пользователя
      redirect: (context, state) {
        if (!userProvider.isInitialized) return null;
        final bool loggedIn = userProvider.userId != null;
        final bool isGoingToPublic = publicPaths.contains(state.matchedLocation);
        if (!loggedIn && !isGoingToPublic) {
          return AppRoutes.welcome;
        }
        if (loggedIn && isGoingToPublic) {
          switch (userProvider.role) {
            case 'admin':
              return AppRoutes.adminHome;
            case 'teacher':
              return AppRoutes.teacherHome;
            case 'student':
              return AppRoutes.studentHome;
            case 'schedule_operator':
              return AppRoutes.scheduleOperatorHome;
            default:
              return AppRoutes.welcome;
          }
        }
        return null;
      },

      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.welcome, builder: (context, state) => const WelcomeScreen()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: AppRoutes.institutionRequest, builder: (context, state) => const InstitutionRequestScreen()),
        GoRoute(path: AppRoutes.checkStatus, builder: (context, state) => const CheckRequestStatusScreen()),
        GoRoute(path: AppRoutes.adminHome, builder: (context, state) => const AdminHomeScreen()),
        GoRoute(path: AppRoutes.adminPeriods, builder: (context, state) => const AcademicPeriodsScreen()),
        GoRoute(path: AppRoutes.teacherHome, builder: (context, state) => const TeacherHomeScreen()),
        GoRoute(path: AppRoutes.studentHome, builder: (context, state) => const StudentHomeScreen()),
        GoRoute(path: AppRoutes.scheduleOperatorHome, builder: (context, state) => const ScheduleOperatorHomeScreen()),
        GoRoute(path: AppRoutes.adminAddUser, builder: (context, state) => const AddUserScreen()),
        GoRoute(path: AppRoutes.teacherLessonComments, builder: (context, state) => const LessonCommentsScreen()),
        GoRoute(path: AppRoutes.teacherGrades, builder: (context, state) => const TeacherGradeScreen()),
        GoRoute(
          path: AppRoutes.teacherHomeworkStatus,
          builder: (context, state) => const TeacherHomeworkStatusScreen(),
        ),
        GoRoute(
          path: AppRoutes.studentLessonComments,
          builder: (context, state) => const StudentLessonCommentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.teacherJournal,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            return TeacherJournalScreen(groupId: extra?['groupId'] ?? '', subjectId: extra?['subjectId'] ?? '');
          },
        ),
      ],

      errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Страница не найдена: ${state.error}'))),
    );
  }
}
