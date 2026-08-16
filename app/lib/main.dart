import 'package:bara_alsalfa/app/app.dart';
import 'package:bara_alsalfa/data/local/local_game_session_store.dart';
import 'package:bara_alsalfa/data/local/local_saved_groups_store.dart';
import 'package:bara_alsalfa/data/local/local_settings_store.dart';
import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/groups/application/saved_groups_controller.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsStore = LocalSettingsStore();
  final sessionStore = LocalGameSessionStore();
  final subjectsStore = LocalSubjectsStore();
  final groupsStore = LocalSavedGroupsStore();
  final settings = await settingsStore.load();
  final savedSession = await sessionStore.load();
  final categoryPacks = await subjectsStore.load();
  final savedGroups = await groupsStore.load();
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }
  runApp(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settingsStore),
        initialAppSettingsProvider.overrideWithValue(settings),
        gameSessionStoreProvider.overrideWithValue(sessionStore),
        initialGameSessionProvider.overrideWithValue(savedSession),
        subjectsStoreProvider.overrideWithValue(subjectsStore),
        initialCategoryPacksProvider.overrideWithValue(categoryPacks),
        savedGroupsStoreProvider.overrideWithValue(groupsStore),
        initialSavedGroupsProvider.overrideWithValue(savedGroups),
      ],
      child: const BaraApp(),
    ),
  );
}
