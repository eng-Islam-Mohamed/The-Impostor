import 'dart:convert';
import 'dart:io';

abstract class TopicTranslationsStore {
  Future<Map<String, Map<String, String>>> load();
  Future<void> save(Map<String, Map<String, String>> translations);
}

class LocalTopicTranslationsStore implements TopicTranslationsStore {
  LocalTopicTranslationsStore({String? filePath})
      : _file = File(
          filePath ??
              '${Directory.systemTemp.path}${Platform.pathSeparator}'
                  'bara_alsalfa_topic_translations.json',
        );

  final File _file;

  @override
  Future<Map<String, Map<String, String>>> load() async {
    try {
      if (!await _file.exists()) {
        return const {};
      }

      final content = await _file.readAsString();
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
    await _file.parent.create(recursive: true);
    await _file.writeAsString(jsonEncode(translations));
  }
}
