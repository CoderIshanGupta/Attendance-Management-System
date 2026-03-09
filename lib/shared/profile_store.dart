import 'package:flutter/foundation.dart';

class Profile {
  String name;
  String email;
  String phone;
  String branch;
  String designation;
  String avatar; // asset path or URL

  Profile({
    required this.name,
    required this.email,
    required this.phone,
    required this.branch,
    required this.designation,
    required this.avatar,
  });

  Profile copyWith({
    String? name,
    String? email,
    String? phone,
    String? branch,
    String? designation,
    String? avatar,
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      branch: branch ?? this.branch,
      designation: designation ?? this.designation,
      avatar: avatar ?? this.avatar,
    );
  }
}

class ProfileStore {
  ProfileStore._();
  static final ProfileStore I = ProfileStore._();

  final ValueNotifier<Profile> profile = ValueNotifier<Profile>(
    Profile(
      name: 'Prof. Ishan Gupta',
      email: 'ishan.gupta@example.edu',
      phone: '+91-9876543210',
      branch: 'CSE',
      designation: 'Assistant Professor',
      avatar: 'assets/images/imeg.jpg',
    ),
  );

  void update(Profile p) => profile.value = p;
}