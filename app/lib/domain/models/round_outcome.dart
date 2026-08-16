import 'package:flutter/foundation.dart';

@immutable
class RoundOutcome {
  const RoundOutcome({
    required this.outsiderIds,
    required this.survivingOutsiderIds,
    required this.accusedPlayerIds,
    required this.topic,
    required this.voteCounts,
    required this.voteScoreDeltas,
    required this.scoreDeltas,
    required this.outsiderGuessOptions,
    required this.outsiderCaught,
    required this.isTie,
    required this.recapLine,
    this.outsiderGuesses = const {},
    this.outsiderGuessResults = const {},
    this.outsiderGuessOptionsByPlayer = const {},
    this.powerEvents = const [],
    this.latestAccusedPlayerIds = const [],
  });

  final List<String> outsiderIds;
  final List<String> survivingOutsiderIds;
  final List<String> accusedPlayerIds;
  final String topic;
  final Map<String, int> voteCounts;
  final Map<String, int> voteScoreDeltas;
  final Map<String, int> scoreDeltas;
  final List<String> outsiderGuessOptions;
  final bool outsiderCaught;
  final bool isTie;
  final String recapLine;
  final Map<String, String> outsiderGuesses;
  final Map<String, bool> outsiderGuessResults;
  final Map<String, List<String>> outsiderGuessOptionsByPlayer;
  final List<String> powerEvents;
  final List<String> latestAccusedPlayerIds;

  List<String> guessOptionsFor(String outsiderId) {
    return outsiderGuessOptionsByPlayer[outsiderId] ?? outsiderGuessOptions;
  }

  RoundOutcome copyWith({
    List<String>? outsiderIds,
    List<String>? survivingOutsiderIds,
    List<String>? accusedPlayerIds,
    String? topic,
    Map<String, int>? voteCounts,
    Map<String, int>? voteScoreDeltas,
    Map<String, int>? scoreDeltas,
    List<String>? outsiderGuessOptions,
    bool? outsiderCaught,
    bool? isTie,
    String? recapLine,
    Map<String, String>? outsiderGuesses,
    Map<String, bool>? outsiderGuessResults,
    Map<String, List<String>>? outsiderGuessOptionsByPlayer,
    List<String>? powerEvents,
    List<String>? latestAccusedPlayerIds,
  }) {
    return RoundOutcome(
      outsiderIds: outsiderIds ?? this.outsiderIds,
      survivingOutsiderIds: survivingOutsiderIds ?? this.survivingOutsiderIds,
      accusedPlayerIds: accusedPlayerIds ?? this.accusedPlayerIds,
      topic: topic ?? this.topic,
      voteCounts: voteCounts ?? this.voteCounts,
      voteScoreDeltas: voteScoreDeltas ?? this.voteScoreDeltas,
      scoreDeltas: scoreDeltas ?? this.scoreDeltas,
      outsiderGuessOptions: outsiderGuessOptions ?? this.outsiderGuessOptions,
      outsiderCaught: outsiderCaught ?? this.outsiderCaught,
      isTie: isTie ?? this.isTie,
      recapLine: recapLine ?? this.recapLine,
      outsiderGuesses: outsiderGuesses ?? this.outsiderGuesses,
      outsiderGuessResults: outsiderGuessResults ?? this.outsiderGuessResults,
      outsiderGuessOptionsByPlayer:
          outsiderGuessOptionsByPlayer ?? this.outsiderGuessOptionsByPlayer,
      powerEvents: powerEvents ?? this.powerEvents,
      latestAccusedPlayerIds:
          latestAccusedPlayerIds ?? this.latestAccusedPlayerIds,
    );
  }
}
