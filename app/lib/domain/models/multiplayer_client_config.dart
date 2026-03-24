import 'package:flutter/foundation.dart';

@immutable
class MultiplayerClientConfig {
  const MultiplayerClientConfig({
    required this.useLiveServer,
    required this.serverUrl,
  });

  const MultiplayerClientConfig.defaults()
      : useLiveServer = true,
        serverUrl = const String.fromEnvironment(
          'MULTIPLAYER_SERVER_URL',
          defaultValue: 'http://192.168.1.40:8080',
        );

  final bool useLiveServer;
  final String serverUrl;

  MultiplayerClientConfig copyWith({
    bool? useLiveServer,
    String? serverUrl,
  }) {
    return MultiplayerClientConfig(
      useLiveServer: useLiveServer ?? this.useLiveServer,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}
