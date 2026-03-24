import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String uiPhrasePackId = '_ui';

String localizeUiPhrase(
  WidgetRef ref,
  String phrase, {
  String? sourceLocaleCode,
}) {
  final locale = ref.read(appSettingsProvider).locale;
  final normalizedSource = sourceLocaleCode ?? _inferSourceLocaleCode(phrase);
  return ref.read(topicTranslationsProvider.notifier).localizedTopic(
        packId: uiPhrasePackId,
        topic: phrase,
        locale: locale,
        sourceLocaleCode: normalizedSource,
      );
}

void warmUiPhrases(
  WidgetRef ref,
  Iterable<String> phrases, {
  String? sourceLocaleCode,
}) {
  final locale = ref.read(appSettingsProvider).locale;
  if (locale == SupportedLocale.arabic) {
    return;
  }

  final cleaned = phrases.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet();
  if (cleaned.isEmpty) {
    return;
  }

  Future<void>.microtask(() async {
    for (final phrase in cleaned) {
      await ref.read(topicTranslationsProvider.notifier).ensureTranslations(
            packId: uiPhrasePackId,
            topic: phrase,
            sourceLocaleCode: sourceLocaleCode ?? _inferSourceLocaleCode(phrase),
          );
    }
  });
}

String _inferSourceLocaleCode(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? 'ar' : 'en';
}
