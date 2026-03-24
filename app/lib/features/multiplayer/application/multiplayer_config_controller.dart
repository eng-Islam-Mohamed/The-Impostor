import 'package:bara_alsalfa/data/local/local_multiplayer_config_store.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_client_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final multiplayerConfigStoreProvider = Provider<MultiplayerConfigStore>(
  (ref) => throw UnimplementedError('MultiplayerConfigStore override missing.'),
);

final initialMultiplayerConfigProvider = Provider<MultiplayerClientConfig>(
  (ref) => const MultiplayerClientConfig.defaults(),
);

class MultiplayerConfigController extends Notifier<MultiplayerClientConfig> {
  MultiplayerConfigStore get _store => ref.read(multiplayerConfigStoreProvider);

  @override
  MultiplayerClientConfig build() {
    return ref.read(initialMultiplayerConfigProvider);
  }

  Future<void> setUseLiveServer(bool enabled) async {
    state = state.copyWith(useLiveServer: enabled);
    await _store.save(state);
  }

  Future<void> setServerUrl(String serverUrl) async {
    var trimmed = serverUrl.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    state = state.copyWith(serverUrl: trimmed);
    await _store.save(state);
  }
}

final multiplayerClientConfigProvider =
    NotifierProvider<MultiplayerConfigController, MultiplayerClientConfig>(
  MultiplayerConfigController.new,
);
