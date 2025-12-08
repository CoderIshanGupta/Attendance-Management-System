import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile.dart';
import 'profile_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProfileStore.I;

    return ValueListenableBuilder<Profile>(
      valueListenable: store.profile,
      builder: (context, p, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Get.to(() => const EditProfileScreen()),
                tooltip: 'Edit profile',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
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
                      backgroundImage: AssetImage(p.avatar),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${p.designation} • ${p.branch}', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 4),
                          Text(p.email, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Name'),
                      subtitle: Text(p.name),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Designation'),
                      subtitle: Text(p.designation),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.account_tree_outlined),
                      title: const Text('Branch'),
                      subtitle: Text(p.branch),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(p.email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Phone'),
                      subtitle: Text(p.phone),
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