import 'package:flutter/foundation.dart';

@immutable
class MultiplayerClientConfig {
  const MultiplayerClientConfig({
    required this.useLiveServer,
    required this.serverUrl,
    required this.clientId,
  });

  const MultiplayerClientConfig.defaults()
      : useLiveServer = true,
        serverUrl = const String.fromEnvironment(
          'MULTIPLAYER_SERVER_URL',
          defaultValue: 'http://192.168.1.40:8080',
        ),
        clientId = 'client-default';

  final bool useLiveServer;
  final String serverUrl;
  final String clientId;

  MultiplayerClientConfig copyWith({
    bool? useLiveServer,
    String? serverUrl,
    String? clientId,
  }) {
    return MultiplayerClientConfig(
      useLiveServer: useLiveServer ?? this.useLiveServer,
      serverUrl: serverUrl ?? this.serverUrl,
      clientId: clientId ?? this.clientId,
    );
  }
}
