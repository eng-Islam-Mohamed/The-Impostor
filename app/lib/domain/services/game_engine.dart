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
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  GameRoundSeed createRound({
    required List<PlayerProfile> players,
    required CategoryPack pack,
    required int outsiderCount,
  }) {
    final shuffledPlayers = [...players]..shuffle(_random);
    final outsiders = shuffledPlayers.take(outsiderCount).map((player) => player.id).toSet();
    final topic = pack.topics[_random.nextInt(pack.topics.length)];

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
  }) {
    final outsiderSet = outsiderIds.toSet();
    final counts = <String, int>{};
    for (final suspectIds in votes.values) {
      for (final suspectId in suspectIds) {
        counts.update(suspectId, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final accusedPlayerIds = _buildAccusedPlayerIds(
      counts: counts,
      limit: outsiderIds.length,
    );
    final isTie = accusedPlayerIds.length > outsiderIds.length;
    final survivingOutsiderIds = outsiderIds
        .where((outsiderId) => !accusedPlayerIds.contains(outsiderId))
        .toList(growable: false);
    final outsiderCaught = survivingOutsiderIds.length != outsiderIds.length;

    final voteScoreDeltas = <String, int>{
      for (final player in players)
        player.id: outsiderSet.contains(player.id)
            ? 0
            : _voteDelta(votes[player.id] ?? const [], outsiderSet),
    };

    final recapLine = switch ((survivingOutsiderIds.isEmpty, outsiderCaught, isTie)) {
      (true, _, _) => 'تم كشف كل برا السالفة في التصويت الحاسم.',
      (false, true, _) => 'تم كشف بعض برا السالفة، لكن الناجين ما زالوا يناورون.',
      (false, false, true) => 'التعادل عقد المشهد وفتح باب النجاة أمام برا السالفة.',
      _ => 'المجموعة شكّت في الأشخاص الخطأ وبرا السالفة ما زال في المشهد.',
    };

    return RoundOutcome(
      outsiderIds: outsiderIds,
      survivingOutsiderIds: survivingOutsiderIds,
      accusedPlayerIds: accusedPlayerIds,
      topic: topic,
      voteCounts: counts,
      voteScoreDeltas: voteScoreDeltas,
      scoreDeltas: voteScoreDeltas,
      outsiderGuessOptions: buildOutsiderGuessOptions(topic: topic, topicPool: topicPool),
      outsiderCaught: outsiderCaught,
      isTie: isTie,
      recapLine: recapLine,
    );
  }

  RoundOutcome finalizeOutsiderGuess({
    required RoundOutcome outcome,
    required String outsiderId,
    required String guessedTopic,
  }) {
    final isCorrect = guessedTopic == outcome.topic;
    final updatedScores = Map<String, int>.from(outcome.scoreDeltas)
      ..update(
        outsiderId,
        (value) => value + (isCorrect ? 1 : -1),
        ifAbsent: () => isCorrect ? 1 : -1,
      );
    final updatedGuesses = Map<String, String>.from(outcome.outsiderGuesses)
      ..[outsiderId] = guessedTopic;
    final updatedResults = Map<String, bool>.from(outcome.outsiderGuessResults)
      ..[outsiderId] = isCorrect;

    return outcome.copyWith(
      scoreDeltas: updatedScores,
      outsiderGuesses: updatedGuesses,
      outsiderGuessResults: updatedResults,
    );
  }

  List<String> buildOutsiderGuessOptions({
    required String topic,
    required List<String> topicPool,
    int optionCount = 15,
  }) {
    final pool = topicPool.toSet().toList(growable: true)..remove(topic);
    pool.shuffle(_random);
    final options = <String>[topic, ...pool.take(max(0, optionCount - 1))]..shuffle(_random);
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

  int _voteDelta(List<String> suspectIds, Set<String> outsiderSet) {
    return suspectIds.fold<int>(
      0,
      (total, suspectId) => total + (outsiderSet.contains(suspectId) ? 1 : -1),
    );
  }

  List<String> _buildAccusedPlayerIds({
    required Map<String, int> counts,
    required int limit,
  }) {
    final sorted = counts.entries.toList()
      ..sort((left, right) {
        final byVotes = right.value.compareTo(left.value);
        if (byVotes != 0) {
          return byVotes;
        }
        return left.key.compareTo(right.key);
      });
    if (sorted.isEmpty) {
      return const [];
    }
    final capped = sorted.take(limit).toList(growable: false);
    final cutoff = capped.last.value;
    return sorted
        .where((entry) => entry.value >= cutoff)
        .map((entry) => entry.key)
        .toList(growable: false);
  }
}
