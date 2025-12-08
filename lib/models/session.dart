enum SessionStatus { scheduled, active, closed, cancelled }

class Session {
  final String id;
  final String subject;
  final String section;
  DateTime startAt;
  DateTime? endAt;
  SessionStatus status;
  int scanned;
  // studentId -> present
  final Map<String, bool> attendance;

  Session({
    required this.id,
    required this.subject,
    required this.section,
    required this.startAt,
    this.endAt,
    this.status = SessionStatus.active,
    this.scanned = 0,
    Map<String, bool>? attendance,
  }) : attendance = attendance ?? {};
}