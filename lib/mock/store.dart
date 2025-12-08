import 'dart:math';
import 'package:flutter/foundation.dart'; // for ValueNotifier
import '../models/session.dart';

class Student {
  final String id;
  final String roll;
  final String name;
  Student({required this.id, required this.roll, required this.name});
}

// Simple daily class slot for today's schedule (used for "Next up")
class ClassSlot {
  final String subject;
  final String section;
  final DateTime start;
  final DateTime end;
  ClassSlot({
    required this.subject,
    required this.section,
    required this.start,
    required this.end,
  });
}

class DataStore {
  DataStore._();
  static final DataStore I = DataStore._();
  final _rand = Random();

  // Emits a tick whenever data changes (sessions/attendance)
  final ValueNotifier<int> tick = ValueNotifier<int>(0);
  void _notify() => tick.value++;

  // Faculty name (mock)
  String teacherName = 'Prof. Ishan Gupta';

  // Hierarchical assignments: Year -> Branch -> Subject -> Sections
  final Map<String, Map<String, Map<String, List<String>>>> assignmentsTree = {
    '3rd Year': {
      'CSE': {
        'Data Structures (CSE 3rd Yr)': ['CSE-01', 'CSE-02', 'CSE-03'],
      },
      'IT': {
        'Operating Systems (IT 3rd Yr)': ['IT-01', 'IT-02'],
      },
    },
    '2nd Year': {
      'CSSE': {
        'Discrete Math (CSSE 2nd Yr)': ['CSSE-01'],
      },
    },
  };

  // Flat assignments used across the app
  final Map<String, List<String>> assignments = {
    'Data Structures (CSE 3rd Yr)': ['CSE-01', 'CSE-02', 'CSE-03'],
    'Operating Systems (IT 3rd Yr)': ['IT-01', 'IT-02'],
    'Discrete Math (CSSE 2nd Yr)': ['CSSE-01'],
  };

  // Roster cache by section
  final Map<String, List<Student>> rosterBySection = {};

  // Sessions grouped by subject|section
  final Map<String, List<Session>> _sessionsByKey = {};

  // “Today” schedule cache (for Next up)
  DateTime? _scheduleKey;
  List<ClassSlot> _todaySlots = [];

  String _key(String subject, String section) => '$subject|$section';

  // Hierarchy helpers
  List<String> years() => assignmentsTree.keys.toList();
  List<String> branchesForYear(String year) => assignmentsTree[year]?.keys.toList() ?? <String>[];
  List<String> subjectsFor(String year, String branch) =>
      assignmentsTree[year]?[branch]?.keys.toList() ?? <String>[];
  List<String> sectionsFor(String year, String branch, String subject) =>
      assignmentsTree[year]?[branch]?[subject] ?? assignments[subject] ?? <String>[];

  // Roster init
  List<Student> _ensureRoster(String section) {
    if (!rosterBySection.containsKey(section)) {
      final List<Student> students = List.generate(30, (i) {
        final idx = i + 1;
        final roll = 'R${idx.toString().padLeft(3, '0')}';
        return Student(id: 'S$section$roll', roll: roll, name: 'Student $idx');
      });
      rosterBySection[section] = students;
    }
    return rosterBySection[section]!;
  }

  List<Session> _listSessions(String subject, String section) {
    final k = _key(subject, section);
    return _sessionsByKey.putIfAbsent(k, () => []);
  }

  Session? getActiveSession(String subject, String section) {
    final list = _listSessions(subject, section);
    for (final s in list) {
      if (s.status == SessionStatus.active) return s;
    }
    return null;
  }

  Session? getLatestSession(String subject, String section) {
    final list = _listSessions(subject, section);
    if (list.isEmpty) return null;
    list.sort((a, b) => b.startAt.compareTo(a.startAt));
    return list.first;
  }

  Session startOrResumeSession(String subject, String section) {
    final active = getActiveSession(subject, section);
    if (active != null) {
      // Resuming an already active session (no data change), no notify.
      return active;
    }

    final roster = _ensureRoster(section);
    final id = 'sess_${DateTime.now().millisecondsSinceEpoch}_${_rand.nextInt(99999)}';
    final session = Session(
      id: id,
      subject: subject,
      section: section,
      startAt: DateTime.now(),
      status: SessionStatus.active,
      scanned: 0,
      attendance: {for (final st in roster) st.id: false},
    );
    _listSessions(subject, section).add(session);
    _notify(); // new session started -> update listeners
    return session;
  }

  void stopSession(String sessionId) {
    final s = _findSessionById(sessionId);
    if (s == null) return;
    if (s.status == SessionStatus.active) {
      s.status = SessionStatus.closed;
      s.endAt = DateTime.now();
      _notify(); // session closed -> update listeners
    }
  }

  Session? _findSessionById(String sessionId) {
    for (final list in _sessionsByKey.values) {
      for (final s in list) {
        if (s.id == sessionId) return s;
      }
    }
    return null;
  }

  // Optional helper for direct lookup by id
  Session? sessionById(String sessionId) => _findSessionById(sessionId);

  int scannedCount(String sessionId) => _findSessionById(sessionId)?.scanned ?? 0;

  // Simulate a scan: increment count and mark next absent student present
  void simulateScan(String sessionId) {
    final s = _findSessionById(sessionId);
    if (s == null) return;
    s.scanned++;
    final roster = _ensureRoster(s.section);
    for (final st in roster) {
      if (s.attendance[st.id] == false) {
        s.attendance[st.id] = true;
        break;
      }
    }
    _notify(); // scanned/presents changed -> update listeners
  }

  List<Student> roster(String section) => _ensureRoster(section);

