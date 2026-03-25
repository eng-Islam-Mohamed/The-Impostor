import 'dart:math';

import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

int maxOutsidersForPlayerCount(int playerCount) {
  if (playerCount >= 9) {
    return 3;
  }
  if (playerCount >= 6) {
    return 2;
  }
  return 1;
}

enum RoundPhase {
  reveal,
  clueTurns,
  discussion,
  voting,
  suspense,
  outsiderGuess,
  results,
}

@immutable
class GameSessionState {
  const GameSessionState({
    required this.players,
    required this.selectedMode,
    required this.selectedPackId,
    required this.discussionSeconds,
    required this.scoringEnabled,
    required this.outsiderCount,
    required this.roundNumber,
    required this.phase,
    required this.assignments,
    required this.revealIndex,
    required this.clueIndex,
    required this.clueLap,
    required this.outsiderGuessIndex,
    required this.votes,
    required this.currentTopic,
    required this.outsiderIds,
    required this.outcome,
  });

  factory GameSessionState.initial({
    List<PlayerProfile>? players,
  }) {
    return GameSessionState(
      players: players ?? buildStarterPlayers(),
      selectedMode: GameMode.classic,
      selectedPackId: seededCategoryPacks.first.id,
      discussionSeconds: GameMode.classic.defaultDiscussionSeconds,
      scoringEnabled: true,
      outsiderCount: 1,
      roundNumber: 1,
      phase: RoundPhase.reveal,
      assignments: const [],
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      votes: const <String, List<String>>{},
      currentTopic: null,
      outsiderIds: const [],
      outcome: null,
    );
  }

  final List<PlayerProfile> players;
  final GameMode selectedMode;
  final String selectedPackId;
  final int discussionSeconds;
  final bool scoringEnabled;
  final int outsiderCount;
  final int roundNumber;
  final RoundPhase phase;
  final List<SecretAssignment> assignments;
  final int revealIndex;
  final int clueIndex;
  final int clueLap;
  final int outsiderGuessIndex;
  final Map<String, List<String>> votes;
  final String? currentTopic;
  final List<String> outsiderIds;
  final RoundOutcome? outcome;

  bool get hasActiveRound => currentTopic != null && outsiderIds.isNotEmpty;

  SecretAssignment? get currentRevealAssignment {
    if (revealIndex >= assignments.length) {
      return null;
    }
    return assignments[revealIndex];
  }

  PlayerProfile? get currentCluePlayer {
    if (clueIndex >= players.length) {
      return null;
    }
    return players[clueIndex];
  }

  PlayerProfile? get currentVoter {
    for (final player in players) {
      if ((votes[player.id]?.length ?? 0) < outsiderCount) {
        return player;
      }
    }
    return null;
  }

  PlayerProfile? get currentOutsiderGuesser {
    final guessQueue = outcome?.outsiderIds ?? outsiderIds;
    if (outsiderGuessIndex >= guessQueue.length) {
      return null;
    }
    return players.firstWhereOrNull((player) => player.id == guessQueue[outsiderGuessIndex]);
  }

  List<PlayerProfile> get outsiderPlayers {
    final outsiderSet = outsiderIds.toSet();
    return players.where((player) => outsiderSet.contains(player.id)).toList(growable: false);
  }

  GameSessionState copyWith({
    List<PlayerProfile>? players,
    GameMode? selectedMode,
    String? selectedPackId,
    int? discussionSeconds,
    bool? scoringEnabled,
    int? outsiderCount,
    int? roundNumber,
    RoundPhase? phase,
    List<SecretAssignment>? assignments,
    int? revealIndex,
    int? clueIndex,
    int? clueLap,
    int? outsiderGuessIndex,
    Map<String, List<String>>? votes,
    Object? currentTopic = _sentinel,
    List<String>? outsiderIds,
    Object? outcome = _sentinel,
  }) {
    return GameSessionState(
      players: players ?? this.players,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedPackId: selectedPackId ?? this.selectedPackId,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      outsiderCount: outsiderCount ?? this.outsiderCount,
      roundNumber: roundNumber ?? this.roundNumber,
      phase: phase ?? this.phase,
      assignments: assignments ?? this.assignments,
      revealIndex: revealIndex ?? this.revealIndex,
      clueIndex: clueIndex ?? this.clueIndex,
      clueLap: clueLap ?? this.clueLap,
      outsiderGuessIndex: outsiderGuessIndex ?? this.outsiderGuessIndex,
      votes: votes ?? this.votes,
      currentTopic:
          identical(currentTopic, _sentinel) ? this.currentTopic : currentTopic as String?,
      outsiderIds: outsiderIds ?? this.outsiderIds,
      outcome:
          identical(outcome, _sentinel) ? this.outcome : outcome as RoundOutcome?,
    );
  }
}

