import 'package:flutter/foundation.dart';

class CurrentStudent {
  final String name;
  final String roll;
  final String section;
  final String program;   // e.g. "B.Tech CSE"
  final String semester;  // e.g. "5th Semester"

  CurrentStudent({
    required this.name,
    required this.roll,
    required this.section,
    required this.program,
    required this.semester,
  });

  CurrentStudent copyWith({
    String? name,
    String? roll,
    String? section,
    String? program,
    String? semester,
  }) {
    return CurrentStudent(
      name: name ?? this.name,
      roll: roll ?? this.roll,
      section: section ?? this.section,
      program: program ?? this.program,
      semester: semester ?? this.semester,
    );
  }
}

class CurrentStudentStore {
  CurrentStudentStore._();
  static final CurrentStudentStore I = CurrentStudentStore._();

  // Dev/mock default: Student 1 from CSE-01
  final ValueNotifier<CurrentStudent> student = ValueNotifier<CurrentStudent>(
    CurrentStudent(
      name: 'Student 1',
      roll: 'R001',
      section: 'CSE-01',
      program: 'B.Tech CSE',
      semester: '5th Semester',
    ),
  );

  void update(CurrentStudent s) => student.value = s;
}