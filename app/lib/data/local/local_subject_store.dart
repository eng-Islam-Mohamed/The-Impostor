import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/app_directories.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:flutter/foundation.dart';

abstract class SubjectsStore {
  Future<List<CategoryPack>> load();
  Future<void> save(List<CategoryPack> packs);
}

class LocalSubjectsStore implements SubjectsStore {
  LocalSubjectsStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_subjects.json';
  static const _seedVersion = 2;
  static List<CategoryPack> _webCache = seededCategoryPacks;

  final String? _filePath;

  Future<File> get _file {
    return AppDirectories.documentsFile(_fileName, overridePath: _filePath);
  }

  @override
  Future<List<CategoryPack>> load() async {
    if (kIsWeb) {
      return _webCache;
    }
    try {
      final file = await _file;
      if (!await file.exists()) {
        return seededCategoryPacks;
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return seededCategoryPacks;
      }
      final decoded = jsonDecode(content);
      final storedVersion = decoded is Map<String, dynamic>
          ? decoded['seedVersion'] as int? ?? 0
          : 0;
      final rawPacks = decoded is Map<String, dynamic>
          ? decoded['packs'] as List<dynamic>? ?? const []
          : decoded as List<dynamic>;
      final packs = rawPacks
          .map((item) => CategoryPack.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      if (storedVersion >= _seedVersion) {
        return packs;
      }
      final migrated = _mergeLatestBuiltInTopics(packs);
      await save(migrated);
      return migrated;
    } catch (_) {
      return seededCategoryPacks;
    }
  }

  @override
  Future<void> save(List<CategoryPack> packs) async {
    if (kIsWeb) {
      _webCache = packs;
      return;
    }
    try {
      final file = await _file;
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'seedVersion': _seedVersion,
          'packs': packs.map((pack) => pack.toJson()).toList(growable: false),
        }),
        flush: true,
      );
    } catch (_) {}
  }

  List<CategoryPack> _mergeLatestBuiltInTopics(List<CategoryPack> packs) {
    final seededById = {for (final pack in seededCategoryPacks) pack.id: pack};
    final existingIds = packs.map((pack) => pack.id).toSet();
    return [
      for (final pack in packs)
        if (seededById[pack.id] case final seeded?)
          pack.copyWith(
            topics: {
              ...pack.topics.map(_canonicalBuiltInTopic),
              ...seeded.topics,
            }.toList(growable: false),
          )
        else
          pack,
      for (final seeded in seededCategoryPacks)
        if (!existingIds.contains(seeded.id)) seeded,
    ];
  }

  String _canonicalBuiltInTopic(String topic) {
    return switch (topic.trim()) {
      'نابليون' => 'نابليون بونابرت',
      'Ibn Sina' => 'ابن سينا',
      'Ibn Battuta' => 'ابن بطوطة',
      'مهاتما غاندي' => 'المهاتما غاندي',
      final value => value,
    };
  }
}
