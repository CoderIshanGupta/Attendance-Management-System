import 'package:flutter/material.dart';
import '../mock/store.dart';
import 'student_att_ctrl.dart';
import 'subject_detail.dart';

class StudentSubjectsScreen extends StatefulWidget {
  const StudentSubjectsScreen({super.key});

  @override
  State<StudentSubjectsScreen> createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<StudentSubjectsScreen> {
  final store = DataStore.I;
  final att = StudentAttController.I;
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
    final summaries = att.subjectSummaries();
    final subjects = summaries.keys.toList()..sort();
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
      ),
      body: subjects.isEmpty
          ? ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No subjects found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text(
                    'Once your timetable is configured, your subjects appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final subject = subjects[i];
                final summary = summaries[subject]!;
                final pct = summary.percentage;
                final pctStr = '${pct.toStringAsFixed(1)}%';
                final color = pct >= 75
                    ? Colors.green
                    : (pct >= 50 ? Colors.orange : Colors.redAccent);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.15),
                      child: const Icon(Icons.menu_book_outlined, color: Colors.blue),
                    ),
                    title: Text(subject),
                    subtitle: Text(
                      'Teacher: ${store.teacherName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pctStr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          '${summary.presents}/${summary.totalSessions}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailScreen(subject: subject),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}