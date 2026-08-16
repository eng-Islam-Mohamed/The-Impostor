import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/app_directories.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class LocalSettingsStore implements SettingsStore {
  LocalSettingsStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_settings.json';
  static AppSettings _webCache = const AppSettings.defaults();

  final String? _filePath;

  Future<File> get _file {
    return AppDirectories.documentsFile(_fileName, overridePath: _filePath);
  }

  @override
  Future<AppSettings> load() async {
    if (kIsWeb) {
      return _webCache;
    }
    try {
      final file = await _file;
      if (!await file.exists()) {
        return const AppSettings.defaults();
      }
      final content = await file.readAsString();
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
        visualTheme: AppVisualTheme.fromName(json['visualTheme'] as String?),
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
    if (kIsWeb) {
      _webCache = settings;
      return;
    }
    try {
      final file = await _file;
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'themeMode': switch (settings.themeMode) {
            ThemeMode.light => 'light',
            ThemeMode.dark || ThemeMode.system => 'dark',
          },
          'visualTheme': settings.visualTheme.name,
          'onboardingSeen': settings.onboardingSeen,
          'hapticsEnabled': settings.hapticsEnabled,
          'soundEnabled': settings.soundEnabled,
          'reducedMotion': settings.reducedMotion,
          'locale': settings.locale.code,
        }),
        flush: true,
      );
    } catch (_) {}
  }
}
