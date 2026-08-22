import 'dart:math';

import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:collection/collection.dart';

class GameRoundSeed {
  const GameRoundSeed({
    required this.topic,
    required this.outsiderIds,
    required this.assignments,
  });

  final String topic;
  final List<String> outsiderIds;
  final List<SecretAssignment> assignments;
}

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  GameRoundSeed createRound({
    required List<PlayerProfile> players,
    required CategoryPack pack,
    required int outsiderCount,
  }) {
    if (players.isEmpty ||
        outsiderCount < 1 ||
        outsiderCount >= players.length) {
      throw ArgumentError(
        'The outsider count must leave at least one insider.',
      );
    }
    final topics = pack.topics
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (topics.isEmpty) {
      throw ArgumentError('The selected category has no playable subjects.');
    }

    final shuffledPlayers = [...players]..shuffle(_random);
    final outsiders = shuffledPlayers
        .take(outsiderCount)
        .map((player) => player.id)
        .toSet();
    final topic = topics[_random.nextInt(topics.length)];
    final assignments = players
        .map(
          (player) => SecretAssignment(
            playerId: player.id,
            playerName: player.name,
            topic: topic,
            isOutsider: outsiders.contains(player.id),
          ),
        )
        .toList(growable: false);

    return GameRoundSeed(
      topic: topic,
      outsiderIds: outsiders.toList(growable: false),
      assignments: assignments,
    );
  }

  RoundOutcome resolveRound({
    required List<PlayerProfile> players,
    required List<String> outsiderIds,
    required String topic,
    required Map<String, List<String>> votes,
    required List<String> topicPool,
    Map<String, int> voteScoreMultipliers = const {},
    Map<String, String> assignedPowerCards = const {},
    int? accusationLimit,
  }) {
    final outsiderSet = outsiderIds.toSet();
    final counts = <String, int>{};
    for (final suspectIds in votes.values) {
      for (final suspectId in suspectIds.toSet()) {
        counts.update(suspectId, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final accusation = _buildAccusation(
      counts: counts,
      limit: accusationLimit ?? outsiderIds.length,
    );
    final accusedPlayerIds = accusation.playerIds;
    final survivingOutsiderIds = outsiderIds
        .where((id) => !accusedPlayerIds.contains(id))
        .toList(growable: false);
    final outsiderCaught = survivingOutsiderIds.length != outsiderIds.length;

    final deltas = <String, int>{};
    final voteScoreDeltas = <String, int>{};
    final powerEvents = <String>[];

    for (final player in players) {
      if (outsiderSet.contains(player.id)) {
        voteScoreDeltas[player.id] = 0;
        deltas[player.id] = 0;
        continue;
      }
      final playerVotes = (votes[player.id] ?? const <String>[]).toSet();
      final correct = playerVotes.where(outsiderSet.contains).length;
      final wrong = playerVotes.length - correct;
      final card = _cardId(assignedPowerCards[player.id]);
      final multiplier = voteScoreMultipliers[player.id] ?? 1;
      final score = switch (card) {
        'high_stakes' => (correct - wrong) * 4,
        'diplomatic_immunity' => correct * multiplier,
        _ => (correct - wrong) * multiplier,
      };
      voteScoreDeltas[player.id] = score;
      deltas[player.id] = score;

      if (card == 'diplomatic_immunity' && wrong > 0) {
        powerEvents.add(
          '🛡️ الحصانة الدبلوماسية حمت ${player.name} من $wrong عقوبة تصويت.',
        );
      }
      if (card == 'high_stakes' && playerVotes.isNotEmpty) {
        powerEvents.add(
          '🔥 الرهان العالي: نتيجة ${player.name} في التصويت ${_signed(score)}.',
        );
      }
    }

    // These high-impact powers trigger only when every submitted choice is an
    // outsider. This keeps them fair with one, two, or three required choices.
    for (final entry in assignedPowerCards.entries) {
      final playerId = entry.key;
      if (outsiderSet.contains(playerId)) continue;
      final player = players.firstWhereOrNull((item) => item.id == playerId);
      if (player == null) continue;
      final playerVotes = (votes[playerId] ?? const <String>[]).toSet();
      final perfectVote =
          playerVotes.isNotEmpty && playerVotes.every(outsiderSet.contains);
      final card = _cardId(entry.value);

      if (card == 'jackpot' && perfectVote) {
        // Players with absolute_immunity are excluded from the jackpot pot.
        final immuneIds = assignedPowerCards.entries
            .where((e) => _cardId(e.value) == 'absolute_immunity')
            .map((e) => e.key)
            .toSet();
        final positivePot = players
            .where(
              (item) =>
                  item.id != playerId &&
                  item.score > 0 &&
                  !immuneIds.contains(item.id),
            )
            .fold<int>(0, (sum, item) => sum + item.score);
        final gain = positivePot > 0 ? positivePot : 3;
        deltas[playerId] = (deltas[playerId] ?? 0) + gain;
        final immuneNote = immuneIds.isNotEmpty
            ? ' (رصيد اللاعبين ذوي الحصانة محذوف)'
            : '';
        powerEvents.add(
          '🎰 الجاكبوت: ${player.name} كسب +$gain نقطة بعد تصويت كامل وصحيح.$immuneNote',
        );
      }

      if (card == 'tactical_drain' && perfectVote) {
        final targetId = _targetId(entry.value);
        final target = players.firstWhereOrNull((item) => item.id == targetId);
        if (target != null) {
          // Check if target has absolute_immunity.
          final targetCard = _cardId(assignedPowerCards[target.id]);
          if (targetCard == 'absolute_immunity') {
            powerEvents.add(
              '🛡️ الحصانة: تصدّى ${target.name} لمحاولة السطو التكتيكي من ${player.name} بنجاح!',
            );
          } else {
            final targetBalance = target.score + (deltas[target.id] ?? 0);
            deltas[playerId] = (deltas[playerId] ?? 0) + targetBalance;
            deltas[target.id] = -target.score;
            powerEvents.add(
              '⚡ السطو التكتيكي: ${player.name} نقل رصيد ${target.name} إلى حسابه.',
            );
          }
        }
      }

      if (card == 'robin_hood' && perfectVote) {
        // Skip leaders with absolute_immunity.
        final immuneIds = assignedPowerCards.entries
            .where((e) => _cardId(e.value) == 'absolute_immunity')
            .map((e) => e.key)
            .toSet();
        final candidates =
            players
                .where(
                  (item) => item.id != playerId && !immuneIds.contains(item.id),
                )
                .toList()
              ..sort((left, right) => right.score.compareTo(left.score));
        if (candidates.isNotEmpty) {
          final leader = candidates.first;
          // Steal 1/4 of the leader's score (minimum 1).
          final leaderBalance = leader.score + (deltas[leader.id] ?? 0);
          final steal = max(0, (max(0, leaderBalance) / 4).floor());
          deltas[playerId] = (deltas[playerId] ?? 0) + steal;
          deltas[leader.id] = (deltas[leader.id] ?? 0) - steal;
          powerEvents.add(
            '🏹 روبن هود: ${player.name} أخذ ربع نقاط ${leader.name} ($steal نقطة).',
          );
        }
      }

      if (card == 'grand_inversion') {
        // Skip if leader has absolute_immunity.
        final immuneIds = assignedPowerCards.entries
            .where((e) => _cardId(e.value) == 'absolute_immunity')
            .map((e) => e.key)
            .toSet();
        final candidates =
            players
                .where(
                  (item) => item.id != playerId && !immuneIds.contains(item.id),
                )
                .toList()
              ..sort((left, right) => right.score.compareTo(left.score));
        final leader = candidates.isNotEmpty ? candidates.first : null;
        if (leader != null) {
          if (perfectVote) {
            final playerBalance = player.score + (deltas[playerId] ?? 0);
            final leaderBalance = leader.score + (deltas[leader.id] ?? 0);
            deltas[playerId] = leaderBalance - player.score;
            deltas[leader.id] = playerBalance - leader.score;
            powerEvents.add(
              '🔄 الانقلاب العظيم: ${player.name} تبادل رصيده مع المتصدر ${leader.name} واعتلى القمة!',
            );
          } else if (playerVotes.isNotEmpty) {
            deltas[playerId] = (deltas[playerId] ?? 0) - 5;
            deltas[leader.id] = (deltas[leader.id] ?? 0) + 3;
            powerEvents.add(
              '❌ فشل الانقلاب العظيم: ${player.name} خسر 5 نقاط وحصل المتصدر ${leader.name} على +3 حماية.',
            );
          }
        } else if (immuneIds.isNotEmpty) {
          powerEvents.add('🛡️ الحصانة: حمت المتصدر من مهارة الانقلاب العظيم!');
        }
      }

      if (card == 'guillotine') {
        final targetId = _targetId(entry.value);
        // Resolve target, skipping immune players.
        final immuneIds = assignedPowerCards.entries
            .where((e) => _cardId(e.value) == 'absolute_immunity')
            .map((e) => e.key)
            .toSet();
        final target = targetId != null
            ? players.firstWhereOrNull(
                (item) => item.id == targetId && !immuneIds.contains(item.id),
              )
            : (players
                      .where(
                        (item) =>
                            item.id != playerId && !immuneIds.contains(item.id),
                      )
                      .toList()
                    ..sort((left, right) => right.score.compareTo(left.score)))
                  .firstOrNull;
        if (target != null) {
          if (perfectVote) {
            final targetBalance = target.score + (deltas[target.id] ?? 0);
            final wiped = max(0, targetBalance);
            final gain = (wiped + 1) ~/ 2;
            deltas[target.id] = -target.score;
            deltas[playerId] = (deltas[playerId] ?? 0) + gain;
            powerEvents.add(
              '💣 المقصلة: ${player.name} صفّر رصيد المتصدر ${target.name} وحصل على +$gain نقطة!',
            );
          } else if (playerVotes.isNotEmpty) {
            final playerBalance = player.score + (deltas[playerId] ?? 0);
            final lost = max(0, playerBalance);
            deltas[playerId] = -player.score;
            deltas[target.id] = (deltas[target.id] ?? 0) + lost;
            powerEvents.add(
              '💥 ارتداد المقصلة: تصفّر رصيد ${player.name} وانتقلت نقاطه للمتصدر ${target.name}!',
            );
          }
        } else if (immuneIds.isNotEmpty) {
          powerEvents.add('🛡️ الحصانة: حمت المتصدر من مهارة المقصلة!');
        }
      }

      if (card == 'all_in') {
        if (perfectVote) {
          final balanceAfterVote = player.score + (deltas[playerId] ?? 0);
          final finalBalance = balanceAfterVote * 3;
          final gain = finalBalance - balanceAfterVote;
          deltas[playerId] = finalBalance - player.score;
          powerEvents.add(
            '🎲 الكل أو اللاشيء: ${player.name} ضاعف رصيده 3 أضعاف (+$gain نقطة)!',
          );
        } else if (playerVotes.isNotEmpty) {
          deltas[playerId] = -player.score;
          powerEvents.add(
            '💥 خسارة الكل أو اللاشيء: ${player.name} أفلس تماماً وتصفّر رصيده إلى 0!',
          );
        }
      }
    }

    // Alliance bonuses are calculated per matching outsider, so the rule
    // naturally scales from one outsider to three outsiders.
    final resolvedAlliancePairs = <String>{};
    for (final entry in assignedPowerCards.entries) {
      if (_cardId(entry.value) != 'tactical_alliance' ||
          outsiderSet.contains(entry.key)) {
        continue;
      }
      final allyId = _targetId(entry.value);
      final owner = players.firstWhereOrNull((item) => item.id == entry.key);
      final ally = players.firstWhereOrNull((item) => item.id == allyId);
      if (owner == null || ally == null || outsiderSet.contains(ally.id)) {
        continue;
      }
      final pair = ([owner.id, ally.id]..sort()).join('|');
      if (!resolvedAlliancePairs.add(pair)) continue;
      final ownerVotes = (votes[owner.id] ?? const <String>[]).toSet();
      final allyVotes = (votes[ally.id] ?? const <String>[]).toSet();
      final sharedCorrect = ownerVotes
          .intersection(allyVotes)
          .where(outsiderSet.contains)
          .length;
      if (sharedCorrect > 0) {
        final bonus = sharedCorrect * 2;
        deltas[owner.id] = (deltas[owner.id] ?? 0) + bonus;
        deltas[ally.id] = (deltas[ally.id] ?? 0) + bonus;
        powerEvents.add(
          '🤝 التحالف التكتيكي: ${owner.name} و${ally.name} تطابقا في $sharedCorrect اختيار صحيح.',
        );
      }
    }

    // Karma transfers one point for every incorrect accusation against its
    // innocent owner, regardless of how many outsiders are in the round.
    for (final entry in assignedPowerCards.entries) {
      if (_cardId(entry.value) != 'karma_backfire' ||
          outsiderSet.contains(entry.key)) {
        continue;
      }
      final owner = players.firstWhereOrNull((item) => item.id == entry.key);
      if (owner == null) continue;
      final attackers = votes.entries
          .where(
            (vote) => vote.key != owner.id && vote.value.contains(owner.id),
          )
          .map((vote) => vote.key)
          .toList(growable: false);
      for (final attackerId in attackers) {
        if (_cardId(assignedPowerCards[attackerId]) == 'diplomatic_immunity') {
          continue;
        }
        deltas[attackerId] = (deltas[attackerId] ?? 0) - 1;
        deltas[owner.id] = (deltas[owner.id] ?? 0) + 1;
      }
      if (attackers.isNotEmpty) {
        powerEvents.add(
          '🪃 الارتداد العكسي: ${owner.name} استعاد ${attackers.length} نقطة من متهميه.',
        );
      }
    }

    final equalizerOwner = players.firstWhereOrNull((player) {
      if (_cardId(assignedPowerCards[player.id]) != 'equalizer') return false;
      final playerVotes = (votes[player.id] ?? const <String>[]).toSet();
      return playerVotes.isNotEmpty && playerVotes.every(outsiderSet.contains);
    });
    if (equalizerOwner != null) {
      final totalPot = players.fold<int>(0, (sum, player) {
        return sum + player.score + (deltas[player.id] ?? 0);
      });
      final targetScore = totalPot ~/ players.length;
      for (final player in players) {
        deltas[player.id] = targetScore - player.score;
      }
      powerEvents.add(
        '⚖️ الميزان العادل: ${equalizerOwner.name} أعاد توزيع النقاط بالتساوي ($targetScore نقطة لكل لاعب)!',
      );
    }

    final uniqueTopicCount = {
      topic.trim(),
      ...topicPool.map((item) => item.trim()).where((item) => item.isNotEmpty),
    }.length;
    final optionsByOutsider = <String, List<String>>{};
    for (final outsiderId in outsiderIds) {
      final cardId = _cardId(assignedPowerCards[outsiderId]);
      final optionCount = switch (cardId) {
        'outsider_choices_focus' => min(7, uniqueTopicCount),
        'outsider_point_wager' => uniqueTopicCount,
        'outsider_headhunter' => uniqueTopicCount,
        'outsider_coup' => uniqueTopicCount,
        'outsider_chaos_wall' => 1 + _random.nextInt(uniqueTopicCount),
        _ => min(15, uniqueTopicCount),
      };
      optionsByOutsider[outsiderId] = buildOutsiderGuessOptions(
        topic: topic,
        topicPool: topicPool,
        optionCount: optionCount,
      );
    }
    final defaultOptions = outsiderIds.isEmpty
        ? buildOutsiderGuessOptions(topic: topic, topicPool: topicPool)
        : optionsByOutsider[outsiderIds.first]!;

    final wrongVoterIds = <String>[];
    for (final player in players) {
      if (outsiderSet.contains(player.id)) continue;
      final playerVotes = (votes[player.id] ?? const <String>[]).toSet();
      final hasWrong =
          playerVotes.isNotEmpty &&
          playerVotes.any((suspect) => !outsiderSet.contains(suspect));
      if (hasWrong) {
        wrongVoterIds.add(player.id);
      }
    }

    return RoundOutcome(
      outsiderIds: outsiderIds,
      survivingOutsiderIds: survivingOutsiderIds,
      accusedPlayerIds: accusedPlayerIds,
      latestAccusedPlayerIds: accusedPlayerIds,
      topic: topic,
      voteCounts: counts,
      voteScoreDeltas: voteScoreDeltas,
      scoreDeltas: deltas,
      outsiderGuessOptions: defaultOptions,
      outsiderGuessOptionsByPlayer: optionsByOutsider,
      outsiderCaught: outsiderCaught,
      isTie: accusation.isTie,
      recapLine: _recapLine(
        survivingOutsiderIds: survivingOutsiderIds,
        outsiderCaught: outsiderCaught,
        isTie: accusation.isTie,
      ),
      powerEvents: powerEvents,
      wrongVoterIds: wrongVoterIds,
      scoreLedger: _buildScoreLedger(
        players: players,
        voteScoreDeltas: voteScoreDeltas,
        scoreDeltas: deltas,
      ),
    );
  }

  RoundOutcome mergeVotingOutcomes({
    required RoundOutcome previous,
    required RoundOutcome current,
    required List<String> survivingOutsiderIds,
    List<PlayerProfile> players = const [],
    Map<String, String> assignedPowerCards = const {},
  }) {
    final mergedVoteCounts = _sumMaps(previous.voteCounts, current.voteCounts);
    final mergedVoteScoreDeltas = _sumMaps(
      previous.voteScoreDeltas,
      current.voteScoreDeltas,
    );
    final mergedAccused = {
      ...previous.accusedPlayerIds,
      ...current.accusedPlayerIds,
    }.toList(growable: false);
    final mergedWrongVoterIds = {
      ...previous.wrongVoterIds,
      ...current.wrongVoterIds,
    }.toList(growable: false);

    final mergedScoreDeltas = Map<String, int>.from(mergedVoteScoreDeltas);
    final mergedPowerEvents = <String>[];

    if (players.isNotEmpty && assignedPowerCards.isNotEmpty) {
      final outsiderSet = current.outsiderIds.toSet();
      final resolvedAlliancePairs = <String>{};
      for (final entry in assignedPowerCards.entries) {
        final playerId = entry.key;
        if (outsiderSet.contains(playerId)) continue;
        final player = players.firstWhereOrNull((item) => item.id == playerId);
        if (player == null) continue;
        final isFlawless =
            !mergedAccused.contains(playerId) &&
            !mergedWrongVoterIds.contains(playerId);
        final card = _cardId(entry.value);

        // Helper: collect immune player IDs.
        final immuneIds = assignedPowerCards.entries
            .where((e) => _cardId(e.value) == 'absolute_immunity')
            .map((e) => e.key)
            .toSet();

        if (card == 'jackpot') {
          if (isFlawless) {
            final positivePot = players
                .where(
                  (item) =>
                      item.id != playerId &&
                      item.score > 0 &&
                      !immuneIds.contains(item.id),
                )
                .fold<int>(0, (sum, item) => sum + item.score);
            final gain = positivePot > 0 ? positivePot : 3;
            mergedScoreDeltas[playerId] =
                (mergedScoreDeltas[playerId] ?? 0) + gain;
            mergedPowerEvents.add(
              '🎰 الجاكبوت: ${player.name} كسب +$gain نقطة بعد تصويت كامل وصحيح في جميع الجولات.',
            );
          }
        }

        if (card == 'tactical_drain') {
          if (isFlawless) {
            final targetId = _targetId(entry.value);
            final target = players.firstWhereOrNull(
              (item) => item.id == targetId,
            );
            if (target != null) {
              final targetCard = _cardId(assignedPowerCards[target.id]);
              if (targetCard == 'absolute_immunity') {
                mergedPowerEvents.add(
                  '🛡️ الحصانة: تصدّى ${target.name} لمحاولة السطو التكتيكي من ${player.name} بنجاح!',
                );
              } else {
                final targetBalance =
                    target.score + (mergedScoreDeltas[target.id] ?? 0);
                mergedScoreDeltas[playerId] =
                    (mergedScoreDeltas[playerId] ?? 0) + targetBalance;
                mergedScoreDeltas[target.id] = -target.score;
                mergedPowerEvents.add(
                  '⚡ السطو التكتيكي: ${player.name} نقل رصيد ${target.name} إلى حسابه.',
                );
              }
            }
          }
        }

        if (card == 'robin_hood') {
          if (isFlawless) {
            final candidates =
                players
                    .where(
                      (item) =>
                          item.id != playerId && !immuneIds.contains(item.id),
                    )
                    .toList()
                  ..sort((left, right) => right.score.compareTo(left.score));
            if (candidates.isNotEmpty) {
              final leader = candidates.first;
              final leaderBalance =
                  leader.score + (mergedScoreDeltas[leader.id] ?? 0);
              final steal = max(0, (max(0, leaderBalance) / 4).floor());
              mergedScoreDeltas[playerId] =
                  (mergedScoreDeltas[playerId] ?? 0) + steal;
              mergedScoreDeltas[leader.id] =
                  (mergedScoreDeltas[leader.id] ?? 0) - steal;
              mergedPowerEvents.add(
                '🏹 روبن هود: ${player.name} أخذ ربع نقاط ${leader.name} ($steal نقطة).',
              );
            }
          }
        }

        if (card == 'grand_inversion') {
          final candidates =
              players
                  .where(
                    (item) =>
                        item.id != playerId && !immuneIds.contains(item.id),
                  )
                  .toList()
                ..sort((left, right) => right.score.compareTo(left.score));
          final leader = candidates.isNotEmpty ? candidates.first : null;
          if (leader != null) {
            if (isFlawless) {
              final playerBalance =
                  player.score + (mergedScoreDeltas[playerId] ?? 0);
              final leaderBalance =
                  leader.score + (mergedScoreDeltas[leader.id] ?? 0);
              mergedScoreDeltas[playerId] = leaderBalance - player.score;
              mergedScoreDeltas[leader.id] = playerBalance - leader.score;
              mergedPowerEvents.add(
                '🔄 الانقلاب العظيم: ${player.name} تبادل رصيده مع المتصدر ${leader.name} واعتلى القمة!',
              );
            } else {
              mergedScoreDeltas[playerId] =
                  (mergedScoreDeltas[playerId] ?? 0) - 5;
              mergedScoreDeltas[leader.id] =
                  (mergedScoreDeltas[leader.id] ?? 0) + 3;
              mergedPowerEvents.add(
                '❌ فشل الانقلاب العظيم: ${player.name} خسر 5 نقاط وحصل المتصدر ${leader.name} على +3 حماية.',
              );
            }
          }
        }

        if (card == 'guillotine') {
          final targetId = _targetId(entry.value);
          final target = targetId != null
              ? players.firstWhereOrNull(
                  (item) => item.id == targetId && !immuneIds.contains(item.id),
                )
              : (players
                        .where(
                          (item) =>
                              item.id != playerId &&
                              !immuneIds.contains(item.id),
                        )
                        .toList()
                      ..sort(
                        (left, right) => right.score.compareTo(left.score),
                      ))
                    .firstOrNull;
          if (target != null) {
            if (isFlawless) {
              final targetBalance =
                  target.score + (mergedScoreDeltas[target.id] ?? 0);
              final wiped = max(0, targetBalance);
              final gain = (wiped + 1) ~/ 2;
              mergedScoreDeltas[target.id] = -target.score;
              mergedScoreDeltas[playerId] =
                  (mergedScoreDeltas[playerId] ?? 0) + gain;
              mergedPowerEvents.add(
                '💣 المقصلة: ${player.name} صفّر رصيد المتصدر ${target.name} وحصل على +$gain نقطة!',
              );
            } else {
              final playerBalance =
                  player.score + (mergedScoreDeltas[playerId] ?? 0);
              final lost = max(0, playerBalance);
              mergedScoreDeltas[playerId] = -player.score;
              mergedScoreDeltas[target.id] =
                  (mergedScoreDeltas[target.id] ?? 0) + lost;
              mergedPowerEvents.add(
                '💥 ارتداد المقصلة: تصفّر رصيد ${player.name} وانتقلت نقاطه للمتصدر ${target.name}!',
              );
            }
          }
        }

        if (card == 'all_in') {
          if (isFlawless) {
            final balanceAfterVotes =
                player.score + (mergedScoreDeltas[playerId] ?? 0);
            final finalBalance = balanceAfterVotes * 3;
            final gain = finalBalance - balanceAfterVotes;
            mergedScoreDeltas[playerId] = finalBalance - player.score;
            mergedPowerEvents.add(
              '🎲 الكل أو اللاشيء: ${player.name} ضاعف رصيده 3 أضعاف (+$gain نقطة)!',
            );
          } else {
            mergedScoreDeltas[playerId] = -player.score;
            mergedPowerEvents.add(
              '💥 خسارة الكل أو اللاشيء: ${player.name} أفلس تماماً وتصفّر رصيده إلى 0!',
            );
          }
        }

        if (card == 'tactical_alliance') {
          final allyId = _targetId(entry.value);
          final ally = players.firstWhereOrNull((item) => item.id == allyId);
          if (ally != null && !outsiderSet.contains(ally.id)) {
            final pair = ([player.id, ally.id]..sort()).join('|');
            if (!resolvedAlliancePairs.add(pair)) continue;
            final isAllyFlawless =
                !mergedAccused.contains(ally.id) &&
                !mergedWrongVoterIds.contains(ally.id);
            if (isFlawless && isAllyFlawless) {
              mergedScoreDeltas[playerId] =
                  (mergedScoreDeltas[playerId] ?? 0) + 3;
              mergedScoreDeltas[ally.id] =
                  (mergedScoreDeltas[ally.id] ?? 0) + 3;
              mergedPowerEvents.add(
                '🤝 التحالف التكتيكي: ${player.name} و${ally.name} تطابقا في التصويت الصحيح في جميع الجولات.',
              );
            }
          }
        }

        if (card == 'karma_backfire') {
          int falseAccusations = 0;
          for (final suspectEntry in mergedVoteCounts.entries) {
            if (suspectEntry.key == playerId) {
              falseAccusations += suspectEntry.value;
            }
          }
          if (falseAccusations > 0) {
            mergedScoreDeltas[playerId] =
                (mergedScoreDeltas[playerId] ?? 0) + falseAccusations;
            mergedPowerEvents.add(
              '⚡ الارتداد العكسي: ${player.name} كسب +$falseAccusations نقطة بسبب الاتهامات الخاطئة ضده.',
            );
          }
        }
      }
      final equalizerOwner = players.firstWhereOrNull((player) {
        if (_cardId(assignedPowerCards[player.id]) != 'equalizer') return false;
        return !mergedAccused.contains(player.id) &&
            !mergedWrongVoterIds.contains(player.id);
      });
      if (equalizerOwner != null) {
        final totalPot = players.fold<int>(0, (sum, player) {
          return sum + player.score + (mergedScoreDeltas[player.id] ?? 0);
        });
        final targetScore = totalPot ~/ players.length;
        for (final player in players) {
          mergedScoreDeltas[player.id] = targetScore - player.score;
        }
        mergedPowerEvents.add(
          '⚖️ الميزان العادل: ${equalizerOwner.name} أعاد توزيع النقاط بالتساوي ($targetScore نقطة لكل لاعب)!',
        );
      }
    } else {
      final allPlayerIds = {
        ...previous.scoreDeltas.keys,
        ...current.scoreDeltas.keys,
        ...mergedVoteScoreDeltas.keys,
      };
      for (final playerId in allPlayerIds) {
        final voteDelta = mergedVoteScoreDeltas[playerId] ?? 0;
        final wasEliminated = mergedAccused.contains(playerId);
        final hadWrongVote = mergedWrongVoterIds.contains(playerId);

        final prevPower =
            (previous.scoreDeltas[playerId] ?? 0) -
            (previous.voteScoreDeltas[playerId] ?? 0);
        final currPower =
            (current.scoreDeltas[playerId] ?? 0) -
            (current.voteScoreDeltas[playerId] ?? 0);

        int powerBonus = 0;
        if (!wasEliminated && !hadWrongVote) {
          powerBonus = prevPower != 0 ? prevPower : currPower;
        } else {
          final penalty = min(prevPower, currPower);
          if (penalty < 0) {
            powerBonus = penalty;
          }
        }
        mergedScoreDeltas[playerId] = voteDelta + powerBonus;
      }
      for (final event in current.powerEvents) {
        if (!mergedPowerEvents.contains(event)) {
          mergedPowerEvents.add(event);
        }
      }
    }

    return current.copyWith(
      survivingOutsiderIds: survivingOutsiderIds,
      accusedPlayerIds: mergedAccused,
      voteCounts: mergedVoteCounts,
      voteScoreDeltas: mergedVoteScoreDeltas,
      scoreDeltas: mergedScoreDeltas,
      outsiderCaught: survivingOutsiderIds.length < current.outsiderIds.length,
      isTie: current.isTie,
      outsiderGuessOptionsByPlayer: {
        ...previous.outsiderGuessOptionsByPlayer,
        ...current.outsiderGuessOptionsByPlayer,
      },
      powerEvents: mergedPowerEvents,
      outsiderGuesses: previous.outsiderGuesses,
      outsiderGuessResults: previous.outsiderGuessResults,
      wrongVoterIds: mergedWrongVoterIds,
      scoreLedger: _buildScoreLedger(
        players: players,
        voteScoreDeltas: mergedVoteScoreDeltas,
        scoreDeltas: mergedScoreDeltas,
      ),
    );
  }

  RoundOutcome finalizeOutsiderGuess({
    required RoundOutcome outcome,
    required String outsiderId,
    required String guessedTopic,
    int correctPoints = 1,
    int wrongPoints = 1,
    String? wagerTargetId,
    int wagerStake = 0,
    int wagerWrongReward = 2,
    String? powerCardId,
    List<PlayerProfile> players = const [],
    Map<String, String> assignedPowerCards = const {},
  }) {
    if (outcome.outsiderGuessResults.containsKey(outsiderId)) return outcome;
    final isCorrect = guessedTopic == outcome.topic;
    var outsiderDelta = isCorrect ? correctPoints : -wrongPoints;
    final scores = Map<String, int>.from(outcome.scoreDeltas);
    final powerEvents = [...outcome.powerEvents];
    final outsider = players.firstWhereOrNull((p) => p.id == outsiderId);
    final outsiderName = outsider?.name ?? 'برا السالفة';

    // Helper: collect immune player IDs.
    final immuneIds = assignedPowerCards.entries
        .where((e) => _cardId(e.value) == 'absolute_immunity')
        .map((e) => e.key)
        .toSet();

    if (powerCardId == 'outsider_coup') {
      // Leader with immunity is skipped.
      final candidates =
          players
              .where((p) => p.id != outsiderId && !immuneIds.contains(p.id))
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));
      final leader = candidates.isNotEmpty ? candidates.first : null;
      if (leader != null) {
        if (isCorrect) {
          final leaderScore = max(0, leader.score + (scores[leader.id] ?? 0));
          scores[leader.id] = -leader.score;
          outsiderDelta = leaderScore;
          powerEvents.add(
            '👑 انقلاب برا السالفة: $outsiderName خمّن السالفة وسرق كامل رصيد المتصدر ${leader.name}!',
          );
        } else {
          outsiderDelta = -6;
          powerEvents.add(
            '❌ فشل انقلاب برا السالفة: خسر $outsiderName 6 نقاط.',
          );
        }
      } else if (immuneIds.isNotEmpty) {
        powerEvents.add('🛡️ الحصانة: حمت المتصدر من انقلاب برا السالفة!');
      }
    } else if (powerCardId == 'outsider_headhunter' && wagerTargetId != null) {
      final target = players.firstWhereOrNull((p) => p.id == wagerTargetId);
      final targetName = target?.name ?? 'اللاعب المستهدف';
      if (immuneIds.contains(wagerTargetId)) {
        powerEvents.add(
          '🛡️ الحصانة المطلقة منعت استهداف $targetName بقاطع الرؤوس.',
        );
      } else if (isCorrect) {
        final targetScore = max(
          0,
          (target?.score ?? 0) + (scores[wagerTargetId] ?? 0),
        );
        scores[wagerTargetId] = -(target?.score ?? 0);
        outsiderDelta = targetScore;
        powerEvents.add(
          '🎯 قاطع الرؤوس: $outsiderName اصطاد رصيد $targetName بالكامل!',
        );
      } else {
        outsiderDelta = -4;
        scores[wagerTargetId] = (scores[wagerTargetId] ?? 0) + 2;
        powerEvents.add(
          '❌ فشل قاطع الرؤوس: خسر $outsiderName 4 نقاط وحصل $targetName على +2 نقطة.',
        );
      }
    } else if (wagerTargetId != null &&
        wagerStake > 0 &&
        !immuneIds.contains(wagerTargetId)) {
      final targetDelta = isCorrect ? -wagerStake : wagerWrongReward;
      scores.update(
        wagerTargetId,
        (value) => value + targetDelta,
        ifAbsent: () => targetDelta,
      );
      powerEvents.add(
        isCorrect
            ? '🎲 نجح رهان الرصيد: +$wagerStake لبرا السالفة و-$wagerStake للاعب المختار.'
            : '🎲 فشل رهان الرصيد: -$wagerStake لبرا السالفة و+$wagerWrongReward للاعب المختار.',
      );
    }

    scores.update(
      outsiderId,
      (value) => value + outsiderDelta,
      ifAbsent: () => outsiderDelta,
    );

    return outcome.copyWith(
      scoreDeltas: scores,
      outsiderGuesses: {...outcome.outsiderGuesses, outsiderId: guessedTopic},
      outsiderGuessResults: {
        ...outcome.outsiderGuessResults,
        outsiderId: isCorrect,
      },
      powerEvents: powerEvents,
      scoreLedger: _appendLedgerChanges(
        existing: outcome.scoreLedger,
        players: players,
        beforeDeltas: outcome.scoreDeltas,
        afterDeltas: scores,
        label: isCorrect
            ? 'نتيجة تخمين برا السالفة الصحيح'
            : 'نتيجة تخمين برا السالفة الخاطئ',
      ),
    );
  }

  List<String> buildOutsiderGuessOptions({
    required String topic,
    required List<String> topicPool,
    int optionCount = 15,
  }) {
    final normalizedTopic = topic.trim();
    final pool =
        topicPool
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty && item != normalizedTopic)
            .toSet()
            .toList(growable: true)
          ..shuffle(_random);
    final options = <String>[
      normalizedTopic,
      ...pool.take(max(0, optionCount - 1)),
    ]..shuffle(_random);
    return options;
  }

  List<PlayerProfile> applyOutcome({
    required List<PlayerProfile> players,
    required RoundOutcome outcome,
  }) {
    return players
        .map(
          (player) => player.copyWith(
            score: player.score + (outcome.scoreDeltas[player.id] ?? 0),
          ),
        )
        .sorted((left, right) => right.score.compareTo(left.score));
  }

  Map<String, List<ScoreLedgerEntry>> _buildScoreLedger({
    required List<PlayerProfile> players,
    required Map<String, int> voteScoreDeltas,
    required Map<String, int> scoreDeltas,
  }) {
    return {
      for (final player in players)
        player.id: _ledgerForPlayer(
          player: player,
          voteDelta: voteScoreDeltas[player.id] ?? 0,
          finalDelta: scoreDeltas[player.id] ?? 0,
        ),
    };
  }

  List<ScoreLedgerEntry> _ledgerForPlayer({
    required PlayerProfile player,
    required int voteDelta,
    required int finalDelta,
  }) {
    final entries = <ScoreLedgerEntry>[];
    final afterVote = player.score + voteDelta;
    entries.add(
      ScoreLedgerEntry(
        label: voteDelta > 0
            ? 'نتيجة التصويت الصحيحة'
            : voteDelta < 0
            ? 'نتيجة التصويت الخاطئة'
            : 'نتيجة التصويت',
        delta: voteDelta,
        balanceBefore: player.score,
        balanceAfter: afterVote,
      ),
    );
    final skillDelta = finalDelta - voteDelta;
    if (skillDelta != 0) {
      entries.add(
        ScoreLedgerEntry(
          label: 'تأثير المهارات',
          delta: skillDelta,
          balanceBefore: afterVote,
          balanceAfter: player.score + finalDelta,
        ),
      );
    }
    return List<ScoreLedgerEntry>.unmodifiable(entries);
  }

  Map<String, List<ScoreLedgerEntry>> _appendLedgerChanges({
    required Map<String, List<ScoreLedgerEntry>> existing,
    required List<PlayerProfile> players,
    required Map<String, int> beforeDeltas,
    required Map<String, int> afterDeltas,
    required String label,
  }) {
    final result = {
      for (final entry in existing.entries)
        entry.key: List<ScoreLedgerEntry>.from(entry.value),
    };
    for (final player in players) {
      final beforeDelta = beforeDeltas[player.id] ?? 0;
      final afterDelta = afterDeltas[player.id] ?? 0;
      if (beforeDelta == afterDelta) continue;
      result
          .putIfAbsent(player.id, () => <ScoreLedgerEntry>[])
          .add(
            ScoreLedgerEntry(
              label: label,
              delta: afterDelta - beforeDelta,
              balanceBefore: player.score + beforeDelta,
              balanceAfter: player.score + afterDelta,
            ),
          );
    }
    return {
      for (final entry in result.entries)
        entry.key: List<ScoreLedgerEntry>.unmodifiable(entry.value),
    };
  }

  _Accusation _buildAccusation({
    required Map<String, int> counts,
    required int limit,
  }) {
    if (counts.isEmpty || limit < 1) return const _Accusation([], false);
    final ranked = counts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    if (ranked.length <= limit) {
      return _Accusation(
        ranked.map((entry) => entry.key).toList(growable: false),
        false,
      );
    }
    final cutoff = ranked[limit - 1].value;
    final above = ranked.where((entry) => entry.value > cutoff).toList();
    final tiedAtCutoff = ranked
        .where((entry) => entry.value == cutoff)
        .toList();
    final available = limit - above.length;
    if (tiedAtCutoff.length > available) {
      return _Accusation(
        above.map((entry) => entry.key).toList(growable: false),
        true,
      );
    }
    return _Accusation(
      [
        ...above,
        ...tiedAtCutoff,
      ].map((entry) => entry.key).toList(growable: false),
      false,
    );
  }

  Map<String, int> _sumMaps(Map<String, int> left, Map<String, int> right) {
    final result = Map<String, int>.from(left);
    for (final entry in right.entries) {
      result.update(
        entry.key,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    return result;
  }

  String _cardId(String? payload) => payload?.split(':').first ?? '';

  String? _targetId(String payload) {
    final parts = payload.split(':');
    return parts.length > 1 ? parts[1] : null;
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';

  String _recapLine({
    required List<String> survivingOutsiderIds,
    required bool outsiderCaught,
    required bool isTie,
  }) {
    if (survivingOutsiderIds.isEmpty) {
      return 'تم كشف كل برا السالفة في التصويت الحاسم.';
    }
    if (outsiderCaught) {
      return 'تم كشف بعض برا السالفة، لكن ما زال هناك من يختبئ.';
    }
    if (isTie) {
      return 'تعادل التصويت، لذلك لم يتم استبعاد أي لاعب.';
    }
    return 'لم ينجح التصويت في كشف برا السالفة.';
  }
}

class _Accusation {
  const _Accusation(this.playerIds, this.isTie);

  final List<String> playerIds;
  final bool isTie;
}
