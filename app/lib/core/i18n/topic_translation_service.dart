import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

final topicTranslationServiceProvider = Provider<TopicTranslationService>(
  (ref) => const GoogleTopicTranslationService(),
);

abstract class TopicTranslationService {
  Future<Map<String, String>> translateTopic(
    String topic, {
    String? sourceLocaleCode,
    Map<String, String>? existingTranslations,
  });
}

class GoogleTopicTranslationService implements TopicTranslationService {
  const GoogleTopicTranslationService();

  static const Map<String, String> _serviceLocaleCodes = {
    'zh': 'zh-cn',
  };

  GoogleTranslator get _translator => GoogleTranslator();

  @override
  Future<Map<String, String>> translateTopic(
    String topic, {
    String? sourceLocaleCode,
    Map<String, String>? existingTranslations,
  }) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      return const {};
    }

    final translations = <String, String>{
      ...?existingTranslations,
    };

    if (sourceLocaleCode != null && sourceLocaleCode.isNotEmpty) {
      translations.putIfAbsent(sourceLocaleCode, () => trimmed);
    }

    for (final locale in SupportedLocale.values) {
      final localeCode = locale.code;
      final cached = translations[localeCode];
      if (cached != null && cached.trim().isNotEmpty) {
        continue;
      }

      if (localeCode == sourceLocaleCode) {
        translations[localeCode] = trimmed;
        continue;
      }

      try {
        final translated = sourceLocaleCode == null
            ? await _translator.translate(
                trimmed,
                to: _mapLocaleCode(localeCode),
              )
            : await _translator.translate(
                trimmed,
                from: _mapLocaleCode(sourceLocaleCode),
                to: _mapLocaleCode(localeCode),
              );

        final translatedText = translated.text.trim();
        if (translatedText.isNotEmpty) {
          translations[localeCode] = translatedText;
        }
      } catch (_) {
        // Keep missing translations unresolved so we can retry later.
      }
    }

    return translations;
  }

  String _mapLocaleCode(String code) {
    return _serviceLocaleCodes[code] ?? code;
  }
}
