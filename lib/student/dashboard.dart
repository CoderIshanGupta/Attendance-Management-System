import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../mock/store.dart';
import '../utils/toast.dart';
import 'scan_qr.dart';
import 'student_att_ctrl.dart';
import '../shared/current_student_store.dart';
import 'package:flutter/foundation.dart';
import 'student_drawer.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final store = DataStore.I;
  final att = StudentAttController.I;
  late final VoidCallback _tickListener;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tickListener = () => mounted ? setState(() {}) : null;
    store.tick.addListener(_tickListener);

    // Real-time refresh every 5 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    store.tick.removeListener(_tickListener);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    await Get.to(() => ScanQrScreen(onScan: att.handleQrScan));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final today = DateTime.now();
    final dateStr =
        '${_weekday(today.weekday)}, ${today.day}/${today.month}/${today.year}';

    final current = CurrentStudentStore.I.student.value;
    final overallPct = att.overallPercentage();
    final nextClass = att.nextClassForStudent();
    final todaySlots = att.todaySlotsForStudent();

    final isDefaulter = overallPct < 75;

    return Scaffold(
      // ← THIS IS THE MISSING PART
      drawer: const StudentDrawer(currentTab: 0),

      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: const Text('Attendance'),
        actions: [
          // Dev-only: Mark all present (hidden in release mode)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.auto_fix_high, color: Colors.amber),
              tooltip: 'Dev: Mark all present',
              onPressed: () {
                final st = store.findStudentByRoll(current.section, current.roll);
                if (st != null) {
                  store.assignments.forEach((subject, sections) {
                    if (sections.contains(current.section)) {
                      final sessions =
                          store.sessionsFor(subject, current.section);
                      for (final s in sessions) {
                        if (s.attendance[st.id] == false) {
                          s.attendance[st.id] = true;
                          s.scanned++;
                        }
                      }
                    }
                  });
                  store.tick.value++;
                  showAppToast('All attendance marked present! (Dev)');
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            // Welcome Header
            _WelcomeHeader(
              dateStr: dateStr,
              name: current.name,
              roll: current.roll,
              program: current.program,
              semester: current.semester,
            ),
            const SizedBox(height: 16),

            // Defaulter Warning
            if (isDefaulter)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Defaulter Alert: Your attendance is below 75%!\nImprove it soon.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Overall Attendance with Circular Progress
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Overall Attendance',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: overallPct / 100,
                              strokeWidth: 14,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                isDefaulter
                                    ? Colors.redAccent
                                    : Colors.green,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${overallPct.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: isDefaulter
                                      ? Colors.redAccent
                                      : Colors.green,
                                ),
                              ),
                              Text(
                                isDefaulter ? 'Work harder!' : 'Excellent!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDefaulter
                                      ? Colors.redAccent
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Next Class
            if (nextClass != null) ...[
              _NextClassCard(slot: nextClass),
              const SizedBox(height: 16),
            ],

            // Today's Classes
            if (todaySlots.isNotEmpty) ...[
              Text('Today\'s Classes',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...todaySlots.map((s) => _TodayClassTile(slot: s)),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No classes scheduled for today',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Mark Attendance Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text(
                  'Mark Attendance Now',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(int i) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[i - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Widgets
class _WelcomeHeader extends StatelessWidget {
  final String dateStr;
  final String name;
  final String roll;
  final String program;
  final String semester;

  const _WelcomeHeader({
    required this.dateStr,
    required this.name,
    required this.roll,
    required this.program,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ],
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
            child:
                const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text('Welcome',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14)),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Roll: $roll',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12)),
                Text('$program • $semester',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(dateStr,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextClassCard extends StatelessWidget {
  final ClassSlot slot;
  const _NextClassCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final time =
        '${_hhmm(slot.start)} - ${_hhmm(slot.end)}';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Colors.blue.withOpacity(0.15),
              child:
                  const Icon(Icons.schedule, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text('Next Class',
                      style:
                          TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(slot.subject,
                      style: const TextStyle(fontSize: 16)),
                  Text('Section: ${slot.section}',
                      style: const TextStyle(
                          color: Colors.black54)),
                ],
              ),
            ),
            Text(time,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _TodayClassTile extends StatelessWidget {
  final ClassSlot slot;
  const _TodayClassTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final time =
        '${_hhmm(slot.start)} - ${_hhmm(slot.end)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(slot.subject),
        subtitle: Text(time),
        trailing: Text('Section ${slot.section}',
            style: const TextStyle(
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}