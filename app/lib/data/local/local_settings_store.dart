import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter/material.dart';

abstract class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class LocalSettingsStore implements SettingsStore {
  LocalSettingsStore({String? filePath})
      : _file = File(
          filePath ??
              '${Directory.systemTemp.path}${Platform.pathSeparator}bara_alsalfa_settings.json',
        );

  final File _file;

  @override
  Future<AppSettings> load() async {
    try {
      if (!await _file.exists()) {
        return const AppSettings.defaults();
      }
      final content = await _file.readAsString();
      if (content.trim().isEmpty) {
        return const AppSettings.defaults();
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppSettings(
        themeMode: switch (json['themeMode']) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.dark,
        },
        onboardingSeen: json['onboardingSeen'] as bool? ?? false,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        reducedMotion: json['reducedMotion'] as bool? ?? false,
        locale: SupportedLocale.fromCode(json['locale'] as String? ?? 'ar'),
      );
    } catch (_) {
      return const AppSettings.defaults();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      jsonEncode({
        'themeMode': switch (settings.themeMode) {
          ThemeMode.light => 'light',
          ThemeMode.dark || ThemeMode.system => 'dark',
        },
        'onboardingSeen': settings.onboardingSeen,
        'hapticsEnabled': settings.hapticsEnabled,
        'soundEnabled': settings.soundEnabled,
        'reducedMotion': settings.reducedMotion,
        'locale': settings.locale.code,
      }),
    );
  }
}
