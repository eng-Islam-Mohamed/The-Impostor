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
    required Map<String, String> votes,
    required List<String> topicPool,
  }) {
    final outsiderSet = outsiderIds.toSet();
    final counts = <String, int>{};
    for (final suspectId in votes.values) {
      counts.update(suspectId, (value) => value + 1, ifAbsent: () => 1);
    }

    final maxVotes = counts.values.fold<int>(0, max);
    final leaders = counts.entries
        .where((entry) => entry.value == maxVotes)
        .map((entry) => entry.key)
        .toList(growable: false);
    final isTie = leaders.length > 1;
    final mostVotedPlayerId = leaders.isEmpty ? null : leaders.first;
    final outsiderCaught = !isTie && outsiderSet.contains(mostVotedPlayerId);

    final voteScoreDeltas = <String, int>{
      for (final player in players)
        player.id: outsiderSet.contains(player.id)
            ? 0
            : outsiderSet.contains(votes[player.id])
                ? 1
                : -1,
    };

    final recapLine = switch ((outsiderCaught, isTie, outsiderIds.length > 1)) {
      (true, _, true) => 'تم كشف واحد من برا السالفة، لكن البقية ما زالوا يراوغون.',
      (true, _, false) => 'انكشف برا السالفة بعد تصويت دقيق في آخر لحظة.',
      (false, true, _) => 'التعادل خلط الأوراق ومنح برا السالفة فرصة أخيرة للنجاة.',
      _ => 'المجموعة شكّت في الشخص الخطأ وبرا السالفة ما زال في المشهد.',
    };

    return RoundOutcome(
      outsiderIds: outsiderIds,
      topic: topic,
      mostVotedPlayerId: mostVotedPlayerId,
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
}
