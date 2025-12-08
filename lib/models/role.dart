enum UserRole { teacher, student }

String roleToString(UserRole r) => r == UserRole.teacher ? 'teacher' : 'student';
UserRole roleFromString(String s) => s.toLowerCase() == 'teacher' ? UserRole.teacher : UserRole.student;

// Dev-only in-memory store
class RoleStore {
  static bool isLoggedIn = false;
  static UserRole? role;
}