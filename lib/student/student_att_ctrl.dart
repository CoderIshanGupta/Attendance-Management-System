import 'package:flutter/services.dart';
import '../mock/store.dart';
import '../shared/current_student_store.dart';
import '../models/session.dart';
import '../shared/settings_store.dart';
import '../utils/toast.dart';

class SubjectAttendanceSummary {
  final String subject;
  final int totalSessions;
  final int presents;

  SubjectAttendanceSummary({
    required this.subject,
    required this.totalSessions,
    required this.presents,
  });

  double get percentage =>
      totalSessions == 0 ? 0.0 : (presents / totalSessions) * 100.0;
}

class StudentAlertItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool present;

  StudentAlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.present,
  });
}

class StudentAttController {
  StudentAttController._();
  static final StudentAttController I = StudentAttController._();

  final DataStore store = DataStore.I;

  CurrentStudent get current => CurrentStudentStore.I.student.value;

  Student? get studentModel =>
      store.findStudentByRoll(current.section, current.roll);

  // Overall percentage across all subjects for current.section
  double overallPercentage() {
    final st = studentModel;
    if (st == null) return 0.0;

    final sec = current.section;
    int total = 0;
    int presents = 0;

    store.assignments.forEach((subject, sections) {
      if (!sections.contains(sec)) return;
      final sessions = store.sessionsFor(subject, sec);
      total += sessions.length;
      for (final s in sessions) {
        if (s.attendance[st.id] == true) presents++;
      }
    });

    if (total == 0) return 0.0;
    return (presents / total) * 100.0;
  }

  // Per-subject summaries for the student's section
  Map<String, SubjectAttendanceSummary> subjectSummaries() {
    final st = studentModel;
    if (st == null) return {};
    final sec = current.section;

    final Map<String, SubjectAttendanceSummary> result = {};
    store.assignments.forEach((subject, sections) {
      if (!sections.contains(sec)) return;
      final sessions = store.sessionsFor(subject, sec);
      final total = sessions.length;
      final presents =
          sessions.where((s) => s.attendance[st.id] == true).length;
      result[subject] = SubjectAttendanceSummary(
        subject: subject,
        totalSessions: total,
        presents: presents,
      );
    });
    return result;
  }

  List<ClassSlot> todaySlotsForStudent() {
    final sec = current.section;
    return store.todaySlots().where((s) => s.section == sec).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  ClassSlot? nextClassForStudent() {
    final slots = todaySlotsForStudent();
    if (slots.isEmpty) return null;
    final now = DateTime.now();
    final upcoming = slots.where((s) => !s.end.isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<Session> sessionsForSubject(String subject) {
    return store.sessionsFor(subject, current.section);
  }

  // Build alerts from closed sessions
  List<StudentAlertItem> buildAlerts() {
    final st = studentModel;
    if (st == null) return [];
    final sec = current.section;
    final List<StudentAlertItem> items = [];

    store.assignments.forEach((subject, sections) {
      if (!sections.contains(sec)) return;
      final sessions = store.sessionsFor(subject, sec);
      for (final s in sessions) {
        if (s.status != SessionStatus.closed) continue;
        final present = s.attendance[st.id] == true;
        final d = s.startAt;
        final date =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
        final time =
            '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        final title = present ? 'Attendance marked' : 'You were absent';
        final body = '$subject — $sec on $date at $time';
        items.add(StudentAlertItem(
          id: s.id,
          title: title,
          body: body,
          time: s.startAt,
          present: present,
        ));
      }
    });

    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  /// Central handler for scanned QR payloads.
  /// Expects something like: ams://attendance?sid=...&ts=...&n=...
  void handleQrScan(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      showAppToast('Invalid QR');
      return;
    }

    final sid = uri.queryParameters['sid'];
    if (sid == null || sid.isEmpty) {
      showAppToast('Invalid QR');
      return;
    }

    final settings = SettingsStore.I.settings.value;

    void hapticSuccess() {
      if (settings.haptics && settings.scanHaptic) {
        HapticFeedback.mediumImpact();
      }
    }

    void hapticError() {
      if (settings.haptics) {
        HapticFeedback.lightImpact();
      }
    }

    final result = store.markAttendanceByRoll(sid, current.roll);

    switch (result) {
      case MarkResult.success:
        hapticSuccess();
        showAppToast('Attendance marked successfully');
        break;
      case MarkResult.alreadyMarked:
        hapticError();
        showAppToast('Attendance already marked for this class');
        break;
      case MarkResult.sessionNotFound:
      case MarkResult.sessionNotActive:
        hapticError();
        showAppToast('This class is not active or QR expired');
        break;
      case MarkResult.studentNotInSection:
        hapticError();
        showAppToast('You are not registered for this class');
        break;
    }
  }
}