import 'package:flutter/material.dart';
import 'settings_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  ThemeMode _toThemeMode(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Settings>(
      valueListenable: SettingsStore.I.settings,
      builder: (context, s, _) {
        final mq = MediaQuery.of(context);
        final bottomInset = mq.viewPadding.bottom + kBottomNavigationBarHeight + 16;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final contentMax = 900.0;
              final basePad = 16.0;
              final extra =
                  constraints.maxWidth > contentMax ? (constraints.maxWidth - contentMax) / 2 : 0;
              final hPad = basePad + extra;

              return ListView(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, bottomInset),
                children: [
                  const _SectionHeader('Appearance'),
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(_themeLabel(s.themeMode)),
                    trailing: SegmentedButton<AppThemeMode>(
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: const [
                        ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                        ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: {s.themeMode},
                      onSelectionChanged: (sel) {
                        if (sel.isEmpty) return;
                        SettingsStore.I.update(s.copyWith(themeMode: sel.first));
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  const _SectionHeader('Haptics'),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_outlined),
                    title: const Text('Haptics'),
                    value: s.haptics,
                    onChanged: (v) => SettingsStore.I.update(s.copyWith(haptics: v)),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.check_circle_outline),
                    title: const Text('Haptic on successful scan'),
                    value: s.scanHaptic,
                    onChanged: s.haptics ? (v) => SettingsStore.I.update(s.copyWith(scanHaptic: v)) : null,
                  ),
                  const Divider(height: 1),

                  const _SectionHeader('Attendance UI'),
                  SwitchListTile(
                    secondary: const Icon(Icons.info_outline),
                    title: const Text('Show edit-window banner'),
                    value: s.showEditBanner,
                    onChanged: (v) => SettingsStore.I.update(s.copyWith(showEditBanner: v)),
                  ),
                  const Divider(height: 1),

                  const _SectionHeader('Notifications'),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Enable notifications'),
                    value: s.notificationsEnabled,
                    onChanged: (v) => SettingsStore.I.update(s.copyWith(notificationsEnabled: v)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _themeLabel(AppThemeMode m) {
    switch (m) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black54)),
    );
  }
}