import 'package:bara_alsalfa/data/local/local_game_session_store.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_phase.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new rosters use neutral localized player labels', () {
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
      ],
    );
    addTearDown(container.dispose);

    final names = container
        .read(gameSessionProvider)
        .players
        .map((player) => player.name)
        .toList(growable: false);
    expect(names, ['لاعب 1', 'لاعب 2', 'لاعب 3', 'لاعب 4', 'لاعب 5']);
  });

  test('legacy preset names migrate while custom names stay unchanged', () {
    final legacy = _snapshotWithPlayers([
      const PlayerProfile(id: 'p1', name: 'سالم', avatarIndex: 0, score: 4),
      const PlayerProfile(id: 'p2', name: 'نورة', avatarIndex: 1, score: 2),
      const PlayerProfile(
        id: 'p3',
        name: 'My Friend',
        avatarIndex: 2,
        score: 1,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
        initialGameSessionProvider.overrideWithValue(legacy),
      ],
    );
    addTearDown(container.dispose);

    final names = container
        .read(gameSessionProvider)
        .players
        .map((player) => player.name)
        .toList(growable: false);
    expect(names, ['لاعب 1', 'لاعب 2', 'My Friend']);
  });

  test('adding a player persists the updated roster', () async {
    final store = _MemoryGameSessionStore();
    final container = ProviderContainer(
      overrides: [gameSessionStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    final originalCount = container.read(gameSessionProvider).players.length;

    controller.addPlayer();
    await controller.flushPendingSaves();

    expect(store.savedSession, isNotNull);
    expect(store.savedSession!.players.length, originalCount + 1);
  });

  test('resetting scores persists the score change', () async {
    final store = _MemoryGameSessionStore();
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(store),
        initialGameSessionProvider.overrideWithValue(_scoredSnapshot()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    controller.resetScores();
    await controller.flushPendingSaves();

    expect(
      store.savedSession!.players.every((player) => player.score == 0),
      isTrue,
    );
  });

  test('clearing a session resets state and removes the snapshot', () async {
    final store = _MemoryGameSessionStore();
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(store),
        initialGameSessionProvider.overrideWithValue(_scoredSnapshot()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(gameSessionProvider.notifier);
    await controller.clearSavedSession();

    expect(store.savedSession, isNull);
    expect(container.read(gameSessionProvider).hasSavedSession, isFalse);
    expect(
      container
          .read(gameSessionProvider)
          .players
          .every((player) => player.score == 0),
      isTrue,
    );
  });

  test(
    'sequential rounds accumulate scores and every outsider guesses',
    () async {
      final store = _MemoryGameSessionStore();
      final container = ProviderContainer(
        overrides: [gameSessionStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameSessionProvider.notifier);
      final players = container.read(gameSessionProvider).players;
      final outsiderIds = [players[0].id, players[1].id];
      final topic = 'Algeria';

      controller.setOutsiderCount(2);
      controller.toggleSequentialElimination(true);
      controller.setCustomState(
        players: players,
        assignments: [
          for (final player in players)
            SecretAssignment(
              playerId: player.id,
              playerName: player.name,
              topic: topic,
              isOutsider: outsiderIds.contains(player.id),
            ),
        ],
        currentTopic: topic,
        outsiderIds: outsiderIds,
        powerCards: const {},
        phase: RoundPhase.voting,
      );

      while (true) {
        final voter = container.read(gameSessionProvider).currentVoter;
        if (voter == null) break;
        controller.submitVote([
          voter.id == outsiderIds.first ? players[2].id : outsiderIds.first,
        ]);
      }
      expect(container.read(gameSessionProvider).phase, RoundPhase.suspense);
      controller.finishSuspense();
      expect(container.read(gameSessionProvider).phase, RoundPhase.clueTurns);
      expect(
        container.read(gameSessionProvider).eliminatedPlayerIds,
        contains(outsiderIds.first),
      );

      controller.startDiscussion();
      controller.proceedToVoting();
      while (true) {
        final voter = container.read(gameSessionProvider).currentVoter;
        if (voter == null) break;
        controller.submitVote([
          voter.id == outsiderIds.last ? players[2].id : outsiderIds.last,
        ]);
      }
      controller.finishSuspense();
      expect(
        container.read(gameSessionProvider).phase,
        RoundPhase.outsiderGuess,
      );

      controller.submitOutsiderGuess(topic);
      expect(
        container.read(gameSessionProvider).currentOutsiderGuesser?.id,
        outsiderIds.last,
      );
      controller.submitOutsiderGuess('Wrong topic');

      final completed = container.read(gameSessionProvider);
      expect(completed.phase, RoundPhase.results);
      expect(completed.outcome!.scoreDeltas[outsiderIds.first], 1);
      expect(completed.outcome!.scoreDeltas[outsiderIds.last], -1);
      for (final player in players.skip(2)) {
        expect(completed.outcome!.scoreDeltas[player.id], 2);
        expect(
          completed.players.firstWhere((item) => item.id == player.id).score,
          2,
        );
      }
      await controller.flushPendingSaves();
      expect(
        store.savedSession!.players.any((player) => player.score != 0),
        isTrue,
      );

      // A rematch resets temporary state but still routes every newly assigned
      // outsider through the guessing queue.
      controller.toggleSequentialElimination(false);
      controller.togglePowerCards(false);
      await controller.playAgain();
      final rematch = container.read(gameSessionProvider);
      expect(rematch.phase, RoundPhase.reveal);
      expect(rematch.outcome, isNull);
      expect(rematch.eliminatedPlayerIds, isEmpty);

      final rematchOutsiders = rematch.outsiderIds.toSet();
      while (true) {
        final voter = container.read(gameSessionProvider).currentVoter;
        if (voter == null) break;
        final choices = container
            .read(gameSessionProvider)
            .players
            .where((player) => player.id != voter.id)
            .map((player) => player.id)
            .take(2)
            .toList();
        controller.submitVote(choices);
      }
      controller.finishSuspense();
      expect(
        container.read(gameSessionProvider).phase,
        RoundPhase.outsiderGuess,
      );
      for (var index = 0; index < rematchOutsiders.length; index++) {
        controller.submitOutsiderGuess(topic);
      }
      expect(container.read(gameSessionProvider).phase, RoundPhase.results);
      expect(
        container.read(gameSessionProvider).outcome!.outsiderGuesses,
        hasLength(rematchOutsiders.length),
      );
    },
  );

  test('second chance is isolated per outsider in the guess queue', () {
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameSessionProvider.notifier);
    final players = container.read(gameSessionProvider).players;
    final outsiders = [players[0].id, players[1].id];
    const topic = 'Algeria';
    final outcome = RoundOutcome(
      outsiderIds: outsiders,
      survivingOutsiderIds: outsiders,
      accusedPlayerIds: const [],
      topic: topic,
      voteCounts: const {},
      voteScoreDeltas: {for (final player in players) player.id: 0},
      scoreDeltas: {for (final player in players) player.id: 0},
      outsiderGuessOptions: const [topic, 'France'],
      outsiderCaught: false,
      isTie: false,
      recapLine: 'Test',
    );
    controller.setCustomState(
      players: players,
      assignments: [
        for (final player in players)
          SecretAssignment(
            playerId: player.id,
            playerName: player.name,
            topic: topic,
            isOutsider: outsiders.contains(player.id),
          ),
      ],
      currentTopic: topic,
      outsiderIds: outsiders,
      powerCards: {outsiders.first: PowerCardCatalog.outsiderSecondChance},
      phase: RoundPhase.outsiderGuess,
      outcome: outcome,
    );

    controller.submitOutsiderGuess('France');
    var state = container.read(gameSessionProvider);
    expect(state.outsiderGuessIndex, 0);
    expect(state.outsiderGuessAttempts, 1);
    expect(state.outcome!.outsiderGuessResults, isEmpty);

    controller.submitOutsiderGuess(topic);
    state = container.read(gameSessionProvider);
    expect(state.outsiderGuessIndex, 1);
    expect(state.outsiderGuessAttempts, 0);
    expect(state.currentOutsiderGuesser?.id, outsiders.last);

    controller.submitOutsiderGuess('France');
    state = container.read(gameSessionProvider);
    expect(state.phase, RoundPhase.results);
    expect(state.outcome!.scoreDeltas[outsiders.first], 1);
    expect(state.outcome!.scoreDeltas[outsiders.last], -1);
  });

  test('one-outsider sequential mode eliminates one player per ballot', () {
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameSessionProvider.notifier);
    final players = container
        .read(gameSessionProvider)
        .players
        .take(4)
        .toList();
    final outsiderId = players.first.id;
    controller.toggleSequentialElimination(true);
    controller.setCustomState(
      players: players,
      assignments: _assignments(players, [outsiderId]),
      currentTopic: 'Algeria',
      outsiderIds: [outsiderId],
      powerCards: const {},
      phase: RoundPhase.voting,
    );

    while (container.read(gameSessionProvider).currentVoter != null) {
      final voter = container.read(gameSessionProvider).currentVoter!;
      controller.submitVote([
        voter.id == players[1].id ? players[2].id : players[1].id,
      ]);
    }
    controller.finishSuspense();

    final state = container.read(gameSessionProvider);
    expect(state.eliminatedPlayerIds, contains(players[1].id));
    expect(state.phase, RoundPhase.clueTurns);
    expect(state.votesPerPlayer, 1);
  });

  test('four-choice skill activation is private and guarantees the topic', () {
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameSessionProvider.notifier);
    final players = container.read(gameSessionProvider).players;
    final outsiderId = players.first.id;
    controller.setCustomState(
      players: players,
      assignments: _assignments(players, [outsiderId]),
      currentTopic: 'Algeria',
      outsiderIds: [outsiderId],
      powerCards: {outsiderId: PowerCardCatalog.outsiderFourChoice},
      phase: RoundPhase.outsiderGuess,
      outcome: _guessOutcome(players, [outsiderId]),
    );

    controller.activateFourChoiceForCurrentOutsider();
    final state = container.read(gameSessionProvider);
    expect(state.outcome!.guessOptionsFor(outsiderId), hasLength(4));
    expect(state.outcome!.guessOptionsFor(outsiderId), contains('Algeria'));
    expect(state.activatedOutsiderSkillIds, contains(outsiderId));
  });

  test('high risk and point wager use their real score rules', () {
    final container = ProviderContainer(
      overrides: [
        gameSessionStoreProvider.overrideWithValue(_MemoryGameSessionStore()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameSessionProvider.notifier);
    final basePlayers = container.read(gameSessionProvider).players;
    final players = [
      basePlayers[0],
      basePlayers[1].copyWith(score: 7),
      ...basePlayers.skip(2),
    ];
    final outsiderId = players.first.id;

    controller.setCustomState(
      players: players,
      assignments: _assignments(players, [outsiderId]),
      currentTopic: 'Algeria',
      outsiderIds: [outsiderId],
      powerCards: {outsiderId: PowerCardCatalog.outsiderHighRisk},
      phase: RoundPhase.outsiderGuess,
      outcome: _guessOutcome(players, [outsiderId]),
    );
    controller.submitOutsiderGuess('France');
    expect(
      container.read(gameSessionProvider).outcome!.scoreDeltas[outsiderId],
      -4,
    );

    controller.setCustomState(
      players: players,
      assignments: _assignments(players, [outsiderId]),
      currentTopic: 'Algeria',
      outsiderIds: [outsiderId],
      powerCards: {outsiderId: PowerCardCatalog.outsiderPointWager},
      phase: RoundPhase.outsiderGuess,
      outcome: _guessOutcome(players, [outsiderId]),
    );
    controller.selectOutsiderWagerTarget(players[1].id);
    controller.submitOutsiderGuess('Algeria');
    final wagerOutcome = container.read(gameSessionProvider).outcome!;
    expect(wagerOutcome.scoreDeltas[outsiderId], 4);
    expect(wagerOutcome.scoreDeltas[players[1].id], -4);
  });
}

List<SecretAssignment> _assignments(
  List<PlayerProfile> players,
  List<String> outsiderIds,
) {
  return [
    for (final player in players)
      SecretAssignment(
        playerId: player.id,
        playerName: player.name,
        topic: 'Algeria',
        isOutsider: outsiderIds.contains(player.id),
      ),
  ];
}

RoundOutcome _guessOutcome(
  List<PlayerProfile> players,
  List<String> outsiderIds,
) {
  return RoundOutcome(
    outsiderIds: outsiderIds,
    survivingOutsiderIds: outsiderIds,
    accusedPlayerIds: const [],
    topic: 'Algeria',
    voteCounts: const {},
    voteScoreDeltas: {for (final player in players) player.id: 0},
    scoreDeltas: {for (final player in players) player.id: 0},
    outsiderGuessOptions: const ['Algeria', 'France'],
    outsiderCaught: false,
    isTie: false,
    recapLine: 'Test',
  );
}

PersistedGameSession _scoredSnapshot() {
  return const PersistedGameSession(
    players: [
      PlayerProfile(id: 'player-1', name: 'Player 1', avatarIndex: 0, score: 4),
      PlayerProfile(
        id: 'player-2',
        name: 'Player 2',
        avatarIndex: 1,
        score: -2,
      ),
      PlayerProfile(id: 'player-3', name: 'Player 3', avatarIndex: 2, score: 1),
    ],
    selectedMode: GameMode.quick,
    selectedPackId: 'countries',
    discussionSeconds: 35,
    scoringEnabled: true,
    powerCardsEnabled: false,
    activePowerCardIds: {},
    outsidersKnowEachOther: false,
    outsiderCount: 1,
    roundNumber: 3,
  );
}

PersistedGameSession _snapshotWithPlayers(List<PlayerProfile> players) {
  return PersistedGameSession(
    players: players,
    selectedMode: GameMode.classic,
    selectedPackId: 'countries',
    discussionSeconds: 45,
    scoringEnabled: true,
    powerCardsEnabled: false,
    activePowerCardIds: const {},
    outsidersKnowEachOther: false,
    outsiderCount: 1,
    roundNumber: 1,
  );
}

class _MemoryGameSessionStore implements GameSessionStore {
  PersistedGameSession? savedSession;

  @override
  Future<void> clear() async {
    savedSession = null;
  }

  @override
  Future<PersistedGameSession?> load() async => savedSession;

  @override
  Future<void> save(PersistedGameSession session) async {
    savedSession = session;
  }
}
