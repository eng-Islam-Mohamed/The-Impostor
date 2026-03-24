import 'package:flutter/services.dart';

class AppAudio {
  AppAudio._();

  static final AppAudio instance = AppAudio._();
  static const MethodChannel _channel = MethodChannel('bara_alsalfa/audio');

  bool _enabled = true;

  Future<void> initialize({required bool enabled}) async {
    _enabled = enabled;
    await _invoke('setEnabled', {'enabled': enabled});
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _invoke('setEnabled', {'enabled': enabled});
  }

  Future<void> playSoftTap() => _enabled ? _invoke('playSoftTap') : Future.value();

  Future<void> playVoteConfirm() => _enabled ? _invoke('playVoteConfirm') : Future.value();

  Future<void> playSuspenseReveal() =>
      _enabled ? _invoke('playSuspenseReveal') : Future.value();

  Future<void> playCorrectGuess() => _enabled ? _invoke('playCorrectGuess') : Future.value();

  Future<void> playWrongGuess() => _enabled ? _invoke('playWrongGuess') : Future.value();

  Future<void> _invoke(String method, [Map<String, Object?>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } catch (_) {
      // Keep gameplay smooth even if audio playback is unavailable.
    }
  }
}
