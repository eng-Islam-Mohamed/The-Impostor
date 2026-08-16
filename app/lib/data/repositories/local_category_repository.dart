import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subjectsStoreProvider = Provider<SubjectsStore>(
  (ref) => LocalSubjectsStore(),
);

final initialCategoryPacksProvider = Provider<List<CategoryPack>>(
  (ref) => seededCategoryPacks,
);

class CategoryLibraryController extends Notifier<List<CategoryPack>> {
  SubjectsStore get _store => ref.read(subjectsStoreProvider);

  @override
  List<CategoryPack> build() => ref.read(initialCategoryPacksProvider);

  CategoryPack getPackById(String id) {
    return state.firstWhere((pack) => pack.id == id);
  }

  Future<CategoryPack> addPack({
    required String title,
    String? subtitle,
    List<String> topics = const [],
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Pack title cannot be empty.');
    }

    final cleanedTopics =
        topics
            .map((topic) => topic.trim())
            .where((topic) => topic.isNotEmpty)
            .toSet()
            .toList(growable: true)
          ..sort((a, b) => a.compareTo(b));
    final pack = CategoryPack(
      id: _uniquePackId(trimmedTitle),
      title: trimmedTitle,
      subtitle: (subtitle?.trim().isNotEmpty ?? false)
          ? subtitle!.trim()
          : 'Custom subject section',
      difficultyLabel: 'Custom',
      isPremium: false,
      topics: cleanedTopics.isEmpty ? ['New subject'] : cleanedTopics,
    );
    state = [...state, pack];
    await _store.save(state);
    return pack;
  }

  Future<void> addTopic(String packId, String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final pack = getPackById(packId);
    final exists = pack.topics.any(
      (item) => item.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      return;
    }

    state = [
      for (final item in state)
        if (item.id == packId)
          item.copyWith(
            topics: [...item.topics, trimmed]..sort((a, b) => a.compareTo(b)),
          )
        else
          item,
    ];
    await _store.save(state);
  }

  Future<void> removeTopic(String packId, String topic) async {
    final pack = getPackById(packId);
    if (pack.topics.length <= 1) {
      return;
    }

    state = [
      for (final item in state)
        if (item.id == packId)
          item.copyWith(
            topics: item.topics.where((entry) => entry != topic).toList(),
          )
        else
          item,
    ];
    await _store.save(state);
  }

  String _uniquePackId(String title) {
    final base = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final seed = base.isEmpty
        ? 'custom-${DateTime.now().millisecondsSinceEpoch}'
        : 'custom-$base';
    final existingIds = state.map((pack) => pack.id).toSet();
    if (!existingIds.contains(seed)) {
      return seed;
    }
    var index = 2;
    while (existingIds.contains('$seed-$index')) {
      index++;
    }
    return '$seed-$index';
  }
}

final categoryLibraryProvider =
    NotifierProvider<CategoryLibraryController, List<CategoryPack>>(
      CategoryLibraryController.new,
    );
