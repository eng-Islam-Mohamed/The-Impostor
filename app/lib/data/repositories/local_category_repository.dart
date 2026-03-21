import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subjectsStoreProvider = Provider<SubjectsStore>(
  (ref) => throw UnimplementedError('SubjectsStore override missing.'),
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
}

final categoryLibraryProvider =
    NotifierProvider<CategoryLibraryController, List<CategoryPack>>(
  CategoryLibraryController.new,
);
