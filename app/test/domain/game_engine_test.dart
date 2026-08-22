import 'dart:math';

import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEngine', () {
    final players = List.generate(
      6,
      (index) => PlayerProfile(
        id: 'p$index',
        name: 'Player ${index + 1}',
        avatarIndex: index,
        score: 0,
      ),
    );
    const pack = CategoryPack(
      id: 'test',
      title: 'Test',
      subtitle: 'pack',
      difficultyLabel: 'Easy',
      isPremium: false,
      topics: ['Algeria', 'France', 'Egypt', 'Japan', 'China', 'Brazil'],
    );

    test('creates requested number of outsiders', () {
      final engine = GameEngine(random: Random(2));
      final round = engine.createRound(
        players: players,
        pack: pack,
        outsiderCount: 2,
      );
      final outsiderCount = round.assignments
          .where((item) => item.isOutsider)
          .length;

      expect(pack.topics, contains(round.topic));
      expect(outsiderCount, 2);
      expect(round.outsiderIds, hasLength(2));
    });

    test('gives every subject the same independent probability', () {
      final engine = GameEngine(random: Random(11));
      final playedTopics = List.generate(
        12000,
        (_) => engine
            .createRound(players: players, pack: pack, outsiderCount: 1)
            .topic,
      );
      final counts = {
        for (final topic in pack.topics)
          topic: playedTopics.where((played) => played == topic).length,
      };
      final values = counts.values.toList();
      final hasImmediateRepeat = List.generate(
        playedTopics.length - 1,
        (index) => playedTopics[index] == playedTopics[index + 1],
      ).contains(true);

      expect(counts.values.every((count) => count > 0), isTrue);
      expect(values.reduce(max) - values.reduce(min), lessThanOrEqualTo(200));
      expect(hasImmediateRepeat, isTrue);
    });

    test('newly added subjects have exactly the same selection weight', () {
      final engine = GameEngine(random: Random(13));
      const updatedPack = CategoryPack(
        id: 'dynamic-pack',
        title: 'Dynamic',
        subtitle: 'pack',
        difficultyLabel: 'Easy',
        isPremium: false,
        topics: ['A', 'B', 'C', 'D', 'My custom subject'],
      );

      final playedTopics = List.generate(
        10000,
        (_) => engine
            .createRound(players: players, pack: updatedPack, outsiderCount: 1)
            .topic,
      );
      final counts = {
        for (final topic in updatedPack.topics)
          topic: playedTopics.where((played) => played == topic).length,
      };
      final values = counts.values.toList();

      expect(counts['My custom subject'], isNotNull);
      expect(values.reduce(max) - values.reduce(min), lessThanOrEqualTo(200));
    });

    test('gives every player the same independent outsider probability', () {
      final engine = GameEngine(random: Random(17));
      final outsiderIds = List.generate(
        12000,
        (_) => engine
            .createRound(players: players, pack: pack, outsiderCount: 1)
            .outsiderIds
            .single,
      );
      final counts = {
        for (final player in players)
          player.id: outsiderIds.where((id) => id == player.id).length,
      };
      final values = counts.values.toList();
      final hasImmediateRepeat = List.generate(
        outsiderIds.length - 1,
        (index) => outsiderIds[index] == outsiderIds[index + 1],
      ).contains(true);

      expect(counts.values.every((count) => count > 0), isTrue);
      expect(values.reduce(max) - values.reduce(min), lessThanOrEqualTo(200));
      expect(hasImmediateRepeat, isTrue);
    });

    test('awards per-suspect score swings for multi-outsider voting', () {
      final engine = GameEngine(random: Random(3));
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0', 'p4'],
        topic: 'Algeria',
        topicPool: pack.topics,
        votes: const {
          'p0': ['p1', 'p2'],
          'p1': ['p0', 'p4'],
          'p2': ['p4', 'p0'],
          'p3': ['p4', 'p0'],
          'p4': ['p1', 'p3'],
          'p5': ['p4', 'p0'],
        },
      );

      expect(outcome.outsiderCaught, isTrue);
      expect(outcome.accusedPlayerIds, containsAll(const ['p0', 'p4']));
      expect(outcome.survivingOutsiderIds, isEmpty);
      expect(outcome.voteScoreDeltas['p0'], 0);
      expect(outcome.voteScoreDeltas['p4'], 0);
      expect(outcome.voteScoreDeltas['p1'], 2);
      expect(outcome.voteScoreDeltas['p2'], 2);
      expect(outcome.voteScoreDeltas['p3'], 2);
      expect(outcome.voteScoreDeltas['p5'], 2);
      expect(outcome.outsiderGuessOptions, hasLength(pack.topics.length));
    });

    test('each outsider guess adds its own final point swing', () {
      final engine = GameEngine(random: Random(5));
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p2', 'p5'],
        topic: 'Egypt',
        topicPool: pack.topics,
        votes: const {
          'p0': ['p2', 'p0'],
          'p1': ['p2', 'p1'],
          'p2': ['p1', 'p3'],
          'p3': ['p2', 'p4'],
          'p4': ['p2', 'p4'],
          'p5': ['p1', 'p4'],
        },
      );

      final withFirstGuess = engine.finalizeOutsiderGuess(
        outcome: outcome,
        outsiderId: 'p2',
        guessedTopic: 'Egypt',
      );
      final finalized = engine.finalizeOutsiderGuess(
        outcome: withFirstGuess,
        outsiderId: 'p5',
        guessedTopic: 'France',
      );

      expect(finalized.outsiderGuesses['p2'], 'Egypt');
      expect(finalized.outsiderGuesses['p5'], 'France');
      expect(finalized.outsiderGuessResults['p2'], isTrue);
      expect(finalized.outsiderGuessResults['p5'], isFalse);
      expect(finalized.scoreDeltas['p2'], 1);
      expect(finalized.scoreDeltas['p5'], -1);
    });

    test('applies vote score multipliers for powered players', () {
      final engine = GameEngine(random: Random(7));
      final outcome = engine.resolveRound(
        players: players.take(4).toList(),
        outsiderIds: const ['p0'],
        topic: 'Japan',
        topicPool: pack.topics,
        voteScoreMultipliers: const {'p1': 2, 'p2': 2},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
          'p2': ['p3'],
          'p3': ['p0'],
        },
      );

      expect(outcome.voteScoreDeltas['p0'], 0);
      expect(outcome.voteScoreDeltas['p1'], 2);
      expect(outcome.voteScoreDeltas['p2'], -2);
      expect(outcome.voteScoreDeltas['p3'], 1);
    });

    test('applies Jackpot skill when player votes correctly on outsider', () {
      final engine = GameEngine(random: Random(9));
      final seededPlayers = [
        PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
        PlayerProfile(
          id: 'p1',
          name: 'Jackpot Player',
          avatarIndex: 1,
          score: 2,
        ),
        PlayerProfile(id: 'p2', name: 'Alice', avatarIndex: 2, score: 5),
        PlayerProfile(id: 'p3', name: 'Bob', avatarIndex: 3, score: 3),
        PlayerProfile(id: 'p4', name: 'Charlie', avatarIndex: 4, score: -2),
      ];

      final outcome = engine.resolveRound(
        players: seededPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'jackpot'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'], // Correct vote!
          'p2': ['p0'],
          'p3': ['p0'],
          'p4': ['p2'],
        },
      );

      expect(outcome.scoreDeltas['p1'], 9);
      expect(outcome.powerEvents, isNotEmpty);
      expect(outcome.powerEvents.first, contains('الجاكبوت'));
    });

    test(
      'applies Tactical Drain skill and resets victim score (positive and negative)',
      () {
        final engine = GameEngine(random: Random(10));
        final seededPlayersPositive = [
          PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
          PlayerProfile(id: 'p1', name: 'Drainer', avatarIndex: 1, score: 4),
          PlayerProfile(id: 'p2', name: 'Victim', avatarIndex: 2, score: 7),
        ];

        final outcomePos = engine.resolveRound(
          players: seededPlayersPositive,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p1': 'tactical_drain:p2'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p1'],
          },
        );

        expect(outcomePos.scoreDeltas['p1'], 7);
        expect(outcomePos.scoreDeltas['p2'], -7);

        // Negative victim score test:
        final seededPlayersNegative = [
          PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
          PlayerProfile(id: 'p1', name: 'Drainer', avatarIndex: 1, score: 4),
          PlayerProfile(id: 'p2', name: 'Victim', avatarIndex: 2, score: -3),
        ];

        final outcomeNeg = engine.resolveRound(
          players: seededPlayersNegative,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p1': 'tactical_drain:p2'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p1'],
          },
        );

        // The post-vote balance is transferred, then the victim is exactly zero.
        expect(outcomeNeg.scoreDeltas['p1'], -3);
        expect(outcomeNeg.scoreDeltas['p2'], 3);
      },
    );

    test('applies High Stakes skill (+4 on correct, -4 on wrong)', () {
      final engine = GameEngine(random: Random(14));
      final seededPlayers = [
        PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
        PlayerProfile(
          id: 'p1',
          name: 'High Stakes Win',
          avatarIndex: 1,
          score: 0,
        ),
        PlayerProfile(
          id: 'p2',
          name: 'High Stakes Loss',
          avatarIndex: 2,
          score: 0,
        ),
      ];

      final outcome = engine.resolveRound(
        players: seededPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'high_stakes', 'p2': 'high_stakes'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'], // Correct -> +4
          'p2': ['p1'], // Wrong -> -4
        },
      );

      expect(outcome.scoreDeltas['p1'], 4);
      expect(outcome.scoreDeltas['p2'], -4);
    });

    test('applies Diplomatic Immunity skill (0 on wrong vote)', () {
      final engine = GameEngine(random: Random(15));
      final seededPlayers = [
        PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
        PlayerProfile(
          id: 'p1',
          name: 'Immune Player',
          avatarIndex: 1,
          score: 0,
        ),
      ];

      final outcome = engine.resolveRound(
        players: seededPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'diplomatic_immunity'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p1'], // Wrong vote on self/innocent
        },
      );

      expect(outcome.scoreDeltas['p1'], 0);
      expect(outcome.powerEvents.first, contains('الحصانة الدبلوماسية'));
    });

    test(
      'applies Tactical Alliance skill (+3 to both when matching correct vote)',
      () {
        final engine = GameEngine(random: Random(16));
        final seededPlayers = [
          PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
          PlayerProfile(id: 'p1', name: 'Voter A', avatarIndex: 1, score: 0),
          PlayerProfile(id: 'p2', name: 'Ally B', avatarIndex: 2, score: 0),
        ];

        final outcome = engine.resolveRound(
          players: seededPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p1': 'tactical_alliance:p2'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'], // Voted p0
            'p2': ['p0'], // Ally also voted p0
          },
        );

        expect(outcome.scoreDeltas['p1'], 3);
        expect(outcome.scoreDeltas['p2'], 3);
        expect(outcome.powerEvents.first, contains('التحالف التكتيكي'));
      },
    );

    test('applies Robin Hood skill (steals 2 from highest scorer leader)', () {
      final engine = GameEngine(random: Random(18));
      final seededPlayers = [
        PlayerProfile(id: 'p0', name: 'Outsider', avatarIndex: 0, score: 0),
        PlayerProfile(id: 'p1', name: 'Robin Hood', avatarIndex: 1, score: 2),
        PlayerProfile(id: 'p2', name: 'Leader', avatarIndex: 2, score: 10),
      ];

      final outcome = engine.resolveRound(
        players: seededPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'robin_hood'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'], // Correct vote!
          'p2': ['p0'],
        },
      );

      // p1 base vote = 1 + 2 stolen = 3.
      // p2 base vote = 1 - 2 stolen = -1.
      expect(outcome.scoreDeltas['p1'], 3);
      expect(outcome.scoreDeltas['p2'], -1);
      expect(outcome.powerEvents.first, contains('روبن هود'));
    });

    test('applies Outsider 7-Choices Focus', () {
      final engine = GameEngine(random: Random(19));
      final bigPack = CategoryPack(
        id: 'big',
        title: 'Big',
        subtitle: 'pack',
        difficultyLabel: 'Easy',
        isPremium: false,
        topics: List.generate(30, (i) => 'Topic $i'),
      );

      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0'],
        topic: 'Topic 0',
        topicPool: bigPack.topics,
        assignedPowerCards: const {'p0': 'outsider_choices_focus'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
        },
      );

      expect(outcome.outsiderGuessOptions, hasLength(7));
      expect(outcome.outsiderGuessOptions, contains('Topic 0'));
    });

    test('skills scale per choice with three outsiders', () {
      final engine = GameEngine(random: Random(21));
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0', 'p1', 'p2'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {
          'p3': 'double_vote',
          'p4': 'high_stakes',
          'p5': 'diplomatic_immunity',
        },
        voteScoreMultipliers: const {'p3': 2},
        votes: const {
          'p0': ['p1', 'p3', 'p4'],
          'p1': ['p0', 'p3', 'p4'],
          'p2': ['p0', 'p3', 'p4'],
          'p3': ['p0', 'p1', 'p4'],
          'p4': ['p0', 'p1', 'p4'],
          'p5': ['p0', 'p1', 'p4'],
        },
      );

      // Two correct selections and one wrong selection are evaluated
      // independently by every skill.
      expect(outcome.scoreDeltas['p3'], 2);
      expect(outcome.scoreDeltas['p4'], 4);
      expect(outcome.scoreDeltas['p5'], 2);
    });

    test(
      'high-impact skills require a complete correct multi-outsider vote',
      () {
        final engine = GameEngine(random: Random(22));
        final seededPlayers = [
          const PlayerProfile(id: 'p0', name: 'O1', avatarIndex: 0, score: 0),
          const PlayerProfile(id: 'p1', name: 'O2', avatarIndex: 1, score: 0),
          const PlayerProfile(
            id: 'p2',
            name: 'Perfect',
            avatarIndex: 2,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Mixed',
            avatarIndex: 3,
            score: 0,
          ),
          const PlayerProfile(id: 'p4', name: 'Bank', avatarIndex: 4, score: 5),
        ];
        final outcome = engine.resolveRound(
          players: seededPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p2': 'jackpot', 'p3': 'jackpot'},
          votes: const {
            'p0': ['p2', 'p3'],
            'p1': ['p2', 'p3'],
            'p2': ['p0', 'p1'],
            'p3': ['p0', 'p4'],
            'p4': ['p0', 'p1'],
          },
        );

        expect(outcome.scoreDeltas['p2'], 7); // +2 votes and +5 jackpot.
        expect(outcome.scoreDeltas['p3'], 0); // Mixed vote does not trigger it.
      },
    );

    test('each outsider receives options matching only their own skill', () {
      final engine = GameEngine(random: Random(23));
      final bigPack = CategoryPack(
        id: 'big-multi',
        title: 'Big',
        subtitle: 'pack',
        difficultyLabel: 'Easy',
        isPremium: false,
        topics: List.generate(30, (index) => 'Topic $index'),
      );
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0', 'p1'],
        topic: 'Topic 0',
        topicPool: bigPack.topics,
        assignedPowerCards: const {'p0': 'outsider_choices_focus'},
        votes: const {},
      );

      expect(outcome.guessOptionsFor('p0'), hasLength(7));
      expect(outcome.guessOptionsFor('p1'), hasLength(15));
      expect(outcome.guessOptionsFor('p0'), contains('Topic 0'));
      expect(outcome.guessOptionsFor('p1'), contains('Topic 0'));
    });

    test('Chaos Wall always contains the topic and tracks category size', () {
      final engine = GameEngine(random: Random(31));
      final topics = List.generate(50, (index) => 'Topic $index');
      final observedSizes = <int>{};

      for (var round = 0; round < 80; round++) {
        final outcome = engine.resolveRound(
          players: players,
          outsiderIds: const ['p0'],
          topic: 'Topic 49',
          topicPool: topics,
          assignedPowerCards: const {'p0': 'outsider_chaos_wall'},
          votes: const {},
        );
        final options = outcome.guessOptionsFor('p0');
        observedSizes.add(options.length);
        expect(options, contains('Topic 49'));
        expect(options.toSet(), hasLength(options.length));
        expect(options.length, inInclusiveRange(1, 50));
      }

      expect(observedSizes.length, greaterThan(20));
      expect(observedSizes.any((size) => size > 15), isTrue);
    });

    test('point wager transfers the correct stake in both outcomes', () {
      final engine = GameEngine(random: Random(32));
      final base = engine
          .resolveRound(
            players: players,
            outsiderIds: const ['p0'],
            topic: 'Algeria',
            topicPool: pack.topics,
            votes: const {},
          )
          .copyWith(scoreDeltas: {for (final player in players) player.id: 0});

      final correct = engine.finalizeOutsiderGuess(
        outcome: base,
        outsiderId: 'p0',
        guessedTopic: 'Algeria',
        correctPoints: 4,
        wrongPoints: 4,
        wagerTargetId: 'p1',
        wagerStake: 4,
      );
      final wrong = engine.finalizeOutsiderGuess(
        outcome: base,
        outsiderId: 'p0',
        guessedTopic: 'France',
        correctPoints: 4,
        wrongPoints: 4,
        wagerTargetId: 'p1',
        wagerStake: 4,
      );

      expect(correct.scoreDeltas['p0'], 4);
      expect(correct.scoreDeltas['p1'], -4);
      expect(wrong.scoreDeltas['p0'], -4);
      expect(wrong.scoreDeltas['p1'], 2);
    });

    test('sequential elimination resolves only one unique leader', () {
      final engine = GameEngine(random: Random(24));
      final eliminated = engine.resolveRound(
        players: players.take(5).toList(),
        outsiderIds: const ['p0', 'p1'],
        topic: 'Algeria',
        topicPool: pack.topics,
        accusationLimit: 1,
        votes: const {
          'p0': ['p2'],
          'p1': ['p2'],
          'p2': ['p0'],
          'p3': ['p0'],
          'p4': ['p0'],
        },
      );
      final tied = engine.resolveRound(
        players: players.take(4).toList(),
        outsiderIds: const ['p0', 'p1'],
        topic: 'Algeria',
        topicPool: pack.topics,
        accusationLimit: 1,
        votes: const {
          'p0': ['p2'],
          'p1': ['p3'],
          'p2': ['p0'],
          'p3': ['p1'],
        },
      );

      expect(eliminated.latestAccusedPlayerIds, ['p0']);
      expect(eliminated.isTie, isFalse);
      expect(tied.latestAccusedPlayerIds, isEmpty);
      expect(tied.isTie, isTrue);
    });

    test(
      'mergeVotingOutcomes does not multiply Jackpot or Tactical Drain across sequential rounds',
      () {
        final engine = GameEngine(random: Random(35));
        final seededPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider 1',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Outsider 2',
            avatarIndex: 1,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Jackpot Player',
            avatarIndex: 2,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Drain Player',
            avatarIndex: 3,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p4',
            name: 'Victim',
            avatarIndex: 4,
            score: 10,
          ),
        ];

        // Cycle 1: p0 (Outsider 1) eliminated
        final cycle1 = engine.resolveRound(
          players: seededPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {
            'p2': 'jackpot',
            'p3': 'tactical_drain:p4',
          },
          votes: const {
            'p0': ['p2'],
            'p1': ['p2'],
            'p2': ['p0'], // Correct vote on p0
            'p3': ['p0'], // Correct vote on p0
            'p4': ['p0'],
          },
        );

        // Cycle 2: p1 (Outsider 2) eliminated
        final cycle2 = engine.resolveRound(
          players: seededPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {
            'p2': 'jackpot',
            'p3': 'tactical_drain:p4',
          },
          votes: const {
            'p0': ['p2'],
            'p1': ['p2'],
            'p2': ['p1'], // Correct vote on p1
            'p3': ['p1'], // Correct vote on p1
            'p4': ['p1'],
          },
        );

        final merged = engine.mergeVotingOutcomes(
          previous: cycle1,
          current: cycle2,
          survivingOutsiderIds: const [],
          players: seededPlayers,
          assignedPowerCards: const {
            'p2': 'jackpot',
            'p3': 'tactical_drain:p4',
          },
        );

        // Jackpot should be 2 votes + 10 (pot of p4) = 12 (NOT 22 or doubled pot!)
        expect(merged.voteScoreDeltas['p2'], 2);
        expect(merged.scoreDeltas['p2'], 12);

        // Tactical Drain transfers the victim's post-vote balance and leaves it at zero.
        expect(merged.voteScoreDeltas['p3'], 2);
        expect(merged.scoreDeltas['p3'], 14);
        expect(merged.scoreDeltas['p4'], -10);

        // Power events should be deduplicated (not listed twice)
        final jackpotEvents = merged.powerEvents
            .where((e) => e.contains('الجاكبوت'))
            .toList();
        final drainEvents = merged.powerEvents
            .where((e) => e.contains('السطو التكتيكي'))
            .toList();
        expect(jackpotEvents, hasLength(1));
        expect(drainEvents, hasLength(1));
      },
    );

    test(
      'Grand Inversion swaps scores with leader on perfect vote and penalizes on failure',
      () {
        final engine = GameEngine(random: Random(10));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Leader',
            avatarIndex: 1,
            score: 30,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Last Player',
            avatarIndex: 2,
            score: 2,
          ),
        ];

        // Perfect vote
        final success = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p2': 'grand_inversion'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p0'],
          },
        );
        // p2 delta: +1 (vote) + 28 (swap) = 29 -> new score = 2 + 29 = 31 (takes top spot)
        // p1 delta: +1 (vote) - 28 (swap) = -27 -> new score = 30 - 27 = 3 (drops to bottom)
        expect(success.scoreDeltas['p2'], 29);
        expect(success.scoreDeltas['p1'], -27);

        // Failed vote
        final failure = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p2': 'grand_inversion'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p1'],
          }, // Wrong vote on p1
        );
        expect(failure.scoreDeltas['p2'], -6); // -1 (vote) - 5 (penalty)
        expect(failure.scoreDeltas['p1'], 4); // +1 (vote) + 3 (protection)
      },
    );

    test(
      'The Guillotine zeroes leader and grants half points on success, reverses on failure',
      () {
        final engine = GameEngine(random: Random(11));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Leader',
            avatarIndex: 1,
            score: 20,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Attacker',
            avatarIndex: 2,
            score: 10,
          ),
        ];

        // Perfect vote
        final success = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p2': 'guillotine:p1'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p0'],
          },
        );
        expect(success.scoreDeltas['p1'], -20);
        expect(success.scoreDeltas['p2'], 12);

        // Failed vote
        final failure = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p2': 'guillotine:p1'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p1'],
          },
        );
        expect(failure.scoreDeltas['p2'], -10);
        expect(failure.scoreDeltas['p1'], 10);
      },
    );

    test(
      'All-In triples score on success and bankrupts to zero on failure',
      () {
        final engine = GameEngine(random: Random(12));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Gambler',
            avatarIndex: 1,
            score: 15,
          ),
        ];

        final success = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p1': 'all_in'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
          },
        );
        expect(success.scoreDeltas['p1'], 33);

        final failure = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p1': 'all_in'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p1'],
          },
        );
        expect(failure.scoreDeltas['p1'], -15);
      },
    );

    test('Equalizer splits all positive points equally across roster', () {
      final engine = GameEngine(random: Random(13));
      final testPlayers = [
        const PlayerProfile(
          id: 'p0',
          name: 'Outsider',
          avatarIndex: 0,
          score: 0,
        ),
        const PlayerProfile(id: 'p1', name: 'Rich', avatarIndex: 1, score: 30),
        const PlayerProfile(id: 'p2', name: 'Poor 1', avatarIndex: 2, score: 5),
        const PlayerProfile(id: 'p3', name: 'Poor 2', avatarIndex: 3, score: 5),
      ];

      final success = engine.resolveRound(
        players: testPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p2': 'equalizer'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
          'p2': ['p0'],
          'p3': ['p0'],
        },
      );
      // The post-vote pot is split once; every final balance is exactly 10.
      expect(success.scoreDeltas['p0'], 10);
      expect(success.scoreDeltas['p1'], -20);
      expect(success.scoreDeltas['p2'], 5);
      expect(success.scoreDeltas['p3'], 5);
    });

    test(
      'Outsider Coup steals leader score on correct guess, penalizes 6 on failure',
      () {
        final engine = GameEngine(random: Random(14));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Leader',
            avatarIndex: 1,
            score: 25,
          ),
        ];
        final base = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p0': 'outsider_coup'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
          },
        );

        final correct = engine.finalizeOutsiderGuess(
          outcome: base,
          outsiderId: 'p0',
          guessedTopic: 'Algeria',
          powerCardId: 'outsider_coup',
          players: testPlayers,
        );
        expect(correct.scoreDeltas['p0'], 26);
        expect(correct.scoreDeltas['p1'], -25);

        final wrong = engine.finalizeOutsiderGuess(
          outcome: base,
          outsiderId: 'p0',
          guessedTopic: 'France',
          powerCardId: 'outsider_coup',
          players: testPlayers,
        );
        expect(wrong.scoreDeltas['p0'], -6);
      },
    );

    test(
      'Flawless rule denies reward if player voted wrong or was eliminated in sequential mode',
      () {
        final engine = GameEngine(random: Random(15));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider 1',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Outsider 2',
            avatarIndex: 1,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Player With Jackpot',
            avatarIndex: 2,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Innocent',
            avatarIndex: 3,
            score: 10,
          ),
        ];

        // Cycle 1: p2 votes WRONG on p3 (innocent)
        final cycle1 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {'p2': 'jackpot'},
          votes: const {
            'p0': ['p3'],
            'p1': ['p3'],
            'p2': ['p3'],
            'p3': ['p0'],
          },
        );

        // Cycle 2: p2 votes correct on p0
        final cycle2 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {'p2': 'jackpot'},
          votes: const {
            'p0': ['p2'],
            'p1': ['p2'],
            'p2': ['p0'],
            'p3': ['p0'],
          },
        );

        final merged = engine.mergeVotingOutcomes(
          previous: cycle1,
          current: cycle2,
          survivingOutsiderIds: const ['p1'],
        );

        // Because p2 made a wrong vote in cycle 1, Jackpot bonus is DENIED (0 jackpot)
        // Net score delta for p2 = -1 (wrong vote cycle 1) + 1 (correct vote cycle 2) = 0
        expect(merged.voteScoreDeltas['p2'], 0);
        expect(merged.scoreDeltas['p2'], 0);
      },
    );

    test(
      'Outsider Headhunter wipes target score on success and penalizes 4 on failure',
      () {
        final engine = GameEngine(random: Random(16));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Innocent Target',
            avatarIndex: 1,
            score: 18,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Other Player',
            avatarIndex: 2,
            score: 5,
          ),
        ];

        final base = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {'p0': 'outsider_headhunter:p1'},
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p0'],
          },
        );

        // Correct guess on Attempt 1
        final correct = engine.finalizeOutsiderGuess(
          outcome: base,
          outsiderId: 'p0',
          guessedTopic: 'Algeria',
          wagerTargetId: 'p1',
          powerCardId: 'outsider_headhunter',
          players: testPlayers,
        );
        // The full post-vote balance is stolen and the target finishes at zero.
        expect(correct.scoreDeltas['p0'], 19);
        expect(correct.scoreDeltas['p1'], -18);

        // Failed guess
        final wrong = engine.finalizeOutsiderGuess(
          outcome: base,
          outsiderId: 'p0',
          guessedTopic: 'Spain',
          wagerTargetId: 'p1',
          powerCardId: 'outsider_headhunter',
          players: testPlayers,
        );
        // p0 loses 4
        expect(wrong.scoreDeltas['p0'], -4);
        // p1 gets +2 points
        expect(wrong.scoreDeltas['p1'], 3); // 1 (vote) + 2 (penalty reward) = 3
      },
    );

    test(
      'Tactical Drain is strictly denied across cycles if player made any wrong vote, and victim is untouched',
      () {
        final engine = GameEngine(random: Random(17));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Drainer',
            avatarIndex: 1,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Victim',
            avatarIndex: 2,
            score: 12,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Other Innocent',
            avatarIndex: 3,
            score: 0,
          ),
        ];

        // Cycle 1: p1 votes wrong on p3
        final cycle1 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {'p1': 'tactical_drain:p2'},
          votes: const {
            'p0': ['p3'],
            'p1': ['p3'],
            'p2': ['p3'],
            'p3': ['p0'],
          },
        );

        // Cycle 2: p1 votes correct on p0
        final cycle2 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          assignedPowerCards: const {'p1': 'tactical_drain:p2'},
          votes: const {
            'p0': ['p2'],
            'p1': ['p0'],
            'p2': ['p0'],
          },
        );

        final merged = engine.mergeVotingOutcomes(
          previous: cycle1,
          current: cycle2,
          survivingOutsiderIds: const [],
          players: testPlayers,
          assignedPowerCards: const {'p1': 'tactical_drain:p2'},
        );

        // p1 made a wrong vote in cycle 1, so tactical drain is DENIED:
        // p1 score delta = -1 (cycle 1) + 1 (cycle 2) = 0
        expect(merged.scoreDeltas['p1'], 0);
        // Victim p2 is unharmed (0 stolen):
        // p2 score delta = -1 (cycle 1) + 1 (cycle 2) = 0
        expect(merged.scoreDeltas['p2'], 0);
        // No tactical drain power event
        expect(
          merged.powerEvents.where((e) => e.contains('السطو التكتيكي')),
          isEmpty,
        );
      },
    );

    test(
      'Absolute Immunity blocks Tactical Drain and leaves both scores intact',
      () {
        final engine = GameEngine(random: Random(20));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Drainer',
            avatarIndex: 1,
            score: 2,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Immune Victim',
            avatarIndex: 2,
            score: 15,
          ),
        ];

        final outcome = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Algeria',
          topicPool: pack.topics,
          assignedPowerCards: const {
            'p1': 'tactical_drain:p2',
            'p2': 'absolute_immunity',
          },
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'], // Perfect vote
            'p2': ['p0'],
          },
        );

        // p1 gets +1 (vote), but 0 drain points (blocked)
        expect(outcome.scoreDeltas['p1'], 1);
        // p2 gets +1 (vote), 0 stolen points (protected)
        expect(outcome.scoreDeltas['p2'], 1);
        expect(
          outcome.powerEvents.any((e) => e.contains('الحصانة: تصدّى')),
          isTrue,
        );
      },
    );

    test('Absolute Immunity excludes player from Jackpot pot', () {
      final engine = GameEngine(random: Random(21));
      final testPlayers = [
        const PlayerProfile(
          id: 'p0',
          name: 'Outsider',
          avatarIndex: 0,
          score: 0,
        ),
        const PlayerProfile(
          id: 'p1',
          name: 'Jackpot Player',
          avatarIndex: 1,
          score: 0,
        ),
        const PlayerProfile(
          id: 'p2',
          name: 'Normal Player',
          avatarIndex: 2,
          score: 10,
        ),
        const PlayerProfile(
          id: 'p3',
          name: 'Immune Player',
          avatarIndex: 3,
          score: 20,
        ),
      ];

      final outcome = engine.resolveRound(
        players: testPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'jackpot', 'p3': 'absolute_immunity'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
          'p2': ['p0'],
          'p3': ['p0'],
        },
      );

      // Pot should only include p2 (10 points), NOT p3 (20 points):
      // p1 gain = 10 (pot) + 1 (vote) = 11
      expect(outcome.scoreDeltas['p1'], 11);
    });

    test('Robin Hood steals exactly 1/4 of leader points', () {
      final engine = GameEngine(random: Random(22));
      final testPlayers = [
        const PlayerProfile(
          id: 'p0',
          name: 'Outsider',
          avatarIndex: 0,
          score: 0,
        ),
        const PlayerProfile(
          id: 'p1',
          name: 'Robin Hood',
          avatarIndex: 1,
          score: 0,
        ),
        const PlayerProfile(
          id: 'p2',
          name: 'Leader',
          avatarIndex: 2,
          score: 16,
        ),
      ];

      final outcome = engine.resolveRound(
        players: testPlayers,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'robin_hood'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
          'p2': ['p0'],
        },
      );

      // 16 / 4 = 4 points stolen
      // p1 score delta = 1 (vote) + 4 (stolen) = 5
      // p2 score delta = 1 (vote) - 4 (stolen) = -3
      expect(outcome.scoreDeltas['p1'], 5);
      expect(outcome.scoreDeltas['p2'], -3);
      expect(outcome.powerEvents.first, contains('ربع نقاط'));
    });

    test(
      'Sequential elimination (Among Us mode) with 1 outsider across 2 cycles',
      () {
        final engine = GameEngine(random: Random(23));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Innocent 1',
            avatarIndex: 1,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Innocent 2',
            avatarIndex: 2,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Innocent 3',
            avatarIndex: 3,
            score: 0,
          ),
        ];

        // Cycle 1: p3 (innocent) is falsely accused and eliminated
        final cycle1 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Egypt',
          topicPool: pack.topics,
          accusationLimit: 1,
          votes: const {
            'p0': ['p3'],
            'p1': ['p3'],
            'p2': ['p3'],
            'p3': ['p0'],
          },
        );
        expect(cycle1.accusedPlayerIds, ['p3']);
        expect(cycle1.survivingOutsiderIds, [
          'p0',
        ]); // Outsider survived cycle 1

        // Cycle 2: p0 (outsider) is correctly accused and eliminated
        final cycle2 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0'],
          topic: 'Egypt',
          topicPool: pack.topics,
          accusationLimit: 1,
          votes: const {
            'p0': ['p1'],
            'p1': ['p0'],
            'p2': ['p0'],
          },
        );
        expect(cycle2.accusedPlayerIds, ['p0']);
        expect(cycle2.survivingOutsiderIds, isEmpty); // Outsider caught!

        final merged = engine.mergeVotingOutcomes(
          previous: cycle1,
          current: cycle2,
          survivingOutsiderIds: const [],
          players: testPlayers,
        );

        expect(merged.outsiderCaught, isTrue);
        expect(merged.accusedPlayerIds, containsAll(['p3', 'p0']));
      },
    );

    test(
      'Sequential elimination (Among Us mode) with 2 outsiders across 3 cycles',
      () {
        final engine = GameEngine(random: Random(24));
        final testPlayers = [
          const PlayerProfile(
            id: 'p0',
            name: 'Outsider 1',
            avatarIndex: 0,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p1',
            name: 'Outsider 2',
            avatarIndex: 1,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p2',
            name: 'Innocent 1',
            avatarIndex: 2,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p3',
            name: 'Innocent 2',
            avatarIndex: 3,
            score: 0,
          ),
          const PlayerProfile(
            id: 'p4',
            name: 'Innocent 3',
            avatarIndex: 4,
            score: 0,
          ),
        ];

        // Cycle 1: p4 (innocent) is eliminated
        final cycle1 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          votes: const {
            'p0': ['p4'],
            'p1': ['p4'],
            'p2': ['p4'],
            'p3': ['p4'],
            'p4': ['p0'],
          },
        );
        expect(cycle1.accusedPlayerIds, ['p4']);
        expect(cycle1.survivingOutsiderIds, ['p0', 'p1']);

        // Cycle 2: p0 (outsider 1) is eliminated
        final cycle2 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p0', 'p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          votes: const {
            'p0': ['p2'],
            'p1': ['p0'],
            'p2': ['p0'],
            'p3': ['p0'],
          },
        );
        expect(cycle2.accusedPlayerIds, ['p0']);
        expect(cycle2.survivingOutsiderIds, ['p1']);

        final merged1and2 = engine.mergeVotingOutcomes(
          previous: cycle1,
          current: cycle2,
          survivingOutsiderIds: ['p1'],
          players: testPlayers,
        );
        expect(merged1and2.survivingOutsiderIds, ['p1']);

        // Cycle 3: p1 (outsider 2) is eliminated (p0 was already caught in cycle 2)
        final cycle3 = engine.resolveRound(
          players: testPlayers,
          outsiderIds: const ['p1'],
          topic: 'Algeria',
          topicPool: pack.topics,
          accusationLimit: 1,
          votes: const {
            'p1': ['p2'],
            'p2': ['p1'],
            'p3': ['p1'],
          },
        );
        expect(cycle3.accusedPlayerIds, ['p1']);
        expect(cycle3.survivingOutsiderIds, isEmpty);

        final mergedFinal = engine.mergeVotingOutcomes(
          previous: merged1and2,
          current: cycle3,
          survivingOutsiderIds: const [],
          players: testPlayers,
        );

        expect(mergedFinal.outsiderCaught, isTrue);
        expect(mergedFinal.accusedPlayerIds, containsAll(['p4', 'p0', 'p1']));
      },
    );

    test('score ledger always reconciles with every final score delta', () {
      final engine = GameEngine(random: Random(91));
      final players = [
        const PlayerProfile(
          id: 'p0',
          name: 'Outsider',
          avatarIndex: 0,
          score: 2,
        ),
        const PlayerProfile(
          id: 'p1',
          name: 'Drainer',
          avatarIndex: 1,
          score: 5,
        ),
        const PlayerProfile(id: 'p2', name: 'Victim', avatarIndex: 2, score: 9),
      ];
      final voting = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {'p1': 'tactical_drain:p2'},
        votes: const {
          'p0': ['p1'],
          'p1': ['p0'],
          'p2': ['p1'],
        },
      );
      final outcome = engine.finalizeOutsiderGuess(
        outcome: voting,
        outsiderId: 'p0',
        guessedTopic: 'Algeria',
        players: players,
      );

      for (final player in players) {
        final entries = outcome.scoreLedger[player.id]!;
        expect(
          entries.fold<int>(0, (sum, entry) => sum + entry.delta),
          outcome.scoreDeltas[player.id],
        );
        expect(entries.first.balanceBefore, player.score);
        expect(
          entries.last.balanceAfter,
          player.score + (outcome.scoreDeltas[player.id] ?? 0),
        );
      }
    });

    test('Diplomatic Immunity also blocks Karma wrong-vote transfer', () {
      final engine = GameEngine(random: Random(92));
      final players = [
        const PlayerProfile(
          id: 'p0',
          name: 'Outsider',
          avatarIndex: 0,
          score: 0,
        ),
        const PlayerProfile(
          id: 'p1',
          name: 'Diplomat',
          avatarIndex: 1,
          score: 4,
        ),
        const PlayerProfile(id: 'p2', name: 'Karma', avatarIndex: 2, score: 4),
      ];
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0'],
        topic: 'Algeria',
        topicPool: pack.topics,
        assignedPowerCards: const {
          'p1': 'diplomatic_immunity',
          'p2': 'karma_backfire',
        },
        votes: const {
          'p0': ['p1'],
          'p1': ['p2'],
          'p2': ['p0'],
        },
      );

      expect(outcome.scoreDeltas['p1'], 0);
      expect(outcome.scoreDeltas['p2'], 1);
    });
  });
}
