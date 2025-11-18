import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../models/role.dart';
import '../shared/profile_store.dart';

class TeacherDrawer extends StatelessWidget {
  final int currentTab; // 0=Home, 1=Classes, 2=Stats, 3=Alerts
  const TeacherDrawer({super.key, this.currentTab = 0});

  void _goTab(int tab) {
    Get.offAllNamed(AppRoutes.teacherHome, arguments: {'tab': tab});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Reactive profile header
            ValueListenableBuilder<Profile>(
              valueListenable: ProfileStore.I.profile,
              builder: (context, p, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(p.avatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed(AppRoutes.profile);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                              Text(
                                p.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('${p.designation} • ${p.branch}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home'),
              selected: currentTab == 0,
              onTap: () { Navigator.pop(context); _goTab(0); },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_rounded),
              title: const Text('Today’s Classes'),
              selected: currentTab == 1,
              onTap: () { Navigator.pop(context); _goTab(1); },
            ),
            ListTile(
              leading: const Icon(Icons.insights_rounded),
              title: const Text('Stats & Reports'),
              selected: currentTab == 2,
              onTap: () { Navigator.pop(context); _goTab(2); },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Alerts'),
              selected: currentTab == 3,
              onTap: () { Navigator.pop(context); _goTab(3); },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings),
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