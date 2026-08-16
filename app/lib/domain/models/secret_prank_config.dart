import 'package:flutter/foundation.dart';

@immutable
class SecretPrankConfig {
  const SecretPrankConfig({
    this.enabled = false,
    this.pin = '1904',
    this.insiderPlayerIds = const {},
    this.roundsRemaining,
  });

  final bool enabled;
  final String pin;
  final Set<String> insiderPlayerIds;

  /// Null means the prank remains active until the host disables it manually.
  final int? roundsRemaining;

  bool isInsider(String playerId) {
    return enabled && insiderPlayerIds.contains(playerId);
  }

  SecretPrankConfig copyWith({
    bool? enabled,
    String? pin,
    Set<String>? insiderPlayerIds,
    Object? roundsRemaining = _unchanged,
  }) {
    return SecretPrankConfig(
      enabled: enabled ?? this.enabled,
      pin: pin ?? this.pin,
      insiderPlayerIds: insiderPlayerIds ?? this.insiderPlayerIds,
      roundsRemaining: identical(roundsRemaining, _unchanged)
          ? this.roundsRemaining
          : roundsRemaining as int?,
    );
  }

  SecretPrankConfig afterCompletedRound() {
    if (!enabled || roundsRemaining == null) return this;
    if (roundsRemaining! <= 1) {
      return copyWith(enabled: false, roundsRemaining: 0);
    }
    return copyWith(roundsRemaining: roundsRemaining! - 1);
  }

  SecretPrankConfig sanitizedForPlayers(Set<String> validPlayerIds) {
    final validInsiders = insiderPlayerIds.intersection(validPlayerIds);
    return copyWith(
      enabled: enabled && validInsiders.isNotEmpty,
      insiderPlayerIds: validInsiders,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'pin': pin,
    'insiderPlayerIds': insiderPlayerIds.toList(growable: false)..sort(),
    'roundsRemaining': roundsRemaining,
  };

  factory SecretPrankConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SecretPrankConfig();
    final rounds = json['roundsRemaining'] as int?;
    final normalizedRounds = rounds?.clamp(0, 10);
    return SecretPrankConfig(
      enabled: (json['enabled'] as bool? ?? false) && normalizedRounds != 0,
      pin: _validPin(json['pin'] as String?),
      insiderPlayerIds:
          (json['insiderPlayerIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toSet() ??
          const {},
      roundsRemaining: normalizedRounds,
    );
  }

  static String _validPin(String? value) {
    final candidate = value?.trim() ?? '';
    return RegExp(r'^\d{4}$').hasMatch(candidate) ? candidate : '1904';
  }
}

const _unchanged = Object();
