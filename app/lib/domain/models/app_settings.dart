import 'package:flutter/material.dart';

/// Supported locales in the app
enum SupportedLocale {
  arabic('ar', 'العربية', TextDirection.rtl),
  english('en', 'English', TextDirection.ltr),
  chinese('zh', '中文', TextDirection.ltr),
  hindi('hi', 'हिन्दी', TextDirection.ltr),
  spanish('es', 'Español', TextDirection.ltr),
  french('fr', 'Français', TextDirection.ltr),
  bengali('bn', 'বাংলা', TextDirection.ltr),
  portuguese('pt', 'Português', TextDirection.ltr),
  russian('ru', 'Русский', TextDirection.ltr),
  indonesian('id', 'Bahasa Indonesia', TextDirection.ltr);

  const SupportedLocale(this.code, this.nativeName, this.textDirection);

  final String code;
  final String nativeName;
  final TextDirection textDirection;

  Locale get locale => Locale(code);

  static SupportedLocale fromCode(String code) {
    return SupportedLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => SupportedLocale.arabic,
    );
  }

  static List<Locale> get supportedLocales =>
      SupportedLocale.values.map((l) => l.locale).toList();
}

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.onboardingSeen,
    required this.hapticsEnabled,
    required this.soundEnabled,
    required this.reducedMotion,
    required this.locale,
  });

  const AppSettings.defaults()
      : themeMode = ThemeMode.dark,
        onboardingSeen = false,
        hapticsEnabled = true,
        soundEnabled = true,
        reducedMotion = false,
        locale = SupportedLocale.arabic;

  final ThemeMode themeMode;
  final bool onboardingSeen;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool reducedMotion;
  final SupportedLocale locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? onboardingSeen,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? reducedMotion,
    SupportedLocale? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      locale: locale ?? this.locale,
    );
  }
}
