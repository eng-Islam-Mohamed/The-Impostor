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
        name: 'لاعب ${index + 1}',
        avatarIndex: index,
        score: 0,
      ),
    );
    const pack = CategoryPack(
      id: 'test',
      title: 'اختبار',
      subtitle: 'pack',
      difficultyLabel: 'سهل',
      isPremium: false,
      topics: ['الجزائر', 'فرنسا', 'مصر', 'اليابان', 'الصين', 'البرازيل'],
    );

    test('creates requested number of outsiders', () {
      final engine = GameEngine(random: Random(2));
      final round = engine.createRound(
        players: players,
        pack: pack,
        outsiderCount: 2,
      );
      final outsiderCount = round.assignments.where((item) => item.isOutsider).length;

      expect(pack.topics, contains(round.topic));
      expect(outsiderCount, 2);
      expect(round.outsiderIds, hasLength(2));
    });

    test('awards plus one for votes targeting any outsider', () {
      final engine = GameEngine(random: Random(3));
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p0', 'p4'],
        topic: 'الجزائر',
        topicPool: pack.topics,
        votes: const {
          'p0': 'p1',
          'p1': 'p0',
          'p2': 'p4',
          'p3': 'p4',
          'p4': 'p1',
          'p5': 'p4',
        },
      );

      expect(outcome.outsiderCaught, isTrue);
      expect(outcome.voteScoreDeltas['p0'], 0);
      expect(outcome.voteScoreDeltas['p4'], 0);
      expect(outcome.voteScoreDeltas['p1'], 1);
      expect(outcome.voteScoreDeltas['p2'], 1);
      expect(outcome.voteScoreDeltas['p3'], 1);
      expect(outcome.voteScoreDeltas['p5'], 1);
      expect(outcome.outsiderGuessOptions, hasLength(pack.topics.length));
    });

    test('each outsider guess adds its own final point swing', () {
      final engine = GameEngine(random: Random(5));
      final outcome = engine.resolveRound(
        players: players,
        outsiderIds: const ['p2', 'p5'],
        topic: 'مصر',
        topicPool: pack.topics,
        votes: const {
          'p0': 'p2',
          'p1': 'p2',
          'p2': 'p1',
          'p3': 'p0',
          'p4': 'p5',
          'p5': 'p1',
        },
      );

      final firstFinalized = engine.finalizeOutsiderGuess(
        outcome: outcome,
        outsiderId: 'p2',
        guessedTopic: 'مصر',
      );
      final secondFinalized = engine.finalizeOutsiderGuess(
        outcome: firstFinalized,
        outsiderId: 'p5',
        guessedTopic: 'اليابان',
      );

      expect(secondFinalized.outsiderGuessResults['p2'], isTrue);
      expect(secondFinalized.outsiderGuessResults['p5'], isFalse);
      expect(secondFinalized.scoreDeltas['p2'], 1);
      expect(secondFinalized.scoreDeltas['p5'], -1);
      expect(secondFinalized.outsiderGuessOptions, contains('مصر'));
    });
  });
}
