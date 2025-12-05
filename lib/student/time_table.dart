import 'package:flutter/material.dart';
import '../mock/store.dart';
import '../student/student_att_ctrl.dart';

class StudentTimeTableScreen extends StatefulWidget {
  const StudentTimeTableScreen({super.key});

  @override
  State<StudentTimeTableScreen> createState() => _StudentTimeTableScreenState();
}

class _StudentTimeTableScreenState extends State<StudentTimeTableScreen> {
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
    final slots = att.todaySlotsForStudent();
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Time Table'),
      ),
      body: slots.isEmpty
          ? ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.event_busy_outlined, size: 72, color: Colors.grey),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No classes scheduled',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text(
                    'Once your timetable is configured, classes will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = slots[i];
                final time =
                    '${_hhmm(s.start)} - ${_hhmm(s.end)}';

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(s.subject),
                    subtitle: Text(time),
                  ),
                );
              },
            ),
    );
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}