import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bara_alsalfa/data/local/app_directories.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_client_config.dart';
import 'package:flutter/foundation.dart';

abstract class MultiplayerConfigStore {
  Future<MultiplayerClientConfig> load();
  Future<void> save(MultiplayerClientConfig config);
}

class LocalMultiplayerConfigStore implements MultiplayerConfigStore {
  static const int _configVersion = 4;
  static const String _defaultServerUrl = String.fromEnvironment(
    'MULTIPLAYER_SERVER_URL',
    defaultValue: 'http://192.168.1.40:8080',
  );

  LocalMultiplayerConfigStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_multiplayer_config.json';
  static MultiplayerClientConfig? _webCache;

  final String? _filePath;

  Future<File> get _file {
    return AppDirectories.documentsFile(_fileName, overridePath: _filePath);
  }

  @override
  Future<MultiplayerClientConfig> load() async {
    if (kIsWeb) {
      return _webCache ??= MultiplayerClientConfig.defaults().copyWith(
        clientId: _generateClientId(),
      );
    }
    try {
      final file = await _file;
      if (!await file.exists()) {
        return MultiplayerClientConfig.defaults().copyWith(
          clientId: _generateClientId(),
        );
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return MultiplayerClientConfig.defaults().copyWith(
          clientId: _generateClientId(),
        );
      }

      final json = jsonDecode(content) as Map<String, dynamic>;
      final storedVersion = json['configVersion'] as int? ?? 0;
      final storedUrl =
          (json['serverUrl'] as String?)?.trim() ?? _defaultServerUrl;
      final storedClientId = (json['clientId'] as String?)?.trim();
      return MultiplayerClientConfig(
        useLiveServer: storedVersion < _configVersion
            ? true
            : json['useLiveServer'] as bool? ?? true,
        serverUrl: storedVersion < _configVersion
            ? _defaultServerUrl
            : (storedUrl.isEmpty ? _defaultServerUrl : storedUrl),
        clientId: storedClientId == null || storedClientId.isEmpty
            ? _generateClientId()
            : storedClientId,
      );
    } catch (_) {
      return MultiplayerClientConfig.defaults().copyWith(
        clientId: _generateClientId(),
      );
    }
  }

  @override
  Future<void> save(MultiplayerClientConfig config) async {
    if (kIsWeb) {
      _webCache = config;
      return;
    }
    try {
      final file = await _file;
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'configVersion': _configVersion,
          'useLiveServer': config.useLiveServer,
          'serverUrl': config.serverUrl,
          'clientId': config.clientId,
        }),
        flush: true,
      );
    } catch (_) {}
  }

  String _generateClientId() {
    final random = Random.secure();
    final suffix = List.generate(
      12,
      (_) => random.nextInt(36).toRadixString(36),
    ).join();
    return 'client-$suffix';
  }
}
