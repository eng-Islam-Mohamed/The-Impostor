import 'package:bara_alsalfa/core/i18n/topic_translation_service.dart';
import 'package:bara_alsalfa/data/local/local_topic_translation_store.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final topicTranslationsStoreProvider = Provider<TopicTranslationsStore>(
  (ref) => LocalTopicTranslationsStore(),
);

final initialTopicTranslationsProvider =
    Provider<Map<String, Map<String, String>>>(
  (ref) => const {},
);

class TopicTranslationsController
    extends Notifier<Map<String, Map<String, String>>> {
  final Set<String> _inFlight = <String>{};

  TopicTranslationsStore get _store => ref.read(topicTranslationsStoreProvider);
  TopicTranslationService get _service =>
      ref.read(topicTranslationServiceProvider);

  @override
  Map<String, Map<String, String>> build() {
    return ref.read(initialTopicTranslationsProvider);
  }

  static String buildTopicKey(String packId, String topic) => '$packId::$topic';

  String localizedTopic({
    required String packId,
    required String topic,
    required SupportedLocale locale,
    String? sourceLocaleCode,
  }) {
    final key = buildTopicKey(packId, topic);
    final localized = state[key]?[locale.code]?.trim();

    if (localized != null && localized.isNotEmpty) {
      return localized;
    }

    if (_isMissingAnyTranslation(state[key]) && !_inFlight.contains(key)) {
      Future<void>.microtask(
        () => ensureTranslations(
          packId: packId,
          topic: topic,
          sourceLocaleCode: sourceLocaleCode,
        ),
      );
    }

    return topic;
  }

  Future<void> ensureTranslations({
    required String packId,
    required String topic,
    String? sourceLocaleCode,
  }) async {
    final key = buildTopicKey(packId, topic);
    if (_inFlight.contains(key)) {
      return;
    }

    final existing = state[key];
    if (!_isMissingAnyTranslation(existing)) {
      return;
    }

    _inFlight.add(key);
    try {
      final translated = await _service.translateTopic(
        topic,
        sourceLocaleCode: sourceLocaleCode,
        existingTranslations: existing,
      );
      if (translated.isEmpty) {
        return;
      }

      state = {
        ...state,
        key: {
          ...?existing,
          ...translated,
        },
      };
      await _store.save(state);
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<void> ensureTopicsTranslated({
    required String packId,
    required Iterable<String> topics,
    String? sourceLocaleCode,
  }) async {
    for (final topic in topics.toSet()) {
      final trimmed = topic.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      await ensureTranslations(
        packId: packId,
        topic: trimmed,
        sourceLocaleCode: sourceLocaleCode,
      );
    }
  }

  Future<void> removeTranslations({
    required String packId,
    required String topic,
  }) async {
    final key = buildTopicKey(packId, topic);
    if (!state.containsKey(key)) {
      return;
    }

    final updated = Map<String, Map<String, String>>.from(state)
      ..remove(key);
    state = updated;
    await _store.save(updated);
  }

  bool _isMissingAnyTranslation(Map<String, String>? translations) {
    if (translations == null || translations.isEmpty) {
      return true;
    }

    for (final locale in SupportedLocale.values) {
      final value = translations[locale.code];
      if (value == null || value.trim().isEmpty) {
        return true;
      }
    }
    return false;
  }
}

final topicTranslationsProvider =
    NotifierProvider<TopicTranslationsController, Map<String, Map<String, String>>>(
  TopicTranslationsController.new,
);
