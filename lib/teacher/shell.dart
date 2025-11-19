import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../mock/store.dart';
import '../shared/notifications.dart';
import 'dashboard.dart';
import 'sessions_list.dart';
import 'section_stats.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _index = 0;

  final pages = const [
    TeacherDashboard(),
    SessionsListScreen(),
    SectionStatsScreen(),
    NotificationPage(),
  ];

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Map && arg['tab'] is int) {
      final t = arg['tab'] as int;
      if (t >= 0 && t < pages.length) _index = t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 360;
    final showFab = _index == 0; // FAB only on Home

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),

      bottomNavigationBar: _BottomNav(
        index: _index,
        onChanged: (i) {
          HapticFeedback.lightImpact();
          setState(() => _index = i);
        },
      ),

      floatingActionButton: showFab
          ? (isNarrow
              ? FloatingActionButton(
                  onPressed: _showQuickStart,
                  child: const Icon(Icons.qr_code_2),
                  tooltip: 'Quick start',
                )
              : FloatingActionButton.extended(
                  onPressed: _showQuickStart,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Quick start'),
                ))
          : null,

      // Keeps the FAB above the NavigationBar to avoid overlap
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showQuickStart() {
    final store = DataStore.I;
    String? year;
    String? branch;
    String? subject;
    String? section;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              final yearOptions = store.years();
              final branchOptions =
                  year == null ? <String>[] : store.branchesForYear(year!);
              final subjectOptions =
                  (year == null || branch == null) ? <String>[] : store.subjectsFor(year!, branch!);
              final sectionOptions =
                  (year == null || branch == null || subject == null)
                      ? <String>[]
                      : store.sectionsFor(year!, branch!, subject!);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Start a session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    value: year,
                    items: yearOptions
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (v) {
                      setSheet(() {
                        year = v;
                        branch = null;
                        subject = null;
                        section = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Branch',
                      prefixIcon: Icon(Icons.account_tree_outlined),
                    ),
                    value: branch,
                    items: branchOptions
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) {
                      setSheet(() {
                        branch = v;
                        subject = null;
                        section = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    value: subject,
                    items: subjectOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      setSheet(() {
                        subject = v;
                        section = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      prefixIcon: Icon(Icons.group_outlined),
                    ),
                    value: section,
                    items: sectionOptions
                        .map((sec) => DropdownMenuItem(value: sec, child: Text(sec)))
                        .toList(),
                    onChanged: (v) => setSheet(() => section = v),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: (year != null && branch != null && subject != null && section != null)
                        ? () {
                            final s = store.startOrResumeSession(subject!, section!);
                            Navigator.pop(context);
                            Get.toNamed(AppRoutes.teacherLiveQr, arguments: {
                              'subject': subject,
                              'section': section,
                              'sessionId': s.id,
                            });
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start now'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: onChanged,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Classes',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Stats',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
      ],
    );
  }
}