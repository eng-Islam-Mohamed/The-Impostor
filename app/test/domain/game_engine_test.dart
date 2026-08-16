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

        expect(outcomePos.scoreDeltas['p1'], 8);
        expect(outcomePos.scoreDeltas['p2'], -8);

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

        // p1 gets +1 (vote) + (-3) = -2.
        // p2 gets -1 (vote) - (-3) = +2 (so final score becomes -3 + 2 + 1 = 0).
        expect(outcomeNeg.scoreDeltas['p1'], -2);
        expect(outcomeNeg.scoreDeltas['p2'], 2);
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
  });
}
