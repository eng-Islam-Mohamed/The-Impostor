import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/domain/models/multiplayer_client_config.dart';

abstract class MultiplayerConfigStore {
  Future<MultiplayerClientConfig> load();
  Future<void> save(MultiplayerClientConfig config);
}

class LocalMultiplayerConfigStore implements MultiplayerConfigStore {
  static const int _configVersion = 3;
  static const String _defaultServerUrl = String.fromEnvironment(
    'MULTIPLAYER_SERVER_URL',
    defaultValue: 'http://192.168.1.40:8080',
  );

  LocalMultiplayerConfigStore({String? filePath})
      : _file = File(
          filePath ??
              '${Directory.systemTemp.path}${Platform.pathSeparator}'
                  'bara_alsalfa_multiplayer_config.json',
        );

  final File _file;

  @override
  Future<MultiplayerClientConfig> load() async {
    try {
      if (!await _file.exists()) {
        return const MultiplayerClientConfig.defaults();
      }

      final content = await _file.readAsString();
      if (content.trim().isEmpty) {
        return const MultiplayerClientConfig.defaults();
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      final storedVersion = json['configVersion'] as int? ?? 0;
      final storedUrl = (json['serverUrl'] as String?)?.trim() ?? _defaultServerUrl;
      return MultiplayerClientConfig(
        useLiveServer: storedVersion < _configVersion
            ? true
            : json['useLiveServer'] as bool? ?? true,
        serverUrl: storedVersion < _configVersion
            ? _defaultServerUrl
            : (storedUrl.isEmpty ? _defaultServerUrl : storedUrl),
      );
    } catch (_) {
      return const MultiplayerClientConfig.defaults();
    }
  }

  @override
  Future<void> save(MultiplayerClientConfig config) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      jsonEncode({
        'configVersion': _configVersion,
        'useLiveServer': config.useLiveServer,
        'serverUrl': config.serverUrl,
      }),
    );
  }
}
