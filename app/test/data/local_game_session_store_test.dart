import 'dart:io';

import 'package:bara_alsalfa/data/local/local_game_session_store.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/secret_prank_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory testDirectory;
  late String filePath;

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp(
      'bara-session-store-test-',
    );
    filePath =
        '${testDirectory.path}${Platform.pathSeparator}game_session.json';
  });

  tearDown(() async {
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  test('save and load round-trip preserves the complete snapshot', () async {
    final store = LocalGameSessionStore(filePath: filePath);
    final snapshot = _snapshot();

    await store.save(snapshot);
    final loaded = await store.load();

    expect(loaded, isNotNull);
    expect(loaded!.toJson(), snapshot.toJson());
  });

  test('clear removes the saved session', () async {
    final store = LocalGameSessionStore(filePath: filePath);

    await store.save(_snapshot());
    await store.clear();

    expect(await store.load(), isNull);
  });

  test('missing and corrupt files return null without throwing', () async {
    final store = LocalGameSessionStore(filePath: filePath);
    expect(await store.load(), isNull);

    await File(filePath).writeAsString('{not-valid-json');
    expect(await store.load(), isNull);
  });
}

PersistedGameSession _snapshot() {
  return const PersistedGameSession(
    players: [
      PlayerProfile(id: 'player-1', name: 'Islam', avatarIndex: 2, score: -3),
      PlayerProfile(id: 'player-2', name: 'Sara', avatarIndex: 4, score: 7),
      PlayerProfile(id: 'player-3', name: 'Amine', avatarIndex: 1, score: 1),
    ],
    selectedMode: GameMode.quick,
    selectedPackId: 'countries',
    discussionSeconds: 35,
    scoringEnabled: true,
    powerCardsEnabled: true,
    activePowerCardIds: {'double_vote', 'direct_question'},
    outsidersKnowEachOther: true,
    outsiderCount: 1,
    roundNumber: 6,
    sequentialEliminationEnabled: true,
    secretPrankConfig: SecretPrankConfig(
      enabled: true,
      pin: '2468',
      insiderPlayerIds: {'player-1', 'player-3'},
      roundsRemaining: 3,
    ),
  );
}
