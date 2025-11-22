import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../mock/store.dart';
import '../models/session.dart';
import '../shared/attendance_chart.dart';
import '../models/attendance_data.dart';
import 'teacher_drawer.dart';
import 'student_stats.dart';

enum DateView { range, day }
enum DateQuick { last7, last30 }

class SectionStatsScreen extends StatefulWidget {
  const SectionStatsScreen({super.key});

  @override
  State<SectionStatsScreen> createState() => _SectionStatsScreenState();
}

class _SectionStatsScreenState extends State<SectionStatsScreen> {
  final store = DataStore.I;

  String? year;
  String? branch;
  String? subject;
  String? section;

  DateView view = DateView.range;
  DateTimeRange? range;
  DateTime? day;

  late final VoidCallback _storeListener;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    range = DateTimeRange(
      start: DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6)),
      end: DateTime(today.year, today.month, today.day),
    );
    day = DateTime(today.year, today.month, today.day);
    _storeListener = () => mounted ? setState(() {}) : null;
    store.tick.addListener(_storeListener);
  }

  @override
  void dispose() {
    store.tick.removeListener(_storeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yearOptions = store.years();
    final branchOptions = year == null ? <String>[] : store.branchesForYear(year!);
    final subjectOptions = (year == null || branch == null) ? <String>[] : store.subjectsFor(year!, branch!);
    final sectionOptions = (year == null || branch == null || subject == null)
        ? <String>[]
        : store.sectionsFor(year!, branch!, subject!);

    final canQuery = subject != null && section != null && (view == DateView.range ? range != null : day != null);

    final List<Session> sessions;
    if (!canQuery) {
      sessions = const [];
    } else {
      if (view == DateView.range) {
        sessions = store.sessionsForRange(subject!, section!, range!.start, range!.end);
      } else {
        sessions = store.sessionsForDate(subject!, section!, day!);
      }
    }

    final roster = section == null ? <Student>[] : store.roster(section!);
    final rosterSize = roster.length;

    final daily = _aggregateDailyPresents(sessions);
    final totalPresents = sessions.fold<int>(0, (p, s) => p + _presentCount(s));
    final totalSlots = sessions.length * (rosterSize == 0 ? 1 : rosterSize);
    final attendancePct = totalSlots == 0 ? 0.0 : (totalPresents / totalSlots) * 100.0;

    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

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
        title: const Text('Stats & Reports'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: sessions.isEmpty ? null : () => _exportCsv(sessions, roster),
          ),
        ],
      ),
      drawer: const TeacherDrawer(currentTab: 2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentMax = 1000.0;
          final basePad = 16.0;
          final extra =
              constraints.maxWidth > contentMax ? (constraints.maxWidth - contentMax) / 2 : 0;
          final hPad = basePad + extra;

          return ListView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, bottomInset),
            children: [
              // Selectors
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: year,
                      items: yearOptions.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      decoration: const InputDecoration(labelText: 'Year', prefixIcon: Icon(Icons.calendar_month)),
                      onChanged: (v) => setState(() {
                        year = v; branch = null; subject = null; section = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: branch,
                      items: branchOptions.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      decoration: const InputDecoration(labelText: 'Branch', prefixIcon: Icon(Icons.account_tree_outlined)),
                      onChanged: (v) => setState(() {
                        branch = v; subject = null; section = null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: subject,
                      items: subjectOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.menu_book_outlined)),
                      onChanged: (v) => setState(() {
                        subject = v; section = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: section,
                      items: sectionOptions.map((sec) => DropdownMenuItem(value: sec, child: Text(sec))).toList(),
                      decoration: const InputDecoration(labelText: 'Section', prefixIcon: Icon(Icons.group_outlined)),
                      onChanged: (v) => setState(() => section = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date view + pickers (responsive Wrap)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<DateView>(
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: const [
                      ButtonSegment(value: DateView.range, label: Text('Range')),
                      ButtonSegment(value: DateView.day, label: Text('Day')),
                    ],
                    selected: {view},
                    onSelectionChanged: (sel) {
                      if (sel.isNotEmpty) setState(() => view = sel.first);
                    },
                  ),
                  if (view == DateView.range) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_rangeLabel()),
                      onPressed: () async {
                        final today = DateTime.now();
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(today.year - 1, 1, 1),
                          lastDate: DateTime(today.year + 1, 12, 31),
                          initialDateRange: range,
                        );
                        if (picked != null) setState(() => range = picked);
                      },
                    ),
                    SegmentedButton<DateQuick>(
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: const [
                        ButtonSegment(value: DateQuick.last7, label: Text('Last 7')),
                        ButtonSegment(value: DateQuick.last30, label: Text('Last 30')),
                      ],
                      selected: <DateQuick>{_currentQuick()},
                      onSelectionChanged: (sel) {
                        if (sel.isEmpty) return;
                        setState(() => range = _quickRange(sel.first));
                      },
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(_dayLabel()),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: day ?? DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 1, 1, 1),
                          lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                        );
                        if (picked != null) {
                          setState(() => day = DateTime(picked.year, picked.month, picked.day));
                        }
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Summary
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summaryCard('Sessions', sessions.length.toString(), Icons.event_note_outlined, Colors.indigo),
                  _summaryCard('Roster', rosterSize.toString(), Icons.groups_outlined, Colors.teal),
                  _summaryCard('Presents', totalPresents.toString(), Icons.task_alt_outlined, Colors.orange),
                  _summaryCard('Attendance %', '${attendancePct.toStringAsFixed(1)}%', Icons.insights_outlined, Colors.purple),
                ],
              ),
              const SizedBox(height: 16),

              // Chart
              SizedBox(
                height: 240,
                child: Card(
                  elevation: 2,
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

              if (canQuery) ...[
                Text('Students (${roster.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                _StudentsTable(
                  subject: subject!,
                  section: section!,
                  roster: roster,
                  sessions: sessions,
                  onTapStudent: (st) {
                    Get.to(() => StudentStatsScreen(
                          subject: subject!,
                          section: section!,
                          student: st,
                          sessions: sessions,
                          from: view == DateView.range ? range!.start : day!,
                          to: view == DateView.range ? range!.end : day!,
                        ));
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCsv(List<Session> sessions, List<Student> roster) async {
    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to export')));
      return;
    }

    final List<String> lines = ['Date,Subject,Section,Roll,Name,Status'];

    for (final s in sessions) {
      final dateStr =
          '${s.startAt.year}-${s.startAt.month.toString().padLeft(2, '0')}-${s.startAt.day.toString().padLeft(2, '0')}'
          ' ${s.startAt.hour.toString().padLeft(2, '0')}:${s.startAt.minute.toString().padLeft(2, '0')}';
      for (final st in roster) {
        final present = s.attendance[st.id] == true;
        final status = present ? 'Present' : 'Absent';
        lines.add('$dateStr,${_csvEscape(s.subject)},${_csvEscape(s.section)},${_csvEscape(st.roll)},${_csvEscape(st.name)},$status');
      }
    }

    final csv = lines.join('\n');

    try {
      if (kIsWeb) {
        await Share.share(csv, subject: 'Attendance CSV');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
        await Share.shareXFiles([XFile(file.path)], text: 'Attendance CSV');
      }
    } catch (e) {
      await Share.share(csv, subject: 'Attendance CSV');
    }
  }

  String _csvEscape(String v) {
    final needsQuotes = v.contains(',') || v.contains('"') || v.contains('\n');
    var out = v.replaceAll('"', '""');
    return needsQuotes ? '"$out"' : out;
  }

  String _rangeLabel() {
    if (range == null) return 'Select range';
    String fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    return '${fmt(range!.start)} - ${fmt(range!.end)}';
  }

  String _dayLabel() {
    if (day == null) return 'Select day';
    return '${day!.day.toString().padLeft(2, '0')}/${day!.month.toString().padLeft(2, '0')}/${day!.year}';
  }

  DateQuick _currentQuick() {
    if (range == null) return DateQuick.last7;
    final last7 = _quickRange(DateQuick.last7);
    final last30 = _quickRange(DateQuick.last30);
    if (range!.start == last7.start && range!.end == last7.end) return DateQuick.last7;
    if (range!.start == last30.start && range!.end == last30.end) return DateQuick.last30;
    return DateQuick.last7;
  }

  DateTimeRange _quickRange(DateQuick quick) {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    if (quick == DateQuick.last7) {
      return DateTimeRange(start: end.subtract(const Duration(days: 6)), end: end);
    } else {
      return DateTimeRange(start: end.subtract(const Duration(days: 29)), end: end);
    }
  }

  int _presentCount(Session s) => s.attendance.values.where((v) => v == true).length;

  List<AttendanceData> _aggregateDailyPresents(List<Session> sessions) {
    final Map<String, int> byDate = {};
    String key(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    for (final s in sessions) {
      final k = key(DateTime(s.startAt.year, s.startAt.month, s.startAt.day));
      byDate.update(k, (val) => val + _presentCount(s), ifAbsent: () => _presentCount(s));
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

Widget _summaryCard(String label, String value, IconData icon, Color color) {
  return SizedBox(
    width: 170,
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          ],
        ),
      ),
    ),
  );
}

class _StudentsTable extends StatelessWidget {
  final String subject;
  final String section;
  final List<Student> roster;
  final List<Session> sessions;
  final void Function(Student) onTapStudent;

  const _StudentsTable({
    required this.subject,
    required this.section,
    required this.roster,
    required this.sessions,
    required this.onTapStudent,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = { for (final st in roster) st.id: 0 };
    for (final s in sessions) {
      for (final st in roster) {
        if (s.attendance[st.id] == true) {
          counts[st.id] = (counts[st.id] ?? 0) + 1;
        }
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: roster.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final st = roster[i];
          final present = counts[st.id] ?? 0;
          return ListTile(
            title: Text('${st.roll} • ${st.name}'),
            subtitle: Text('Presents: $present'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTapStudent(st),
          );
        },
      ),
    );
  }
}