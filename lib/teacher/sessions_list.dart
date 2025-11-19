import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../mock/store.dart';
import '../models/session.dart'; // for SessionStatus

enum ClassFilter { all, upcoming, done }

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  final store = DataStore.I;
  ClassFilter filter = ClassFilter.all;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => mounted ? setState(() {}) : null;
    store.tick.addListener(_listener);
  }

  @override
  void dispose() {
    store.tick.removeListener(_listener);
    super.dispose();
  }

  bool _isDone(ClassSlot s) {
    final sessionsToday = store.sessionsForDate(s.subject, s.section, s.start);
    return sessionsToday.any(
      (x) => x.status == SessionStatus.active || x.status == SessionStatus.closed,
    );
  }

  Iterable<ClassSlot> _filtered(List<ClassSlot> slots) {
    final now = DateTime.now();
    switch (filter) {
      case ClassFilter.all:
        return slots;
      case ClassFilter.upcoming:
        return slots.where((s) => !_isDone(s) && !s.end.isBefore(now));
      case ClassFilter.done:
        return slots.where(_isDone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = store.todaySlots();
    final data = _filtered(slots).toList();

    // Responsive horizontal padding and bottom padding to avoid nav bar overlap
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today’s Classes'),
        // Put the filter as the AppBar bottom so it shares the exact same background/tint
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<ClassFilter>(
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  segments: const [
                    ButtonSegment(value: ClassFilter.all, label: Text('All')),
                    ButtonSegment(value: ClassFilter.upcoming, label: Text('Upcoming')),
                    ButtonSegment(value: ClassFilter.done, label: Text('Done')),
                  ],
                  selected: {filter},
                  onSelectionChanged: (sel) {
                    if (sel.isNotEmpty) setState(() => filter = sel.first);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentMax = 1000.0;
          final basePad = 16.0;
          final extra =
              constraints.maxWidth > contentMax ? (constraints.maxWidth - contentMax) / 2 : 0;
          final hPad = basePad + extra;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: data.isEmpty
                ? _EmptyState(
                    icon: filter == ClassFilter.done ? Icons.event_available_outlined : Icons.event_busy_outlined,
                    title: filter == ClassFilter.done ? 'No classes marked done yet' : 'No upcoming classes',
                    subtitle: filter == ClassFilter.done
                        ? 'Once you start or close a session, it will appear here.'
                        : 'All set for now. You can start a class from the dashboard.',
                    horizontalPadding: hPad,
                    bottomPadding: bottomInset,
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomInset),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = data[i];
                      final done = _isDone(s);

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text('Section: ${s.section}'),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                                  ),
                                  const Spacer(),
                                  Text('${_hhmm(s.start)} - ${_hhmm(s.end)}',
                                      style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final sess = store.startOrResumeSession(s.subject, s.section);
                                        await Get.toNamed(AppRoutes.teacherLiveQr, arguments: {
                                          'subject': s.subject,
                                          'section': s.section,
                                          'sessionId': sess.id,
                                        });
                                        setState(() {}); // refresh on return
                                      },
                                      icon: const Icon(Icons.play_circle_outline),
                                      label: Text(done ? 'Resume' : 'Start'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final active = store.getActiveSession(s.subject, s.section);
                                        final latest = store.getLatestSession(s.subject, s.section);
                                        final sessionId = active?.id ?? latest?.id;
                                        if (sessionId != null) {
                                          Get.toNamed(AppRoutes.teacherAttendees, arguments: {
                                            'subject': s.subject,
                                            'section': s.section,
                                            'sessionId': sessionId,
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('No session yet. Start one first.')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.people_outline),
                                      label: const Text('Attendees'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double horizontalPadding;
  final double bottomPadding;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.horizontalPadding = 16,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, bottomPadding),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Center(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}