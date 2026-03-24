import 'package:bara_alsalfa/app/app.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:bara_alsalfa/data/local/local_multiplayer_config_store.dart';
import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/local/local_settings_store.dart';
import 'package:bara_alsalfa/data/local/local_topic_translation_store.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsStore = LocalSettingsStore();
  final initialSettings = await settingsStore.load();
  await AppAudio.instance.initialize(enabled: initialSettings.soundEnabled);
  final subjectsStore = LocalSubjectsStore();
  final initialCategoryPacks = await subjectsStore.load();
  final topicTranslationsStore = LocalTopicTranslationsStore();
  final initialTopicTranslations = await topicTranslationsStore.load();
  final multiplayerConfigStore = LocalMultiplayerConfigStore();
  final initialMultiplayerConfig = await multiplayerConfigStore.load();

  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settingsStore),
        initialAppSettingsProvider.overrideWithValue(initialSettings),
        subjectsStoreProvider.overrideWithValue(subjectsStore),
        initialCategoryPacksProvider.overrideWithValue(initialCategoryPacks),
        topicTranslationsStoreProvider.overrideWithValue(topicTranslationsStore),
        initialTopicTranslationsProvider.overrideWithValue(initialTopicTranslations),
        multiplayerConfigStoreProvider.overrideWithValue(multiplayerConfigStore),
        initialMultiplayerConfigProvider.overrideWithValue(initialMultiplayerConfig),
      ],
      child: const BaraApp(),
    ),
  );
}
