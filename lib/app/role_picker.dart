import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/role.dart';
import 'routes.dart';

class RolePicker extends StatelessWidget {
  const RolePicker({super.key});

  void _select(UserRole role) {
    RoleStore.isLoggedIn = true; // simulate auth
    RoleStore.role = role;

    if (role == UserRole.teacher) {
      Get.offAllNamed(AppRoutes.teacherHome);
    } else {
      Get.offAllNamed(AppRoutes.studentHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Choose how you want to continue (dev only).'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _select(UserRole.teacher),
                icon: const Icon(Icons.school),
                label: const Text('I am a Teacher'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _select(UserRole.student),
                icon: const Icon(Icons.person),
                label: const Text('I am a Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}