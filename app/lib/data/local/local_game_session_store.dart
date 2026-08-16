import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/app_directories.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:flutter/foundation.dart';

abstract class GameSessionStore {
  Future<PersistedGameSession?> load();
  Future<void> save(PersistedGameSession session);
  Future<void> clear();
}

class LocalGameSessionStore implements GameSessionStore {
  LocalGameSessionStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_game_session.json';
  static PersistedGameSession? _webCache;

  final String? _filePath;

  Future<File> get _file {
    return AppDirectories.documentsFile(_fileName, overridePath: _filePath);
  }

  @override
  Future<PersistedGameSession?> load() async {
    if (kIsWeb) {
      return _webCache;
    }
    try {
      final file = await _file;
      if (!await file.exists()) {
        return null;
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return null;
      }
      return PersistedGameSession.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(PersistedGameSession session) async {
    if (kIsWeb) {
      _webCache = session;
      return;
    }
    try {
      final file = await _file;
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(session.toJson()), flush: true);
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    if (kIsWeb) {
      _webCache = null;
      return;
    }
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
