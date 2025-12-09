import 'package:flutter/material.dart';
import '../shared/current_student_store.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CurrentStudentStore.I;

    return ValueListenableBuilder<CurrentStudent>(
      valueListenable: store.student,
      builder: (context, s, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll: ${s.roll}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${s.program} • ${s.semester}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Section: ${s.section}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Name'),
                      subtitle: Text(s.name),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.confirmation_number_outlined),
                      title: const Text('Roll Number'),
                      subtitle: Text(s.roll),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Program'),
                      subtitle: Text(s.program),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.layers_outlined),
                      title: const Text('Semester'),
                      subtitle: Text(s.semester),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('Section'),
                      subtitle: Text(s.section),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}