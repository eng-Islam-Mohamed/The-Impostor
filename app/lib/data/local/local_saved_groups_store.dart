import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/app_directories.dart';
import 'package:bara_alsalfa/domain/models/saved_game_group.dart';
import 'package:flutter/foundation.dart';

abstract class SavedGroupsStore {
  Future<SavedGroupsState> load();
  Future<void> save(SavedGroupsState state);
}

class LocalSavedGroupsStore implements SavedGroupsStore {
  LocalSavedGroupsStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_saved_groups.json';
  static SavedGroupsState _webCache = const SavedGroupsState();
  final String? _filePath;

  Future<File> get _file =>
      AppDirectories.documentsFile(_fileName, overridePath: _filePath);

  @override
  Future<SavedGroupsState> load() async {
    if (kIsWeb) return _webCache;
    try {
      final file = await _file;
      if (!await file.exists()) return const SavedGroupsState();
      final content = await file.readAsString();
      if (content.trim().isEmpty) return const SavedGroupsState();
      return SavedGroupsState.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (_) {
      return const SavedGroupsState();
    }
  }

  @override
  Future<void> save(SavedGroupsState state) async {
    if (kIsWeb) {
      _webCache = state;
      return;
    }
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(state.toJson()), flush: true);
  }
}
