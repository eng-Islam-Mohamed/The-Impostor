import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';

extension GameModeText on GameMode {
  String localizedTitle(AppLocalizations l10n) => switch (this) {
        GameMode.classic => l10n.classic,
        GameMode.quick => l10n.quick,
        GameMode.teams => l10n.teams,
        GameMode.family => l10n.family,
        GameMode.chaos => l10n.chaos,
      };

  String localizedSubtitle(AppLocalizations l10n) => switch (this) {
        GameMode.classic => l10n.classicSubtitle,
        GameMode.quick => l10n.quickSubtitle,
        GameMode.teams => l10n.teamsSubtitle,
        GameMode.family => l10n.familySubtitle,
        GameMode.chaos => l10n.chaosSubtitle,
      };
}

String localizedPackTitle(CategoryPack pack, SupportedLocale locale) {
  return switch (pack.id) {
    'countries' => _pickByLocale(locale, const {
        'ar': 'الدول',
        'en': 'Countries',
        'zh': '国家',
        'hi': 'देश',
        'es': 'Países',
        'fr': 'Pays',
        'bn': 'দেশসমূহ',
        'pt': 'Países',
        'ru': 'Страны',
        'id': 'Negara',
      }),
    'historical-people' => _pickByLocale(locale, const {
        'ar': 'شخصيات تاريخية مشهورة',
        'en': 'Famous Historical Figures',
        'zh': '著名历史人物',
        'hi': 'प्रसिद्ध ऐतिहासिक व्यक्तित्व',
        'es': 'Personajes Históricos Famosos',
        'fr': 'Personnages Historiques Célèbres',
        'bn': 'বিখ্যাত ঐতিহাসিক ব্যক্তিত্ব',
        'pt': 'Figuras Históricas Famosas',
        'ru': 'Известные Исторические Личности',
        'id': 'Tokoh Sejarah Terkenal',
      }),
    _ => pack.title,
  };
}

String localizedPackSubtitle(CategoryPack pack, SupportedLocale locale) {
  return switch (pack.id) {
    'countries' => _pickByLocale(locale, const {
        'ar': 'اختر من قائمة دول معروفة ومباشرة لجولات التخمين والخداع.',
        'en': 'Pick from well-known countries for fast bluffing rounds.',
        'zh': '从知名国家列表中选择，适合快速推理和伪装回合。',
        'hi': 'तेज़ ब्लफ़ और अनुमान राउंड के लिए प्रसिद्ध देशों की सूची।',
        'es': 'Elige entre países conocidos para rondas rápidas de farol y deducción.',
        'fr': 'Choisissez parmi des pays connus pour des manches rapides de bluff.',
        'bn': 'দ্রুত ব্লাফ ও অনুমানের রাউন্ডের জন্য পরিচিত দেশগুলোর তালিকা।',
        'pt': 'Escolha entre países conhecidos para rodadas rápidas de blefe.',
        'ru': 'Выбирайте известные страны для быстрых раундов блефа и догадок.',
        'id': 'Pilih negara terkenal untuk ronde tebak dan bluff yang cepat.',
      }),
    'historical-people' => _pickByLocale(locale, const {
        'ar': 'شخصيات تاريخية معروفة من حضارات وعصور مختلفة.',
        'en': 'Recognizable historical figures from different eras and civilizations.',
        'zh': '来自不同文明与时代、辨识度高的历史人物。',
        'hi': 'विभिन्न सभ्यताओं और युगों के पहचाने जाने वाले ऐतिहासिक व्यक्तित्व।',
        'es': 'Figuras históricas reconocibles de distintas épocas y civilizaciones.',
        'fr': 'Des figures historiques connues de différentes époques et civilisations.',
        'bn': 'বিভিন্ন যুগ ও সভ্যতার পরিচিত ঐতিহাসিক ব্যক্তিত্ব।',
        'pt': 'Figuras históricas reconhecíveis de diferentes eras e civilizações.',
        'ru': 'Узнаваемые исторические личности из разных эпох и цивилизаций.',
        'id': 'Tokoh sejarah terkenal dari berbagai era dan peradaban.',
      }),
    _ => pack.subtitle,
  };
}

String localizedDifficultyLabel(CategoryPack pack, SupportedLocale locale) {
  if (pack.isPremium) {
    return pack.difficultyLabel;
  }

  return _pickByLocale(locale, const {
    'ar': 'أساسي',
    'en': 'Basic',
    'zh': '基础',
    'hi': 'आधारभूत',
    'es': 'Básico',
    'fr': 'Essentiel',
    'bn': 'বেসিক',
    'pt': 'Básico',
    'ru': 'Базовый',
    'id': 'Dasar',
  });
}

String _pickByLocale(SupportedLocale locale, Map<String, String> translations) {
  return translations[locale.code] ?? translations['ar']!;
}
