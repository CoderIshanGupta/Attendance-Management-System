import 'package:flutter/foundation.dart';

enum AppThemeMode { system, light, dark }

class Settings {
  AppThemeMode themeMode;
  bool haptics;
  bool scanHaptic;
  bool showEditBanner; // attendees banner
  bool notificationsEnabled;

  Settings({
    this.themeMode = AppThemeMode.system,
    this.haptics = true,
    this.scanHaptic = true,
    this.showEditBanner = true,
    this.notificationsEnabled = true,
  });

  Settings copyWith({
    AppThemeMode? themeMode,
    bool? haptics,
    bool? scanHaptic,
    bool? showEditBanner,
    bool? notificationsEnabled,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      haptics: haptics ?? this.haptics,
      scanHaptic: scanHaptic ?? this.scanHaptic,
      showEditBanner: showEditBanner ?? this.showEditBanner,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsStore {
  SettingsStore._();
  static final SettingsStore I = SettingsStore._();

  final ValueNotifier<Settings> settings = ValueNotifier<Settings>(Settings());
  void update(Settings s) => settings.value = s;
}