import 'package:flutter/material.dart';
import '../mock/store.dart';
import 'student_att_ctrl.dart';

class StudentAlertsScreen extends StatefulWidget {
  const StudentAlertsScreen({super.key});

  @override
  State<StudentAlertsScreen> createState() => _StudentAlertsScreenState();
}

class _StudentAlertsScreenState extends State<StudentAlertsScreen> {
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
    final alerts = att.buildAlerts();
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: alerts.isEmpty
          ? ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.notifications_off_outlined,
                    size: 72, color: Colors.grey),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No alerts yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text(
                    'Your attendance updates will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = alerts[i];
                final iconColor = a.present ? Colors.green : Colors.redAccent;
                final iconData =
                    a.present ? Icons.check_circle_outline : Icons.error_outline;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.15),
                      child: Icon(iconData, color: iconColor),
                    ),
                    title: Text(a.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(a.body),
                    trailing: Text(
                      _ago(a.time),
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}