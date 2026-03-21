import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';

abstract class SubjectsStore {
  Future<List<CategoryPack>> load();
  Future<void> save(List<CategoryPack> packs);
}

class LocalSubjectsStore implements SubjectsStore {
  LocalSubjectsStore({String? filePath})
      : _file = File(
          filePath ??
              '${Directory.systemTemp.path}${Platform.pathSeparator}bara_alsalfa_subjects.json',
        );

  final File _file;

  @override
  Future<List<CategoryPack>> load() async {
    try {
      if (!await _file.exists()) {
        return seededCategoryPacks;
      }
      final content = await _file.readAsString();
      if (content.trim().isEmpty) {
        return seededCategoryPacks;
      }
      final json = jsonDecode(content) as List<dynamic>;
      return json
          .map((item) => CategoryPack.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return seededCategoryPacks;
    }
  }

  @override
  Future<void> save(List<CategoryPack> packs) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      jsonEncode(
        packs.map((pack) => pack.toJson()).toList(growable: false),
      ),
    );
  }
}
