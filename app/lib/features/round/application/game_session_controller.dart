import 'dart:math';

import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RoundPhase {
  reveal,
  clueTurns,
  discussion,
  voting,
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
    required this.roundNumber,
    required this.phase,
    required this.assignments,
    required this.revealIndex,
    required this.clueIndex,
    required this.votes,
    required this.currentTopic,
    required this.outsiderId,
    required this.outcome,
  });

  factory GameSessionState.initial() {
    return GameSessionState(
      players: buildStarterPlayers(),
      selectedMode: GameMode.classic,
      selectedPackId: seededCategoryPacks.first.id,
      discussionSeconds: GameMode.classic.defaultDiscussionSeconds,
      scoringEnabled: true,
      roundNumber: 1,
      phase: RoundPhase.reveal,
      assignments: const [],
      revealIndex: 0,
      clueIndex: 0,
      votes: const {},
      currentTopic: null,
      outsiderId: null,
      outcome: null,
    );
  }

  final List<PlayerProfile> players;
  final GameMode selectedMode;
  final String selectedPackId;
  final int discussionSeconds;
  final bool scoringEnabled;
  final int roundNumber;
  final RoundPhase phase;
  final List<SecretAssignment> assignments;
  final int revealIndex;
  final int clueIndex;
  final Map<String, String> votes;
  final String? currentTopic;
  final String? outsiderId;
  final RoundOutcome? outcome;

  bool get hasActiveRound => currentTopic != null && outsiderId != null;

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
    if (votes.length >= players.length) {
      return null;
    }
    return players[votes.length];
  }

  GameSessionState copyWith({
    List<PlayerProfile>? players,
    GameMode? selectedMode,
    String? selectedPackId,
    int? discussionSeconds,
    bool? scoringEnabled,
    int? roundNumber,
    RoundPhase? phase,
    List<SecretAssignment>? assignments,
    int? revealIndex,
    int? clueIndex,
    Map<String, String>? votes,
    Object? currentTopic = _sentinel,
    Object? outsiderId = _sentinel,
    Object? outcome = _sentinel,
  }) {
    return GameSessionState(
      players: players ?? this.players,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedPackId: selectedPackId ?? this.selectedPackId,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      roundNumber: roundNumber ?? this.roundNumber,
      phase: phase ?? this.phase,
      assignments: assignments ?? this.assignments,
      revealIndex: revealIndex ?? this.revealIndex,
      clueIndex: clueIndex ?? this.clueIndex,
      votes: votes ?? this.votes,
      currentTopic:
          identical(currentTopic, _sentinel) ? this.currentTopic : currentTopic as String?,
      outsiderId:
          identical(outsiderId, _sentinel) ? this.outsiderId : outsiderId as String?,
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
    return GameSessionState.initial();
  }

  void selectMode(GameMode mode) {
    state = state.copyWith(
      selectedMode: mode,
      discussionSeconds: mode.defaultDiscussionSeconds,
    );
  }

  void setDiscussionSeconds(int seconds) {
    state = state.copyWith(discussionSeconds: seconds);
  }

  void toggleScoring(bool enabled) {
    state = state.copyWith(scoringEnabled: enabled);
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
    final player = PlayerProfile(
      id: 'player-$nextIndex-${DateTime.now().microsecondsSinceEpoch}',
      name: 'لاعب ${nextIndex + 1}',
      avatarIndex: nextIndex % 8,
      score: 0,
    );
    state = state.copyWith(players: [...state.players, player]);
  }

  void removePlayer(String playerId) {
    if (state.players.length <= 3) {
      return;
    }
    state = state.copyWith(
      players: state.players.where((player) => player.id != playerId).toList(),
    );
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

  void startRound() {
    final pack = ref.read(categoryLibraryProvider.notifier).getPackById(state.selectedPackId);
    final seed = _engine.createRound(players: state.players, pack: pack);

    state = state.copyWith(
      assignments: seed.assignments,
      currentTopic: seed.topic,
      outsiderId: seed.outsiderId,
      votes: {},
      phase: RoundPhase.reveal,
      revealIndex: 0,
      clueIndex: 0,
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
    final nextIndex = state.clueIndex + 1;
    if (nextIndex >= state.players.length) {
      state = state.copyWith(phase: RoundPhase.discussion, clueIndex: nextIndex);
      return;
    }
    state = state.copyWith(clueIndex: nextIndex);
  }

  void startVoting() {
    state = state.copyWith(phase: RoundPhase.voting);
  }

  void submitVote(String suspectId) {
    final voter = state.currentVoter;
    if (voter == null || state.outsiderId == null || state.currentTopic == null) {
      return;
    }

    final nextVotes = Map<String, String>.from(state.votes)
      ..[voter.id] = suspectId;

    if (nextVotes.length == state.players.length) {
      final outcome = _engine.resolveRound(
        players: state.players,
        outsiderId: state.outsiderId!,
        topic: state.currentTopic!,
        votes: nextVotes,
      );
      final updatedPlayers = state.scoringEnabled
          ? _engine.applyOutcome(players: state.players, outcome: outcome)
          : state.players;

      state = state.copyWith(
        votes: nextVotes,
        phase: RoundPhase.results,
        outcome: outcome,
        players: updatedPlayers,
      );
      return;
    }

    state = state.copyWith(votes: nextVotes);
  }

  void playAgain() {
    state = state.copyWith(roundNumber: state.roundNumber + 1);
    startRound();
  }

  CategoryPack get selectedPack {
    return ref.read(categoryLibraryProvider.notifier).getPackById(state.selectedPackId);
  }
}

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSessionState>(
  GameSessionController.new,
);
