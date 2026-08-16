import 'package:bara_alsalfa/data/local/local_saved_groups_store.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/saved_game_group.dart';
import 'package:bara_alsalfa/features/groups/application/saved_groups_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'groups persist independently and duplication can reset scores',
    () async {
      final store = _MemorySavedGroupsStore();
      final container = ProviderContainer(
        overrides: [savedGroupsStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final controller = container.read(savedGroupsProvider.notifier);

      final original = await controller.create(
        name: 'الأصدقاء الأربعة',
        session: _snapshot,
      );
      final copy = await controller.duplicate(
        groupId: original.id,
        name: 'الأصدقاء الخمسة',
        copyScores: false,
      );

      expect(copy, isNotNull);
      expect(container.read(savedGroupsProvider).activeGroupId, original.id);
      expect(original.session.players.first.score, 7);
      expect(
        copy!.session.players.every((player) => player.score == 0),
        isTrue,
      );
      expect(store.saved.groups, hasLength(2));
    },
  );
}

const _snapshot = PersistedGameSession(
  players: [
    PlayerProfile(id: 'p1', name: 'Islam', avatarIndex: 0, score: 7),
    PlayerProfile(id: 'p2', name: 'Ali', avatarIndex: 1, score: -2),
    PlayerProfile(id: 'p3', name: 'Sara', avatarIndex: 2, score: 3),
  ],
  selectedMode: GameMode.classic,
  selectedPackId: 'countries',
  discussionSeconds: 45,
  scoringEnabled: true,
  powerCardsEnabled: true,
  activePowerCardIds: {},
  outsidersKnowEachOther: false,
  outsiderCount: 1,
  roundNumber: 4,
);

class _MemorySavedGroupsStore implements SavedGroupsStore {
  SavedGroupsState saved = const SavedGroupsState();

  @override
  Future<SavedGroupsState> load() async => saved;

  @override
  Future<void> save(SavedGroupsState state) async {
    saved = state;
  }
}