const _sentinel = Object();

class GameSessionController extends Notifier<GameSessionState> {
  late final GameEngine _engine;

  @override
  GameSessionState build() {
    _engine = GameEngine(random: Random());
    ref.listen(appSettingsProvider, (previous, next) {
      if (previous?.locale == next.locale) {
        return;
      }
      _refreshDefaultPlayerNames(next.locale);
    });
    final locale = ref.read(appSettingsProvider).locale;
    return GameSessionState.initial(
      players: buildStarterPlayers(locale: locale),
    );
  }

  void selectMode(GameMode mode) {
    state = state.copyWith(
      selectedMode: mode,
      discussionSeconds: mode.defaultDiscussionSeconds,
    );
    _clampOutsiderCount();
  }

  void setDiscussionSeconds(int seconds) {
    state = state.copyWith(discussionSeconds: seconds);
  }

  void toggleScoring(bool enabled) {
    state = state.copyWith(scoringEnabled: enabled);
  }

  void setOutsiderCount(int count) {
    state = state.copyWith(
      outsiderCount: count.clamp(1, maxOutsidersForPlayerCount(state.players.length)),
    );
  }

  void updatePlayerName(String playerId, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(
      players: [
        for (final player in state.players)
          if (player.id == playerId) player.copyWith(name: trimmed) else player,
      ],
    );
  }

  void addPlayer() {
    final nextIndex = state.players.length;
    final locale = ref.read(appSettingsProvider).locale;
    final player = PlayerProfile(
      id: 'player-$nextIndex-${DateTime.now().microsecondsSinceEpoch}',
      name: defaultPlayerName(nextIndex + 1, locale),
      avatarIndex: nextIndex % 8,
      score: 0,
    );
    state = state.copyWith(players: [...state.players, player]);
    _clampOutsiderCount();
  }

  void removePlayer(String playerId) {
    if (state.players.length <= 3) {
      return;
    }
    state = state.copyWith(
      players: state.players.where((player) => player.id != playerId).toList(),
    );
    _clampOutsiderCount();
  }

  void shufflePlayers() {
    final shuffled = [...state.players]..shuffle();
    state = state.copyWith(players: shuffled);
  }

  void cycleAvatar(String playerId) {
    state = state.copyWith(
      players: [
        for (final player in state.players)
          if (player.id == playerId)
            player.copyWith(avatarIndex: (player.avatarIndex + 1) % 8)
          else
            player,
      ],
    );
  }

  void selectPack(String packId) {
    state = state.copyWith(selectedPackId: packId);
  }

  Future<void> startRound() async {
    final pack = ref.read(categoryLibraryProvider.notifier).getPackById(state.selectedPackId);
    await _ensurePackTranslations(pack);
    final seed = _engine.createRound(
      players: state.players,
      pack: pack,
      outsiderCount: state.outsiderCount,
    );

    state = state.copyWith(
      assignments: seed.assignments,
      currentTopic: seed.topic,
      outsiderIds: seed.outsiderIds,
      votes: const <String, List<String>>{},
      phase: RoundPhase.reveal,
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      outcome: null,
    );
  }

  void advanceReveal() {
    final nextIndex = state.revealIndex + 1;
    state = state.copyWith(revealIndex: nextIndex);
    if (nextIndex >= state.assignments.length) {
      state = state.copyWith(phase: RoundPhase.clueTurns);
    }
  }

  void advanceClueTurn() {
    final nextIndex = (state.clueIndex + 1) % state.players.length;
    final nextLap = nextIndex == 0 ? state.clueLap + 1 : state.clueLap;
    state = state.copyWith(
      clueIndex: nextIndex,
      clueLap: nextLap,
    );
  }

