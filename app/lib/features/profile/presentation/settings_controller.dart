import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:bara_alsalfa/data/local/local_settings_store.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('SettingsStore override missing.'),
);

final initialAppSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings.defaults(),
);

class AppSettingsController extends Notifier<AppSettings> {
  SettingsStore get _settingsStore => ref.read(settingsStoreProvider);

  @override
  AppSettings build() {
    return ref.read(initialAppSettingsProvider);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingSeen: true);
    await _settingsStore.save(state);
  }

  Future<void> toggleThemeMode() async {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: nextMode);
    await _settingsStore.save(state);
  }

  Future<void> setHaptics(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _settingsStore.save(state);
  }

  Future<void> setSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await AppAudio.instance.setEnabled(enabled);
    await _settingsStore.save(state);
  }

  Future<void> setReducedMotion(bool enabled) async {
    state = state.copyWith(reducedMotion: enabled);
    await _settingsStore.save(state);
  }

  Future<void> setLocale(SupportedLocale locale) async {
    state = state.copyWith(locale: locale);
    await _settingsStore.save(state);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);
