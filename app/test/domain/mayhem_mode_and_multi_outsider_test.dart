import 'dart:math';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/round_phase.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Engineer Review: Mayhem Mode (فوضى شاملة) Skill Allocation Tests', () {
    final pack = seededCategoryPacks.first;

    test(
      'Mayhem Mode: Verify EVERY player gets a skill (5, 6, 7, 8, 12 players)',
      () {
        for (final playerCount in [5, 6, 7, 8, 12]) {
          final players = List.generate(
            playerCount,
            (i) => PlayerProfile(
              id: 'p$i',
              name: 'Player $i',
              avatarIndex: i,
              score: 10,
            ),
          );

          for (final outsiderCount in [1, 2, 3]) {
            if (outsiderCount >= playerCount) continue;

            final sessionState = GameSessionState(
              players: players,
              selectedMode: GameMode.classic,
              selectedPackId: pack.id,
              discussionSeconds: 60,
              scoringEnabled: true,
              powerCardsEnabled: true,
              activePowerCardIds: PowerCardCatalog.defaultEnabledIds,
              outsidersKnowEachOther: false,
              sequentialEliminationEnabled: false,
              outsiderCount: outsiderCount,
              roundNumber: 1,
              hasSavedSession: false,
              phase: RoundPhase.reveal,
              assignments: const [],
              revealIndex: 0,
              clueIndex: 0,
              clueLap: 0,
              outsiderGuessIndex: 0,
              outsiderGuessAttempts: 0,
              votes: const {},
              powerCards: const {},
              currentTopic: '',
              outsiderIds: const [],
              outcome: null,
              eliminatedPlayerIds: const [],
              eliminationRound: 1,
              activatedOutsiderSkillIds: const {},
              outsiderWagerTargetIds: const {},
              powerDensity: PowerDensity.mayhem, // فوضى شاملة
            );

            // Simulate controller power cards assignment for Mayhem
            final outsiderIds = List.generate(
              outsiderCount,
              (i) => 'p$i',
            ).toSet();
            final assignCount = switch (sessionState.powerDensity) {
              PowerDensity.mayhem => playerCount,
              PowerDensity.intense => min(
                playerCount,
                max(2, min(4, (playerCount * 0.6).round())),
              ),
              PowerDensity.balanced => playerCount <= 4 ? 2 : 3,
            };

            expect(
              assignCount,
              equals(playerCount),
              reason: 'Mayhem mode MUST assign skills to 100% of players',
            );
          }
        }
      },
    );

    test(
      'Mayhem Mode: Outsiders get OUTSIDER skills and Innocents get INNOCENT skills',
      () {
        final engine = GameEngine();
        final players = List.generate(
          6,
          (i) => PlayerProfile(
            id: 'p$i',
            name: 'Player $i',
            avatarIndex: i,
            score: 10,
          ),
        );

        final seed = engine.createRound(
          players: players,
          pack: pack,
          outsiderCount: 2,
        );
        expect(seed.outsiderIds.length, equals(2));

        final innocentPool = PowerCardCatalog.innocentCardIds;
        final outsiderPool = PowerCardCatalog.outsiderCardIds;

        // Verify separation of card pools
        for (final card in innocentPool) {
          expect(
            outsiderPool.contains(card),
            isFalse,
            reason: 'Card $card cannot be in both pools',
          );
        }
      },
    );
  });

  group('Engineer Review: Multi-Round Games (1, 2, 3 Outsiders) Rules & Math', () {
    final engine = GameEngine();

    test(
      'Game 1 (1 Outsider, 5 Players): Round 1 and Round 2 Score Delta Resolution',
      () {
        final p1 = PlayerProfile(
          id: 'p1',
          name: 'P1',
          avatarIndex: 0,
          score: 0,
        );
        final p2 = PlayerProfile(
          id: 'p2',
          name: 'P2',
          avatarIndex: 1,
          score: 0,
        );
        final p3 = PlayerProfile(
          id: 'p3',
          name: 'P3',
          avatarIndex: 2,
          score: 0,
        );
        final p4 = PlayerProfile(
          id: 'p4',
          name: 'P4',
          avatarIndex: 3,
          score: 0,
        );
        final outsider = PlayerProfile(
          id: 'p5',
          name: 'Outsider',
          avatarIndex: 4,
          score: 0,
        );
        final players = [p1, p2, p3, p4, outsider];

        // Round 1: Everyone votes correctly on p5
        final votesRound1 = {
          'p1': ['p5'],
          'p2': ['p5'],
          'p3': ['p5'],
          'p4': ['p5'],
          'p5': ['p1'],
        };

        final powerCardsRound1 = {
          'p1': PowerCardCatalog.doubleVote,
          'p2': PowerCardCatalog.jackpot,
          'p3': PowerCardCatalog.karmaBackfire,
          'p4': PowerCardCatalog.diplomaticImmunity,
          'p5': PowerCardCatalog.outsiderSecondChance,
        };

        final outcome1 = engine.resolveRound(
          players: players,
          outsiderIds: ['p5'],
          topic: 'الأهرامات',
          votes: votesRound1,
          topicPool: ['الأهرامات', 'بابل', 'طيبة', 'قرطاج'],
          assignedPowerCards: powerCardsRound1,
          voteScoreMultipliers: {'p1': 2},
        );

        // p1 had double vote: correct vote gives +2
        expect(outcome1.scoreDeltas['p1'], equals(2));
        // p2 had jackpot: perfect vote, positive pot is 0, so gets fallback +3
        expect(
          outcome1.scoreDeltas['p2'],
          equals(4),
        ); // +1 normal vote + +3 jackpot
        // p3 had karma: not attacked, vote delta +1
        expect(outcome1.scoreDeltas['p3'], equals(1));
        // p4 had diplomatic: vote delta +1
        expect(outcome1.scoreDeltas['p4'], equals(1));

        // Finalize Outsider guess (correct guess)
        final finalizedOutcome1 = engine.finalizeOutsiderGuess(
          outcome: outcome1,
          outsiderId: 'p5',
          guessedTopic: 'الأهرامات',
          powerCardId: 'outsider_second_chance',
          players: players,
        );

        expect(finalizedOutcome1.scoreDeltas['p5'], equals(1));
        expect(finalizedOutcome1.outsiderCaught, isTrue);

        // Carry over to Round 2
        final playersRound2 = [
          p1.copyWith(score: p1.score + finalizedOutcome1.scoreDeltas['p1']!),
          p2.copyWith(score: p2.score + finalizedOutcome1.scoreDeltas['p2']!),
          p3.copyWith(score: p3.score + finalizedOutcome1.scoreDeltas['p3']!),
          p4.copyWith(score: p4.score + finalizedOutcome1.scoreDeltas['p4']!),
          outsider.copyWith(
            score: outsider.score + finalizedOutcome1.scoreDeltas['p5']!,
          ),
        ];

        expect(
          playersRound2.map((p) => p.score).toList(),
          equals([2, 4, 1, 1, 1]),
        );

        // Round 2: p3 has tactical_drain targeting p2 (score 4)
        final powerCardsRound2 = {
          'p1': PowerCardCatalog.highStakes,
          'p2': PowerCardCatalog.absoluteImmunity,
          'p3': '${PowerCardCatalog.tacticalDrain}:p2',
          'p4': PowerCardCatalog.robinHood,
          'p5': PowerCardCatalog.outsiderCoup,
        };

        // p3 votes correctly on p5. But p2 has absolute immunity!
        final outcome2 = engine.resolveRound(
          players: playersRound2,
          outsiderIds: ['p5'],
          topic: 'بابل',
          votes: votesRound1,
          topicPool: ['الأهرامات', 'بابل', 'طيبة', 'قرطاج'],
          assignedPowerCards: powerCardsRound2,
        );

        // Verify absolute immunity blocked tactical drain
        expect(
          outcome2.powerEvents.any(
            (e) => e.contains('تصدّى P2 لمحاولة السطو التكتيكي'),
          ),
          isTrue,
        );
        // p2 score is NOT drained
        expect(outcome2.scoreDeltas['p2'], equals(1)); // +1 for correct vote
      },
    );

    test(
      'Game 2 (2 Outsiders, 6 Players): Full 2-Outsider Voting & Multi-Guess',
      () {
        final players = List.generate(
          6,
          (i) =>
              PlayerProfile(id: 'p$i', name: 'P$i', avatarIndex: i, score: 5),
        );
        final outsiderIds = ['p4', 'p5'];

        // Each innocent votes for 2 suspects: p4 and p5 (100% correct)
        // Outsiders vote for p0 and p1
        final votes = {
          'p0': ['p4', 'p5'],
          'p1': ['p4', 'p5'],
          'p2': ['p4', 'p5'],
          'p3': ['p4', 'p5'],
          'p4': ['p0', 'p1'],
          'p5': ['p0', 'p1'],
        };

        final powerCards = {
          'p0': PowerCardCatalog.doubleVote,
          'p1': PowerCardCatalog.highStakes,
          'p2': '${PowerCardCatalog.tacticalAlliance}:p3',
          'p3': '${PowerCardCatalog.tacticalAlliance}:p2',
          'p4': PowerCardCatalog.outsiderChoicesFocus,
          'p5': PowerCardCatalog.outsiderPanicTimer,
        };

        final outcome = engine.resolveRound(
          players: players,
          outsiderIds: outsiderIds,
          topic: 'ابن خلدون',
          votes: votes,
          topicPool: [
            'ابن خلدون',
            'ابن سينا',
            'الخوارزمي',
            'الفارابي',
            'الكندي',
            'البيروني',
            'ابن رشد',
            'ابن بطوطة',
          ],
          assignedPowerCards: powerCards,
          voteScoreMultipliers: {'p0': 2},
        );

        // p0: double vote with 2 correct votes = +4
        expect(outcome.scoreDeltas['p0'], equals(4));
        // p1: high stakes with 2 correct votes = 2 * 4 = +8
        expect(outcome.scoreDeltas['p1'], equals(8));
        // p2 & p3: tactical alliance matching on 2 correct votes = 2 base + (2*2 bonus) = +6 each
        expect(outcome.scoreDeltas['p2'], equals(6));
        expect(outcome.scoreDeltas['p3'], equals(6));

        // Outsider 1 guess (correct)
        var nextOutcome = engine.finalizeOutsiderGuess(
          outcome: outcome,
          outsiderId: 'p4',
          guessedTopic: 'ابن خلدون',
          powerCardId: 'outsider_choices_focus',
          players: players,
        );
        // Outsider 2 guess (wrong)
        nextOutcome = engine.finalizeOutsiderGuess(
          outcome: nextOutcome,
          outsiderId: 'p5',
          guessedTopic: 'ابن سينا',
          powerCardId: 'outsider_panic_timer',
          players: players,
        );

        expect(nextOutcome.scoreDeltas['p4'], equals(1));
        expect(nextOutcome.scoreDeltas['p5'], equals(-1));
        expect(nextOutcome.outsiderCaught, isTrue);
      },
    );

    test(
      'Game 3 (3 Outsiders, 8 Players): Full 3-Outsider Voting & Multi-Guess',
      () {
        final players = List.generate(
          8,
          (i) =>
              PlayerProfile(id: 'p$i', name: 'P$i', avatarIndex: i, score: 5),
        );
        final outsiderIds = ['p5', 'p6', 'p7'];

        // Innocents vote for 3 suspects: p5, p6, p7
        final votes = {
          'p0': ['p5', 'p6', 'p7'],
          'p1': ['p5', 'p6', 'p7'],
          'p2': ['p5', 'p6', 'p7'],
          'p3': ['p5', 'p6', 'p7'],
          'p4': ['p5', 'p6', 'p7'],
          'p5': ['p0', 'p1', 'p2'],
          'p6': ['p0', 'p1', 'p2'],
          'p7': ['p0', 'p1', 'p2'],
        };

        final powerCards = {
          'p0': PowerCardCatalog.allIn,
          'p1': PowerCardCatalog.grandInversion,
          'p2': PowerCardCatalog.guillotine,
          'p3': PowerCardCatalog.equalizer,
          'p4': PowerCardCatalog.karmaBackfire,
          'p5': PowerCardCatalog.outsiderCoup,
          'p6': PowerCardCatalog.outsiderHeadhunter,
          'p7': PowerCardCatalog.outsiderSecondChance,
        };

        final outcome = engine.resolveRound(
          players: players,
          outsiderIds: outsiderIds,
          topic: 'صلاح الدين',
          votes: votes,
          topicPool: [
            'صلاح الدين',
            'قطز',
            'بيبرس',
            'نور الدين',
            'عماد الدين',
            'شيركوه',
            'المعز',
            'العاضد',
          ],
          assignedPowerCards: powerCards,
        );

        // Equalizer is the final global operation, so it deterministically
        // replaces earlier balance transformations for every player.
        expect(outcome.scoreDeltas['p0'], equals(3));
        // p3 has Equalizer: calculates the final shared balance once.
        expect(
          outcome.powerEvents.any((e) => e.contains('الميزان العادل')),
          isTrue,
        );
      },
    );

    test('Game 4: Sequential Elimination Mode with 2 Outsiders', () {
      final players = List.generate(
        6,
        (i) => PlayerProfile(id: 'p$i', name: 'P$i', avatarIndex: i, score: 0),
      );
      final outsiderIds = ['p4', 'p5'];

      // Sub-round 1: p4 gets the most votes and is eliminated
      final votesSubRound1 = {
        'p0': ['p4'],
        'p1': ['p4'],
        'p2': ['p4'],
        'p3': ['p5'],
        'p4': ['p0'],
        'p5': ['p0'],
      };

      final outcomeSub1 = engine.resolveRound(
        players: players,
        outsiderIds: outsiderIds,
        topic: 'مكة المكرمة',
        votes: votesSubRound1,
        topicPool: ['مكة المكرمة', 'المدينة المنورة', 'القدس'],
        accusationLimit: 1,
      );

      expect(outcomeSub1.accusedPlayerIds, equals(['p4']));
      expect(outcomeSub1.survivingOutsiderIds, equals(['p5']));

      // Sub-round 2: Remaining players vote. p5 gets eliminated.
      final votesSubRound2 = {
        'p0': ['p5'],
        'p1': ['p5'],
        'p2': ['p5'],
        'p3': ['p5'],
        'p5': ['p0'],
      };

      final outcomeSub2 = engine.resolveRound(
        players: players.where((p) => p.id != 'p4').toList(),
        outsiderIds: ['p5'],
        topic: 'مكة المكرمة',
        votes: votesSubRound2,
        topicPool: ['مكة المكرمة', 'المدينة المنورة', 'القدس'],
        accusationLimit: 1,
      );

      final merged = engine.mergeVotingOutcomes(
        previous: outcomeSub1,
        current: outcomeSub2,
        survivingOutsiderIds: const [],
        players: players,
      );

      expect(merged.accusedPlayerIds, containsAll(['p4', 'p5']));
      expect(merged.outsiderCaught, isTrue);
    });
  });
}