  void startDiscussion() {
    state = state.copyWith(phase: RoundPhase.discussion);
  }

  void startVoting() {
    state = state.copyWith(phase: RoundPhase.voting);
  }

  void submitVote(List<String> suspectIds) {
    final voter = state.currentVoter;
    if (voter == null || state.outsiderIds.isEmpty || state.currentTopic == null) {
      return;
    }
    if (suspectIds.length != state.outsiderCount) {
      return;
    }
    if (suspectIds.toSet().length != suspectIds.length) {
      return;
    }
    if (suspectIds.contains(voter.id)) {
      return;
    }

    final nextVotes = Map<String, List<String>>.from(state.votes)
      ..[voter.id] = List<String>.from(suspectIds);

    if (nextVotes.length == state.players.length) {
      final outcome = _engine.resolveRound(
        players: state.players,
        outsiderIds: state.outsiderIds,
        topic: state.currentTopic!,
        votes: nextVotes,
        topicPool: selectedPack.topics,
      );

      state = state.copyWith(
        votes: nextVotes,
        phase: RoundPhase.suspense,
        outcome: outcome,
      );
      return;
    }

    state = state.copyWith(votes: nextVotes);
  }

  void finishSuspense() {
    if (state.phase != RoundPhase.suspense || state.outcome == null) {
      return;
    }
    if (state.outcome!.outsiderIds.isEmpty) {
      final updatedPlayers = state.scoringEnabled
          ? _engine.applyOutcome(players: state.players, outcome: state.outcome!)
          : state.players;
      state = state.copyWith(
        players: updatedPlayers,
        phase: RoundPhase.results,
      );
      return;
    }
    state = state.copyWith(
      phase: RoundPhase.outsiderGuess,
      outsiderGuessIndex: 0,
    );
  }

  void submitOutsiderGuess(String guessedTopic) {
    final outcome = state.outcome;
    final outsider = state.currentOutsiderGuesser;
    if (outcome == null || outsider == null) {
      return;
    }

    final finalized = _engine.finalizeOutsiderGuess(
      outcome: outcome,
      outsiderId: outsider.id,
      guessedTopic: guessedTopic,
    );
    final allOutsiders = finalized.outsiderIds;
    final isLastOutsider = state.outsiderGuessIndex >= allOutsiders.length - 1;

    if (!isLastOutsider) {
      state = state.copyWith(
        outcome: finalized,
        outsiderGuessIndex: state.outsiderGuessIndex + 1,
      );
      return;
    }

    final updatedPlayers = state.scoringEnabled
        ? _engine.applyOutcome(players: state.players, outcome: finalized)
        : state.players;

    state = state.copyWith(
      outcome: finalized,
      players: updatedPlayers,
      phase: RoundPhase.results,
    );
  }

  void resetScores() {
    state = state.copyWith(
      players: [
        for (final player in state.players) player.copyWith(score: 0),
      ],
    );
  }

  Future<void> playAgain() async {
    state = state.copyWith(roundNumber: state.roundNumber + 1);
    await startRound();
  }

  void _clampOutsiderCount() {
    final maxAllowed = maxOutsidersForPlayerCount(state.players.length);
    if (state.outsiderCount > maxAllowed) {
      state = state.copyWith(outsiderCount: maxAllowed);
    }
  }

  void _refreshDefaultPlayerNames(SupportedLocale locale) {
    state = state.copyWith(
      players: [
        for (var index = 0; index < state.players.length; index++)
          if (isDefaultPlayerName(state.players[index].name))
            state.players[index].copyWith(name: defaultPlayerName(index + 1, locale))
          else
            state.players[index],
      ],
    );
  }

  Future<void> _ensurePackTranslations(CategoryPack pack) async {
    final locale = ref.read(appSettingsProvider).locale;
    if (locale == SupportedLocale.arabic) {
      return;
    }

    await ref.read(topicTranslationsProvider.notifier).ensureTopicsTranslated(
          packId: pack.id,
          topics: pack.topics,
        );
  }

  CategoryPack get selectedPack {
    return ref.read(categoryLibraryProvider.notifier).getPackById(state.selectedPackId);
  }
}

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSessionState>(
  GameSessionController.new,
);
