import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/app_directories.dart';

abstract class TopicTranslationsStore {
  Future<Map<String, Map<String, String>>> load();
  Future<void> save(Map<String, Map<String, String>> translations);
}

class LocalTopicTranslationsStore implements TopicTranslationsStore {
  LocalTopicTranslationsStore({String? filePath}) : _filePath = filePath;

  static const _fileName = 'bara_alsalfa_topic_translations.json';

  final String? _filePath;

  Future<File> get _file {
    return AppDirectories.documentsFile(_fileName, overridePath: _filePath);
  }

  @override
  Future<Map<String, Map<String, String>>> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return const {};
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return const {};
      }

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (localeCode, text) => MapEntry(localeCode, text as String),
          ),
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<void> save(Map<String, Map<String, String>> translations) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(translations), flush: true);
  }
}
