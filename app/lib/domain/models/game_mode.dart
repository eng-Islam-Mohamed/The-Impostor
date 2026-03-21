enum GameMode {
  classic,
  quick,
  teams,
  family,
  chaos;

  String get slug => switch (this) {
        GameMode.classic => 'classic',
        GameMode.quick => 'quick',
        GameMode.teams => 'teams',
        GameMode.family => 'family',
        GameMode.chaos => 'chaos',
      };

  String get title => switch (this) {
        GameMode.classic => 'الوضع الكلاسيكي',
        GameMode.quick => 'جولة سريعة',
        GameMode.teams => 'وضع الفرق',
        GameMode.family => 'العائلة',
        GameMode.chaos => 'وضع الفوضى',
      };

  String get subtitle => switch (this) {
        GameMode.classic => 'أفضل نسخة للجلسات الأساسية والتخمين النظيف.',
        GameMode.quick => 'إعداد أسرع ومؤقت أخف لإعادة اللعب بسرعة.',
        GameMode.teams => 'تنافس جماعي وصخب أكبر.',
        GameMode.family => 'نبرة ألطف وأسهل للجلسات العائلية.',
        GameMode.chaos => 'مفاجآت وتعديلات للمحترفين.',
      };

  String get playerRange => switch (this) {
        GameMode.classic => '4-12',
        GameMode.quick => '3-8',
        GameMode.teams => '6-14',
        GameMode.family => '4-10',
        GameMode.chaos => '5-12',
      };

  int get minPlayers => switch (this) {
        GameMode.quick => 3,
        GameMode.classic || GameMode.family => 4,
        GameMode.chaos => 5,
        GameMode.teams => 6,
      };

  int get maxPlayers => switch (this) {
        GameMode.quick => 8,
        GameMode.classic || GameMode.chaos => 12,
        GameMode.family => 10,
        GameMode.teams => 14,
      };

  bool get isMvpAvailable => switch (this) {
        GameMode.classic || GameMode.quick => true,
        _ => false,
      };

  int get defaultDiscussionSeconds => switch (this) {
        GameMode.quick => 35,
        _ => 60,
      };

  static GameMode fromSlug(String? slug) {
    return GameMode.values.firstWhere(
      (mode) => mode.slug == slug,
      orElse: () => GameMode.classic,
    );
  }
}
