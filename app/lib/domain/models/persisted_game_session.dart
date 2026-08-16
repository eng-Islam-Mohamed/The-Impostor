import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:flutter/foundation.dart';

enum PowerDensity {
  balanced('متوازنة', 'توزيع تكتيكي ذكي حسب عدد اللاعبين (1-2 أو 2-3 مهارات)'),
  intense('حماسية', 'وتيرة مهارات مرتفعة (2 إلى 4 مهارات)'),
  mayhem('فوضى شاملة', 'مهارة سرية لكل لاعب في الجولة!');

  const PowerDensity(this.label, this.description);
  final String label;
  final String description;

  static PowerDensity fromName(String? name) {
    return PowerDensity.values.firstWhere(
      (d) => d.name == name,
      orElse: () => PowerDensity.balanced,
    );
  }
}

@immutable
class PersistedGameSession {
  const PersistedGameSession({
    required this.players,
    required this.selectedMode,
    required this.selectedPackId,
    required this.discussionSeconds,
    required this.scoringEnabled,
    required this.powerCardsEnabled,
    required this.activePowerCardIds,
    required this.outsidersKnowEachOther,
    required this.outsiderCount,
    required this.roundNumber,
    this.powerDensity = PowerDensity.balanced,
    this.sequentialEliminationEnabled = false,
  });

  final List<PlayerProfile> players;
  final GameMode selectedMode;
  final String selectedPackId;
  final int discussionSeconds;
  final bool scoringEnabled;
  final bool powerCardsEnabled;
  final Set<String> activePowerCardIds;
  final bool outsidersKnowEachOther;
  final int outsiderCount;
  final int roundNumber;
  final PowerDensity powerDensity;
  final bool sequentialEliminationEnabled;

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'selectedMode': selectedMode.name,
      'selectedPackId': selectedPackId,
      'discussionSeconds': discussionSeconds,
      'scoringEnabled': scoringEnabled,
      'powerCardsEnabled': powerCardsEnabled,
      'activePowerCardIds': activePowerCardIds.toList()..sort(),
      'outsidersKnowEachOther': outsidersKnowEachOther,
      'outsiderCount': outsiderCount,
      'roundNumber': roundNumber,
      'powerDensity': powerDensity.name,
      'sequentialEliminationEnabled': sequentialEliminationEnabled,
    };
  }

  factory PersistedGameSession.fromJson(Map<String, dynamic> json) {
    final players = (json['players'] as List<dynamic>)
        .map((player) => PlayerProfile.fromJson(player as Map<String, dynamic>))
        .toList(growable: false);
    if (players.isEmpty) {
      throw const FormatException('A saved session must contain players.');
    }

    return PersistedGameSession(
      players: players,
      selectedMode: GameMode.values.firstWhere(
        (mode) => mode.name == json['selectedMode'],
        orElse: () => GameMode.classic,
      ),
      selectedPackId: json['selectedPackId'] as String,
      discussionSeconds: json['discussionSeconds'] as int,
      scoringEnabled: json['scoringEnabled'] as bool,
      powerCardsEnabled: json['powerCardsEnabled'] as bool? ?? true,
      activePowerCardIds:
          (json['activePowerCardIds'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toSet() ??
          const <String>{},
      outsidersKnowEachOther: json['outsidersKnowEachOther'] as bool,
      outsiderCount: json['outsiderCount'] as int,
      roundNumber: json['roundNumber'] as int,
      powerDensity: PowerDensity.fromName(json['powerDensity'] as String?),
      sequentialEliminationEnabled:
          json['sequentialEliminationEnabled'] as bool? ?? false,
    );
  }
}
