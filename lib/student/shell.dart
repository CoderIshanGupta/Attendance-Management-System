import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'dashboard.dart';
import 'subjects.dart';
import 'time_table.dart';
import 'alerts.dart';
import 'scan_qr.dart';
import 'student_att_ctrl.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  final pages = const [
    StudentDashboard(),
    StudentSubjectsScreen(),
    StudentTimeTableScreen(),
    StudentAlertsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Allow drawer to switch tab via route argument (same pattern as TeacherShell)
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final t = args['tab'] as int;
      if (t >= 0 && t < pages.length) {
        _index = t;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final att = StudentAttController.I;
    final showFab = _index == 0; // FAB only on Home

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) {
          HapticFeedback.lightImpact();
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_rounded),
            selectedIcon: Icon(Icons.schedule),
            label: 'Time Table',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => Get.to(() => ScanQrScreen(onScan: att.handleQrScan)),
              tooltip: 'Mark Attendance',
              child: const Icon(Icons.qr_code_scanner),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}