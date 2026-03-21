import 'package:flutter/foundation.dart';

@immutable
class SecretAssignment {
  const SecretAssignment({
    required this.playerId,
    required this.playerName,
    required this.topic,
    required this.isOutsider,
  });

  final String playerId;
  final String playerName;
  final String topic;
  final bool isOutsider;
}
