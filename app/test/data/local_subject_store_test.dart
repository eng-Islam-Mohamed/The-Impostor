import 'dart:convert';
import 'dart:io';

import 'package:bara_alsalfa/data/local/local_subject_store.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expanded built-in packs contain unique supplied topics', () {
    final countries = seededCategoryPacks.firstWhere(
      (pack) => pack.id == 'countries',
    );
    final people = seededCategoryPacks.firstWhere(
      (pack) => pack.id == 'historical-people',
    );

    expect(
      countries.topics,
      containsAll(['الإمارات', 'كوريا الشمالية', 'السنغال', 'كولومبيا']),
    );
    expect(
      people.topics,
      containsAll([
        'نابليون بونابرت',
        'ابن سينا',
        'ريتشارد فاينمان',
        'تيمورلنك',
      ]),
    );
    expect(countries.topics.toSet(), hasLength(countries.topics.length));
    expect(people.topics.toSet(), hasLength(people.topics.length));
    expect(countries.topics.length, 61);
    expect(people.topics.length, 61);
  });

  test('legacy subject files migrate once and preserve custom packs', () async {
    final tempDirectory = await Directory.systemTemp.createTemp('subjects-');
    addTearDown(() => tempDirectory.delete(recursive: true));
    final file = File('${tempDirectory.path}/subjects.json');
    final legacyPacks = [
      const CategoryPack(
        id: 'countries',
        title: 'الدول',
        subtitle: 'Legacy',
        difficultyLabel: 'أساسي',
        isPremium: false,
        topics: ['الجزائر', 'بلد مخصص'],
      ),
      const CategoryPack(
        id: 'historical-people',
        title: 'شخصيات',
        subtitle: 'Legacy',
        difficultyLabel: 'أساسي',
        isPremium: false,
        topics: ['نابليون', 'Ibn Sina'],
      ),
      const CategoryPack(
        id: 'custom-friends',
        title: 'الأصدقاء',
        subtitle: 'Custom',
        difficultyLabel: 'Custom',
        isPremium: false,
        topics: ['إسلام', 'علي'],
      ),
    ];
    await file.writeAsString(
      jsonEncode(legacyPacks.map((pack) => pack.toJson()).toList()),
    );

    final store = LocalSubjectsStore(filePath: file.path);
    final migrated = await store.load();
    final countries = migrated.firstWhere((pack) => pack.id == 'countries');
    final people = migrated.firstWhere(
      (pack) => pack.id == 'historical-people',
    );

    expect(countries.topics, containsAll(['بلد مخصص', 'الإمارات', 'السنغال']));
    expect(people.topics, contains('نابليون بونابرت'));
    expect(people.topics, contains('ابن سينا'));
    expect(people.topics, isNot(contains('نابليون')));
    expect(migrated.any((pack) => pack.id == 'custom-friends'), isTrue);

    final persisted =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(persisted['seedVersion'], 2);
  });
}
