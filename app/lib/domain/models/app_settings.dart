import 'package:flutter/material.dart';

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.onboardingSeen,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.reducedMotion,
  });

  const AppSettings.defaults()
      : themeMode = ThemeMode.dark,
        onboardingSeen = false,
        hapticsEnabled = true,
        soundEnabled = true,
        reducedMotion = false;

  final ThemeMode themeMode;
  final bool onboardingSeen;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool reducedMotion;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? onboardingSeen,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? reducedMotion,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}
