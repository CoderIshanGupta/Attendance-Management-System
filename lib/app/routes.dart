import 'package:get/get.dart';

// Auth
import '../auth/login_page.dart';
import '../auth/signup_page.dart';

// App-level gate/middleware
import 'role_gate.dart';
import 'role_middleware.dart';
import 'role_picker.dart';

// Teacher
import '../teacher/shell.dart';
import '../teacher/live_qr.dart';
import '../teacher/attendees.dart';

// Student
import '../student/shell.dart';

// Shared
import '../shared/profile.dart';
import '../shared/settings.dart';

class AppRoutes {
  // Core
  static const splash = '/splash';
  static const rolePicker = '/role-picker';
  static const login = '/login';
  static const signup = '/signup';

  // Teacher
  static const teacherHome = '/teacher';
  static const teacherLiveQr = '/teacher/live-qr';
  static const teacherAttendees = '/teacher/attendees';

  // Student
  static const studentHome = '/student';

  // Shared
  static const profile = '/profile';
  static const settings = '/settings';

  static final pages = <GetPage>[
    // App flow
    GetPage(name: splash, page: () => const RoleGate()),
    GetPage(name: rolePicker, page: () => const RolePicker()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: signup, page: () => const SignUpPage()),

    // Teacher shell (bottom nav + drawer)
    GetPage(
      name: teacherHome,
      page: () => const TeacherShell(),
      middlewares: [RoleMiddleware.teacher()],
    ),
    GetPage(
      name: teacherLiveQr,
      page: () => const LiveQrScreen(),
      middlewares: [RoleMiddleware.teacher()],
    ),
    GetPage(
      name: teacherAttendees,
      page: () => const AttendeesScreen(),
      middlewares: [RoleMiddleware.teacher()],
    ),

    // Student
    GetPage(
      name: studentHome,
      page: () => const StudentShell(),
      middlewares: [RoleMiddleware.student()],
    ),

    // Shared
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];
}