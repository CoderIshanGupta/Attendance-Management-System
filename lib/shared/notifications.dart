import 'dart:async';
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  bool read;
  final DateTime time;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.time,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    _items = List.generate(
      8,
      (i) => NotificationItem(
        id: 'n$i',
        title: i.isEven ? 'Session reminder' : 'Attendance report ready',
        body: i.isEven
            ? 'Your class starts soon. Tap to open details.'
            : 'The report for today has been generated.',
        read: i % 3 == 0,
        time: DateTime.now().subtract(Duration(minutes: i * 7)),
      ),
    );
    setState(() => _loading = false);
  }

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.read = true;
      }
    });
  }

  void _clearAll() {
    setState(() => _items.clear());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(onPressed: _markAllRead, icon: const Icon(Icons.done_all), tooltip: 'Mark all read'),
          IconButton(onPressed: _clearAll, icon: const Icon(Icons.clear_all), tooltip: 'Clear all'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final contentMax = 900.0;
                final basePad = 16.0;
                final extra =
                    constraints.maxWidth > contentMax ? (constraints.maxWidth - contentMax) / 2 : 0;
                final hPad = basePad + extra;

                if (_items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomInset),
                    children: const [
                      SizedBox(height: 120),
                      Icon(Icons.notifications_off_outlined, size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Center(
                        child: Text('No alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 6),
                      Center(child: Text('You’re all caught up!', style: TextStyle(color: Colors.black54))),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomInset),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = _items[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    (n.read ? Colors.grey : Colors.orange).withOpacity(0.15),
                                child: Icon(
                                  n.read ? Icons.notifications_none : Icons.notifications_active,
                                  color: n.read ? Colors.grey : Colors.orange,
                                ),
                              ),
                              if (!n.read)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Colors.red, shape: BoxShape.circle),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(n.body),
                          trailing: Text(_ago(n.time), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          onTap: () => setState(() => n.read = true),
                        ),
                      );
                    },
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