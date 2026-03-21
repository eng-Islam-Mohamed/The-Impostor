import 'dart:math';

import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:collection/collection.dart';

class GameRoundSeed {
  const GameRoundSeed({
    required this.topic,
    required this.outsiderId,
    required this.assignments,
  });

  final String topic;
  final String outsiderId;
  final List<SecretAssignment> assignments;
}

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  GameRoundSeed createRound({
    required List<PlayerProfile> players,
    required CategoryPack pack,
  }) {
    final outsider = players[_random.nextInt(players.length)];
    final topic = pack.topics[_random.nextInt(pack.topics.length)];

    final assignments = players
        .map(
          (player) => SecretAssignment(
            playerId: player.id,
            playerName: player.name,
            topic: topic,
            isOutsider: player.id == outsider.id,
          ),
        )
        .toList(growable: false);

    return GameRoundSeed(
      topic: topic,
      outsiderId: outsider.id,
      assignments: assignments,
    );
  }

  RoundOutcome resolveRound({
    required List<PlayerProfile> players,
    required String outsiderId,
    required String topic,
    required Map<String, String> votes,
  }) {
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
    final outsiderCaught = !isTie && mostVotedPlayerId == outsiderId;

    final scoreDeltas = {
      for (final player in players) player.id: 0,
    };

    if (outsiderCaught) {
      for (final voteEntry in votes.entries) {
        if (voteEntry.value == outsiderId) {
          scoreDeltas.update(voteEntry.key, (value) => value + 2);
        }
      }
    } else {
      scoreDeltas.update(outsiderId, (value) => value + (isTie ? 4 : 3));
      final decoy = mostVotedPlayerId;
      if (decoy != null && decoy != outsiderId) {
        scoreDeltas.update(decoy, (value) => value + 1);
      }
    }

    final recapLine = switch ((outsiderCaught, isTie)) {
      (true, _) => 'انكشف برا السالفة بعد تصويت دقيق في آخر لحظة.',
      (false, true) => 'الجولة انتهت بفوضى جميلة وتعادل أنقذ برا السالفة.',
      _ => 'برا السالفة اندمج بذكاء ومرّ من التصويت بكل ثقة.',
    };

    return RoundOutcome(
      outsiderId: outsiderId,
      topic: topic,
      mostVotedPlayerId: mostVotedPlayerId,
      voteCounts: counts,
      scoreDeltas: scoreDeltas,
      outsiderCaught: outsiderCaught,
      isTie: isTie,
      recapLine: recapLine,
    );
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
