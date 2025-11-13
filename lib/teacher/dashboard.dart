import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../models/role.dart';
import '../mock/store.dart';
import '../models/session.dart';
import 'teacher_drawer.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final store = DataStore.I;

  Future<void> _refresh() async => setState(() {});

  void _logout() {
    RoleStore.isLoggedIn = false;
    RoleStore.role = null;
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${now.day}/${now.month}/${now.year}';
    final isWide = MediaQuery.of(context).size.width >= 700;
    final next = store.nextClass();
    final leftToday = store.classesLeftToday();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: const TeacherDrawer(currentTab: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final contentMax = isWide ? 900.0 : maxW;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMax),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WelcomeHeader(
                            dateStr: dateStr,
                            name: store.teacherName,
                          ),
                          const SizedBox(height: 16),
                          _QuickStatsRow(
                            isWide: isWide,
                            subjects: store.assignmentsCount(),
                            sections: store.sectionsCount(),
                            leftToday: leftToday,
                          ),
                          if (next != null) ...[
                            const SizedBox(height: 16),
                            _NextUpCard(
                              subject: next.subject,
                              section: next.section,
                              time: _hhmm(next.start),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ...store.assignments.entries.map(
                            (e) => _SubjectCard(
                              subject: e.key,
                              sections: e.value,
                              onChanged: _refresh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _weekday(int i) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(i - 1).clamp(0, 6)];
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _WelcomeHeader extends StatelessWidget {
  final String dateStr;
  final String name;
  const _WelcomeHeader({required this.dateStr, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final bool isWide;
  final int subjects;
  final int sections;
  final int leftToday;
  const _QuickStatsRow({
    required this.isWide,
    required this.subjects,
    required this.sections,
    required this.leftToday,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _StatCard(icon: Icons.menu_book_outlined, label: 'Subjects', value: subjects.toString(), color: Colors.indigo),
      _StatCard(icon: Icons.groups_2_outlined, label: 'Sections', value: sections.toString(), color: Colors.teal),
      _StatCard(icon: Icons.schedule_outlined, label: 'Left Today', value: leftToday.toString(), color: Colors.orange),
    ];

    if (isWide) {
      return Row(
        children: [
          Expanded(child: items[0]),
          const SizedBox(width: 12),
          Expanded(child: items[1]),
          const SizedBox(width: 12),
          Expanded(child: items[2]),
        ],
      );
    }
    return Column(
      children: [
        items[0],
        const SizedBox(height: 12),
        items[1],
        const SizedBox(height: 12),
        items[2],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final String subject;
  final String section;
  final String time;
  const _NextUpCard({required this.subject, required this.section, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.15),
              child: const Icon(Icons.alarm, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next up', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '$subject — $section',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String subject;
  final List<String> sections;
  final Future<void> Function() onChanged;
  const _SubjectCard({required this.subject, required this.sections, required this.onChanged});

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool expanded = false;
  final store = DataStore.I;

  Chip _statusChip(SessionStatus? status) {
    Color color;
    String text;
    switch (status) {
      case SessionStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case SessionStatus.closed:
        color = Colors.grey;
        text = 'Closed';
        break;
      case SessionStatus.cancelled:
        color = Colors.redAccent;
        text = 'Cancelled';
        break;
      case SessionStatus.scheduled:
      default:
        color = Colors.blue;
        text = 'Scheduled';
    }
    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(widget.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onTap: () => setState(() => expanded = !expanded),
            ),
            if (expanded)
              ...widget.sections.map((sec) {
                final active = store.getActiveSession(widget.subject, sec);
                final latest = store.getLatestSession(widget.subject, sec);
                final status = active != null ? SessionStatus.active : (latest?.status ?? SessionStatus.scheduled);
                final startLabel = active != null ? 'Resume' : 'Start';
                final sessionId = active?.id ?? latest?.id;

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Section: $sec', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          _statusChip(status),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final s = store.startOrResumeSession(widget.subject, sec);
                                await Get.toNamed(AppRoutes.teacherLiveQr, arguments: {
                                  'subject': widget.subject,
                                  'section': sec,
                                  'sessionId': s.id,
                                });
                                await widget.onChanged();
                                setState(() {});
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: Text(startLabel),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: sessionId == null
                                  ? null
                                  : () {
                                      Get.toNamed(AppRoutes.teacherAttendees, arguments: {
                                        'subject': widget.subject,
                                        'section': sec,
                                        'sessionId': sessionId,
                                      });
                                    },
                              icon: const Icon(Icons.people_outline),
                              label: const Text('Attendees'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}