  // Find a student in a section by roll number
  Student? findStudentByRoll(String section, String roll) {
    final list = _ensureRoster(section);
    for (final st in list) {
      if (st.roll == roll) return st;
    }
    return null;
  }

  bool isOverrideLocked(String sessionId) {
    final s = _findSessionById(sessionId);
    if (s == null) return false;
    if (s.status != SessionStatus.closed) return false;
    if (s.endAt == null) return false;
    return DateTime.now().isAfter(s.endAt!.add(const Duration(hours: 24)));
  }

  bool setPresent(String sessionId, String studentId, bool present) {
    final s = _findSessionById(sessionId);
    if (s == null) return false;
    if (isOverrideLocked(sessionId)) return false;
    s.attendance[studentId] = present;
    _notify(); // attendance changed -> update listeners
    return true;
  }

  bool? isPresent(String sessionId, String studentId) {
    final s = _findSessionById(sessionId);
    if (s == null) return null;
    return s.attendance[studentId];
  }

  // Student QR-based marking by roll number
  MarkResult markAttendanceByRoll(String sessionId, String roll) {
    final s = _findSessionById(sessionId);
    if (s == null) return MarkResult.sessionNotFound;
    if (s.status != SessionStatus.active) return MarkResult.sessionNotActive;

    final roster = _ensureRoster(s.section);
    Student? student;
    for (final st in roster) {
      if (st.roll == roll) {
        student = st;
        break;
      }
    }
    if (student == null) return MarkResult.studentNotInSection;

    final alreadyPresent = s.attendance[student.id] == true;
    if (alreadyPresent) return MarkResult.alreadyMarked;

    s.attendance[student.id] = true;
    s.scanned++;
    _notify();
    return MarkResult.success;
  }

  // Quick stats
  int assignmentsCount() => assignments.length;
  int sectionsCount() => assignments.values.fold(0, (p, list) => p + list.length);

  // Today schedule (for Next up) — generate a slot for every assignment pair
  void _ensureTodaySchedule() {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    if (_scheduleKey == todayKey && _todaySlots.isNotEmpty) return;

    _scheduleKey = todayKey;
    _todaySlots = [];

    // Flatten all (subject, section) pairs
    final pairs = <MapEntry<String, String>>[];
    assignments.forEach((subject, sections) {
      for (final sec in sections) {
        pairs.add(MapEntry(subject, sec));
      }
    });

    // Start at 9:00, each slot is 50 minutes + 10-minute gap (1 hour step)
    final startHour = 9;
    for (int i = 0; i < pairs.length; i++) {
      final start =
          DateTime(now.year, now.month, now.day, startHour, 0).add(Duration(minutes: i * 60));
      final end = start.add(const Duration(minutes: 50));
      final pair = pairs[i];
      _todaySlots.add(ClassSlot(
        subject: pair.key,
        section: pair.value,
        start: start,
        end: end,
      ));
    }

    _todaySlots.sort((a, b) => a.start.compareTo(b.start));
  }

  List<ClassSlot> todaySlots() {
    _ensureTodaySchedule();
    return List.unmodifiable(_todaySlots);
  }

  // Next up: the next not-done slot, preferring those starting after "now"
  ClassSlot? nextClassDynamic() {
    _ensureTodaySchedule();
    final now = DateTime.now();

    bool slotDone(ClassSlot slot) {
      final todaySessions = sessionsForDate(slot.subject, slot.section, slot.start);
      return todaySessions.any(
          (s) => s.status == SessionStatus.active || s.status == SessionStatus.closed);
    }

    final undone = _todaySlots.where((s) => !slotDone(s)).toList();
    if (undone.isEmpty) return null;

    final upcoming = undone.where((s) => !s.start.isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    if (upcoming.isNotEmpty) return upcoming.first;

    undone.sort((a, b) => a.start.compareTo(b.start));
    return undone.first;
  }

  // Total classes planned today (sum of sections across all assigned subjects)
  int totalPlannedToday() {
    int total = 0;
    assignments.forEach((_, sections) {
      total += sections.length;
    });
    return total;
  }

  // Remaining classes based on assignments and today's started/closed sessions
  int classesLeftTodayDynamic() {
    final today = DateTime.now();
    int done = 0;

    assignments.forEach((subject, sections) {
      for (final sec in sections) {
        final sessionsToday = sessionsForDate(subject, sec, today);
        final isDone =
            sessionsToday.any((s) => s.status == SessionStatus.active || s.status == SessionStatus.closed);
        if (isDone) done++;
      }
    });

    final total = totalPlannedToday();
    final left = total - done;
    return left < 0 ? 0 : left;
  }

  // Sessions APIs for stats
  List<Session> sessionsFor(String subject, String section) {
    final k = _key(subject, section);
    return List<Session>.from(_sessionsByKey[k] ?? const []);
  }

  List<Session> sessionsForRange(
    String subject,
    String section,
    DateTime from,
    DateTime to,
  ) {
    final all = sessionsFor(subject, section);
    final list = all.where((s) {
      return !s.startAt.isBefore(from) && !s.startAt.isAfter(to);
    }).toList();
    list.sort((a, b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  List<Session> sessionsForDate(String subject, String section, DateTime date) {
    final all = sessionsFor(subject, section);
    final ymd = DateTime(date.year, date.month, date.day);
    return all.where((s) {
      final d = DateTime(s.startAt.year, s.startAt.month, s.startAt.day);
      return d == ymd;
    }).toList();
  }
}

// Result of attempting to mark attendance for a session by roll number
enum MarkResult {
  success,
  alreadyMarked,
  sessionNotFound,
  sessionNotActive,
  studentNotInSection,
}