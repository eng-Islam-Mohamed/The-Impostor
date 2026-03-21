import 'package:flutter/foundation.dart';

@immutable
class RoundOutcome {
  const RoundOutcome({
    required this.outsiderId,
    required this.topic,
    required this.mostVotedPlayerId,
    required this.voteCounts,
    required this.scoreDeltas,
    required this.outsiderCaught,
    required this.isTie,
    required this.recapLine,
  });

  final String outsiderId;
  final String topic;
  final String? mostVotedPlayerId;
  final Map<String, int> voteCounts;
  final Map<String, int> scoreDeltas;
  final bool outsiderCaught;
  final bool isTie;
  final String recapLine;
}
