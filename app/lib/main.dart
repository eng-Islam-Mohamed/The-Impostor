import 'package:bara_alsalfa/app/app.dart';
import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/local/local_settings_store.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsStore = LocalSettingsStore();
  final initialSettings = await settingsStore.load();
  final subjectsStore = LocalSubjectsStore();
  final initialCategoryPacks = await subjectsStore.load();

  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settingsStore),
        initialAppSettingsProvider.overrideWithValue(initialSettings),
        subjectsStoreProvider.overrideWithValue(subjectsStore),
        initialCategoryPacksProvider.overrideWithValue(initialCategoryPacks),
      ],
      child: const BaraApp(),
    ),
  );
}
