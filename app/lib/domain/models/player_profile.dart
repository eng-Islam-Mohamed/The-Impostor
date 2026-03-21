import 'package:flutter/foundation.dart';

@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.avatarIndex,
    required this.score,
  });

  final String id;
  final String name;
  final int avatarIndex;
  final int score;

  PlayerProfile copyWith({
    String? id,
    String? name,
    int? avatarIndex,
    int? score,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      score: score ?? this.score,
    );
  }
}
