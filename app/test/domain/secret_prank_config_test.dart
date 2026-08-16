import 'package:bara_alsalfa/domain/models/secret_prank_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecretPrankConfig', () {
    test('counts completed rounds and disables at zero', () {
      const config = SecretPrankConfig(
        enabled: true,
        insiderPlayerIds: {'p1'},
        roundsRemaining: 2,
      );

      final afterFirstRound = config.afterCompletedRound();
      final afterSecondRound = afterFirstRound.afterCompletedRound();

      expect(afterFirstRound.enabled, isTrue);
      expect(afterFirstRound.roundsRemaining, 1);
      expect(afterSecondRound.enabled, isFalse);
      expect(afterSecondRound.roundsRemaining, 0);
    });

    test('unlimited mode remains enabled after completed rounds', () {
      const config = SecretPrankConfig(enabled: true, insiderPlayerIds: {'p1'});

      expect(identical(config.afterCompletedRound(), config), isTrue);
    });

    test('removes missing players and disables an empty selection', () {
      const config = SecretPrankConfig(
        enabled: true,
        insiderPlayerIds: {'removed-player'},
        roundsRemaining: 5,
      );

      final sanitized = config.sanitizedForPlayers({'p1', 'p2'});

      expect(sanitized.enabled, isFalse);
      expect(sanitized.insiderPlayerIds, isEmpty);
    });

    test('round trip preserves pin, insiders, and duration', () {
      const config = SecretPrankConfig(
        enabled: true,
        pin: '2468',
        insiderPlayerIds: {'p2', 'p1'},
        roundsRemaining: 10,
      );

      final restored = SecretPrankConfig.fromJson(config.toJson());

      expect(restored.enabled, isTrue);
      expect(restored.pin, '2468');
      expect(restored.insiderPlayerIds, {'p1', 'p2'});
      expect(restored.roundsRemaining, 10);
    });

    test('zero remaining rounds cannot restore as enabled', () {
      final restored = SecretPrankConfig.fromJson({
        'enabled': true,
        'pin': '1904',
        'insiderPlayerIds': ['p1'],
        'roundsRemaining': 0,
      });

      expect(restored.enabled, isFalse);
    });
  });
}
