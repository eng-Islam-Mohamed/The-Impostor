import 'dart:math';

import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameEngine', () {
    final players = List.generate(
      4,
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
      topics: ['قهوة'],
    );

    test('creates exactly one outsider', () {
      final engine = GameEngine(random: Random(2));
      final round = engine.createRound(players: players, pack: pack);
      final outsiderCount = round.assignments.where((item) => item.isOutsider).length;

      expect(round.topic, 'قهوة');
      expect(outsiderCount, 1);
    });

    test('awards outsider when group misses', () {
      final engine = GameEngine(random: Random(3));
      final outcome = engine.resolveRound(
        players: players,
        outsiderId: 'p0',
        topic: 'قهوة',
        votes: const {
          'p0': 'p1',
          'p1': 'p2',
          'p2': 'p2',
          'p3': 'p2',
        },
      );

      expect(outcome.outsiderCaught, isFalse);
      expect(outcome.scoreDeltas['p0'], 3);
      expect(outcome.mostVotedPlayerId, 'p2');
    });
  });
}
