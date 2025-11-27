import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/role.dart';
import '../shared/loading.dart';
import 'routes.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_decide);
  }

  void _decide() {
    if (!RoleStore.isLoggedIn) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    final role = RoleStore.role;
    if (role == null) {
      Get.offAllNamed(AppRoutes.rolePicker);
      return;
    }
    if (role == UserRole.teacher) {
      Get.offAllNamed(AppRoutes.teacherHome);
    } else {
      Get.offAllNamed(AppRoutes.studentHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(label: 'Checking role...');
  }
}