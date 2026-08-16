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
        final positivePot = players
            .where((item) => item.id != playerId && item.score > 0)
            .fold<int>(0, (sum, item) => sum + item.score);
        final gain = positivePot > 0 ? positivePot : 3;
        deltas[playerId] = (deltas[playerId] ?? 0) + gain;
        powerEvents.add(
          '🎰 الجاكبوت: ${player.name} كسب +$gain نقطة بعد تصويت كامل وصحيح.',
        );
      }

      if (card == 'tactical_drain' && perfectVote) {
        final targetId = _targetId(entry.value);
        final target = players.firstWhereOrNull((item) => item.id == targetId);
        if (target != null) {
          deltas[playerId] = (deltas[playerId] ?? 0) + target.score;
          deltas[target.id] = (deltas[target.id] ?? 0) - target.score;
          powerEvents.add(
            '⚡ السطو التكتيكي: ${player.name} نقل رصيد ${target.name} إلى حسابه.',
          );
        }
      }

      if (card == 'robin_hood' && perfectVote) {
        final candidates = players.where((item) => item.id != playerId).toList()
          ..sort((left, right) => right.score.compareTo(left.score));
        if (candidates.isNotEmpty) {
          final leader = candidates.first;
          deltas[playerId] = (deltas[playerId] ?? 0) + 2;
          deltas[leader.id] = (deltas[leader.id] ?? 0) - 2;
          powerEvents.add(
            '🏹 روبن هود: ${player.name} أخذ نقطتين من ${leader.name}.',
          );
        }
      }
    }

    // Alliance bonuses are calculated per matching outsider, so the rule
    // naturally scales from one outsider to three outsiders.
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
        deltas[attackerId] = (deltas[attackerId] ?? 0) - 1;
        deltas[owner.id] = (deltas[owner.id] ?? 0) + 1;
      }
      if (attackers.isNotEmpty) {
        powerEvents.add(
          '🪃 الارتداد العكسي: ${owner.name} استعاد ${attackers.length} نقطة من متهميه.',
        );
      }
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
    );
  }

  RoundOutcome mergeVotingOutcomes({
    required RoundOutcome previous,
    required RoundOutcome current,
    required List<String> survivingOutsiderIds,
  }) {
    return current.copyWith(
      survivingOutsiderIds: survivingOutsiderIds,
      accusedPlayerIds: {
        ...previous.accusedPlayerIds,
        ...current.accusedPlayerIds,
      }.toList(growable: false),
      voteCounts: _sumMaps(previous.voteCounts, current.voteCounts),
      voteScoreDeltas: _sumMaps(
        previous.voteScoreDeltas,
        current.voteScoreDeltas,
      ),
      scoreDeltas: _sumMaps(previous.scoreDeltas, current.scoreDeltas),
      outsiderCaught: survivingOutsiderIds.length < current.outsiderIds.length,
      isTie: current.isTie,
      outsiderGuessOptionsByPlayer: {
        ...previous.outsiderGuessOptionsByPlayer,
        ...current.outsiderGuessOptionsByPlayer,
      },
      powerEvents: [...previous.powerEvents, ...current.powerEvents],
      outsiderGuesses: previous.outsiderGuesses,
      outsiderGuessResults: previous.outsiderGuessResults,
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
  }) {
    if (outcome.outsiderGuessResults.containsKey(outsiderId)) return outcome;
    final isCorrect = guessedTopic == outcome.topic;
    final outsiderDelta = isCorrect ? correctPoints : -wrongPoints;
    final scores = Map<String, int>.from(outcome.scoreDeltas)
      ..update(
        outsiderId,
        (value) => value + outsiderDelta,
        ifAbsent: () => outsiderDelta,
      );
    final powerEvents = [...outcome.powerEvents];
    if (wagerTargetId != null && wagerStake > 0) {
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
    return outcome.copyWith(
      scoreDeltas: scores,
      outsiderGuesses: {...outcome.outsiderGuesses, outsiderId: guessedTopic},
      outsiderGuessResults: {
        ...outcome.outsiderGuessResults,
        outsiderId: isCorrect,
      },
      powerEvents: powerEvents,
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
