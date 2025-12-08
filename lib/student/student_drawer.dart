import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../models/role.dart';
import '../shared/current_student_store.dart';
import 'profile.dart';

class StudentDrawer extends StatelessWidget {
  final int currentTab; // 0=Home, 1=Subjects, 2=TimeTable, 3=Alerts
  const StudentDrawer({super.key, this.currentTab = 0});

  void _goTab(int tab) {
    Get.offAllNamed(AppRoutes.studentHome, arguments: {'tab': tab});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with student details
            ValueListenableBuilder<CurrentStudent>(
              valueListenable: CurrentStudentStore.I.student,
              builder: (context, s, _) {
                final initials = s.name
                    .split(' ')
                    .where((e) => e.isNotEmpty)
                    .map((e) => e[0].toUpperCase())
                    .join();
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                  accountEmail: Text(
                    '${s.roll} • ${s.program} • ${s.semester}',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  onDetailsPressed: () {
                    Navigator.pop(context);
                    Get.to(() => const StudentProfileScreen());
                  },
                );
              },
            ),

            // Navigation items
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home'),
              selected: currentTab == 0,
              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _goTab(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Subjects'),
              selected: currentTab == 1,
              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _goTab(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule_rounded),
              title: const Text('Time Table'),
              selected: currentTab == 2,
              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _goTab(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Alerts'),
              selected: currentTab == 3,
              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _goTab(3);
              },
            ),

            const Spacer(),
            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About App'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Campus QR Attendance',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.qr_code_2, size: 48),
                  children: const [
                    Text(
                      'A modern QR-based attendance system for colleges.\n'
                      'Built with Flutter.',
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                RoleStore.isLoggedIn = false;
                RoleStore.role = null;
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}