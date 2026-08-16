import 'package:bara_alsalfa/data/local/local_saved_groups_store.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/saved_game_group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedGroupsStoreProvider = Provider<SavedGroupsStore>(
  (ref) => LocalSavedGroupsStore(),
);

final initialSavedGroupsProvider = Provider<SavedGroupsState>(
  (ref) => const SavedGroupsState(),
);

class SavedGroupsController extends Notifier<SavedGroupsState> {
  SavedGroupsStore get _store => ref.read(savedGroupsStoreProvider);

  @override
  SavedGroupsState build() => ref.read(initialSavedGroupsProvider);

  SavedGameGroup? byId(String id) {
    for (final group in state.groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  Future<SavedGameGroup> create({
    required String name,
    required PersistedGameSession session,
    bool activateGroup = true,
  }) async {
    final now = DateTime.now();
    final group = SavedGameGroup(
      id: 'group-${now.microsecondsSinceEpoch}',
      name: _validName(name),
      session: session,
      updatedAt: now,
    );
    state = SavedGroupsState(
      groups: [...state.groups, group],
      activeGroupId: activateGroup ? group.id : state.activeGroupId,
    );
    await _store.save(state);
    return group;
  }

  Future<SavedGameGroup?> duplicate({
    required String groupId,
    required String name,
    required bool copyScores,
  }) async {
    final source = byId(groupId);
    if (source == null) return null;
    final players = copyScores
        ? source.session.players
        : [
            for (final player in source.session.players)
              player.copyWith(score: 0),
          ];
    return create(
      name: name,
      session: _sessionWithPlayers(source.session, players),
      activateGroup: false,
    );
  }

  Future<void> rename(String groupId, String name) async {
    state = SavedGroupsState(
      groups: [
        for (final group in state.groups)
          if (group.id == groupId)
            group.copyWith(name: _validName(name), updatedAt: DateTime.now())
          else
            group,
      ],
      activeGroupId: state.activeGroupId,
    );
    await _store.save(state);
  }

  Future<void> delete(String groupId) async {
    state = SavedGroupsState(
      groups: state.groups
          .where((group) => group.id != groupId)
          .toList(growable: false),
      activeGroupId: state.activeGroupId == groupId
          ? null
          : state.activeGroupId,
    );
    await _store.save(state);
  }

  Future<void> activate(String? groupId) async {
    state = SavedGroupsState(
      groups: state.groups,
      activeGroupId: groupId != null && byId(groupId) != null ? groupId : null,
    );
    await _store.save(state);
  }

  Future<void> syncActive(PersistedGameSession session) async {
    final activeId = state.activeGroupId;
    if (activeId == null) return;
    state = SavedGroupsState(
      groups: [
        for (final group in state.groups)
          if (group.id == activeId)
            group.copyWith(session: session, updatedAt: DateTime.now())
          else
            group,
      ],
      activeGroupId: activeId,
    );
    await _store.save(state);
  }

  String _validName(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'مجموعة جديدة' : trimmed;
  }

  PersistedGameSession _sessionWithPlayers(
    PersistedGameSession source,
    List<PlayerProfile> players,
  ) {
    return PersistedGameSession(
      players: players,
      selectedMode: source.selectedMode,
      selectedPackId: source.selectedPackId,
      discussionSeconds: source.discussionSeconds,
      scoringEnabled: source.scoringEnabled,
      powerCardsEnabled: source.powerCardsEnabled,
      activePowerCardIds: source.activePowerCardIds,
      outsidersKnowEachOther: source.outsidersKnowEachOther,
      outsiderCount: source.outsiderCount,
      roundNumber: source.roundNumber,
      powerDensity: source.powerDensity,
      sequentialEliminationEnabled: source.sequentialEliminationEnabled,
    );
  }
}

final savedGroupsProvider =
    NotifierProvider<SavedGroupsController, SavedGroupsState>(
      SavedGroupsController.new,
    );
