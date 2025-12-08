import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final store = ProfileStore.I;
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _branch;
  late final TextEditingController _designation;

  @override
  void initState() {
    super.initState();
    final p = store.profile.value;
    _name = TextEditingController(text: p.name);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _branch = TextEditingController(text: p.branch);
    _designation = TextEditingController(text: p.designation);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _branch.dispose();
    _designation.dispose();
    super.dispose();
  }

  void _save() {
    final p = store.profile.value.copyWith(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      branch: _branch.text.trim(),
      designation: _designation.text.trim(),
    );
    store.update(p);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Get.back();
  }

  Widget _field(String label, TextEditingController c, IconData icon, {TextInputType? type}) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Name', _name, Icons.person_outline),
          const SizedBox(height: 12),
          _field('Designation', _designation, Icons.badge_outlined),
          const SizedBox(height: 12),
          _field('Branch', _branch, Icons.account_tree_outlined),
          const SizedBox(height: 12),
          _field('Email', _email, Icons.email_outlined, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field('Phone', _phone, Icons.phone_outlined, type: TextInputType.phone),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}