import 'package:flutter/material.dart';
import '../mock/store.dart';
import '../models/session.dart';

class StudentStatsScreen extends StatelessWidget {
  final String subject;
  final String section;
  final Student student;
  final List<Session> sessions;
  final DateTime from;
  final DateTime to;

  const StudentStatsScreen({
    super.key,
    required this.subject,
    required this.section,
    required this.student,
    required this.sessions,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = sessions.where((s) =>
      !s.startAt.isBefore(from) && !s.startAt.isAfter(to)
    ).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    final total = filtered.length;
    final presents = filtered.where((s) => s.attendance[student.id] == true).length;
    final pct = total == 0 ? 0.0 : (presents / total) * 100.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${student.roll} — ${student.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                        Text('Section: $section'),
                        Text('Subject: $subject', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text('${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Sessions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Text('No sessions in the selected range.')
          else
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = filtered[i];
                  final present = s.attendance[student.id] == true;
                  final d = s.startAt;
                  final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
                  return ListTile(
                    title: Text('$date  •  ${s.subject}'),
                    subtitle: Text('Section: ${s.section}'),
                    trailing: Chip(
                      label: Text(present ? 'Present' : 'Absent',
                        style: const TextStyle(color: Colors.white)),
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
}