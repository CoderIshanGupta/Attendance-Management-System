import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../mock/store.dart';
import '../models/session.dart';

class AttendeesScreen extends StatefulWidget {
  const AttendeesScreen({super.key});

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends State<AttendeesScreen> {
  final store = DataStore.I;

  late final String subject;
  late final String section;
  String? sessionId;

  bool _showPresent = true;
  bool _showAbsent = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    subject = (Get.arguments?['subject'] ?? 'Subject') as String;
    section = (Get.arguments?['section'] ?? 'Section') as String;

    // Prefer passed sessionId; otherwise pick active, else latest
    sessionId = Get.arguments?['sessionId'] as String?;
    sessionId ??= store.getActiveSession(subject, section)?.id;
    sessionId ??= store.getLatestSession(subject, section)?.id;
  }

  @override
  Widget build(BuildContext context) {
    if (sessionId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Attendees • $subject — $section')),
        body: const Center(child: Text('No session found. Start a session first.')),
      );
    }

    // Session object for banner logic
    final sessions = store.sessionsFor(subject, section);
    Session? session;
    for (final s in sessions) {
      if (s.id == sessionId) { session = s; break; }
    }

    final roster = store.roster(section);
    final locked = store.isOverrideLocked(sessionId!);

    final rows = roster.map((st) {
      final present = store.isPresent(sessionId!, st.id) ?? false;
      return _StudentRow(studentId: st.id, roll: st.roll, name: st.name, present: present);
    }).where((r) {
      if (!_showPresent && r.present) return false;
      if (!_showAbsent && !r.present) return false;
      if (_query.isEmpty) return true;
      return r.roll.toLowerCase().contains(_query.toLowerCase()) ||
          r.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Attendees • $subject — $section')),
      body: Column(
        children: [
          // Search + filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search roll/name',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Present'),
                  selected: _showPresent,
                  onSelected: (v) => setState(() => _showPresent = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Absent'),
                  selected: _showAbsent,
                  onSelected: (v) => setState(() => _showAbsent = v),
                ),
              ],
            ),
          ),

          // Inline banner (active / countdown / locked)
          if (session != null) _EditWindowBanner(session: session!, locked: locked),

          // List
          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final row = rows[i];
                return ListTile(
                  title: Text('${row.roll} • ${row.name}'),
                  onTap: locked
                      ? () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edits disabled after 24 hours.')),
                          );
                        }
                      : null,
                  trailing: Switch(
                    value: row.present,
                    onChanged: locked
                        ? null
                        : (v) {
                            final ok = store.setPresent(sessionId!, row.studentId, v);
                            if (!ok) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edits disabled for this session.')),
                              );
                            }
                            setState(() {}); // re-read present values
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow {
  final String studentId;
  final String roll;
  final String name;
  final bool present;
  _StudentRow({required this.studentId, required this.roll, required this.name, required this.present});
}

// Inline banner widget for edit window status
class _EditWindowBanner extends StatelessWidget {
  final Session session;
  final bool locked;
  const _EditWindowBanner({required this.session, required this.locked});

  @override
  Widget build(BuildContext context) {
    Color bg;
    IconData icon;
    String text;

    if (session.status == SessionStatus.active) {
      bg = Colors.green.withOpacity(0.12);
      icon = Icons.edit;
      text = 'Manual overrides enabled (session active)';
    } else if (session.status == SessionStatus.closed) {
      if (locked) {
        bg = Colors.redAccent.withOpacity(0.12);
        icon = Icons.lock;
        text = 'Edits disabled 24 hours after a session is closed.';
      } else {
        final remain = _remaining(session);
        bg = Colors.amber.withOpacity(0.12);
        icon = Icons.timer_outlined;
        text = 'Manual overrides available for ${_fmt(remain)}';
      }
    } else {
      // Scheduled or cancelled: no special note
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: bg.withOpacity(0.8), width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Duration _remaining(Session s) {
    // Only called when s.status == closed and not locked
    final until = s.endAt!.add(const Duration(hours: 24));
    return until.difference(DateTime.now());
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0 && m <= 0) return '0m';
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }
}