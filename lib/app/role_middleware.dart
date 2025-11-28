import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/role.dart';
import 'routes.dart';

class RoleMiddleware extends GetMiddleware {
  final UserRole allowed;
  RoleMiddleware._(this.allowed);

  factory RoleMiddleware.teacher() => RoleMiddleware._(UserRole.teacher);
  factory RoleMiddleware.student() => RoleMiddleware._(UserRole.student);

  @override
  RouteSettings? redirect(String? route) {
    if (!RoleStore.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (RoleStore.role != allowed) {
      return const RouteSettings(name: AppRoutes.rolePicker);
    }
    return null;
  }
}