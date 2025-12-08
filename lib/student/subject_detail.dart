import 'package:flutter/material.dart';
import '../mock/store.dart';
import '../models/session.dart';
import '../shared/attendance_chart.dart';
import '../models/attendance_data.dart';
import '../shared/current_student_store.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final store = DataStore.I;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) setState(() {});
    };
    store.tick.addListener(_listener);
  }

  @override
  void dispose() {
    store.tick.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = CurrentStudentStore.I.student.value;
    final sec = current.section;
    final st = store.findStudentByRoll(sec, current.roll);

    final sessions = store.sessionsFor(widget.subject, sec).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    final total = sessions.length;
    final presents = st == null
        ? 0
        : sessions.where((s) => s.attendance[st.id] == true).length;
    final pct = total == 0 ? 0.0 : (presents / total) * 100.0;

    final daily = _aggregateDailyForStudent(sessions, st);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.15),
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Section: $sec'),
                        const SizedBox(height: 2),
                        Text(
                          'Total classes: $total',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text('Presents: $presents'),
                      ],
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 220,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AttendanceChart(
                  data: daily,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Sessions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Text('No classes recorded yet for this subject.')
          else
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  final d = s.startAt;
                  final date =
                      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                  final time =
                      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                  final present =
                      st != null && s.attendance[st.id] == true;

                  return ListTile(
                    title: Text(date),
                    subtitle: Text('Time: $time'),
                    trailing: Chip(
                      label: Text(
                        present ? 'Present' : 'Absent',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: present ? Colors.green : Colors.redAccent,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<AttendanceData> _aggregateDailyForStudent(
      List<Session> sessions, Student? st) {
    if (st == null) return [];
    final Map<String, int> byDate = {};
    String key(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

    for (final s in sessions) {
      final d = DateTime(s.startAt.year, s.startAt.month, s.startAt.day);
      final k = key(d);
      final present = s.attendance[st.id] == true ? 1 : 0;
      byDate.update(k, (val) => val + present, ifAbsent: () => present);
    }

    final keys = byDate.keys.toList();
    keys.sort((a, b) {
      DateTime parse(String ddmm) {
        final p = ddmm.split('/');
        return DateTime(DateTime.now().year, int.parse(p[1]), int.parse(p[0]));
      }

      return parse(a).compareTo(parse(b));
    });

    return keys.map((k) => AttendanceData(k, byDate[k]!)).toList();
  }
}