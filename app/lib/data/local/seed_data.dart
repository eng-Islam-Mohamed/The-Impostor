import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';

const int starterPlayerCount = 5;
const int maxDefaultPlayerSlots = 8;

List<PlayerProfile> buildStarterPlayers({
  SupportedLocale locale = SupportedLocale.arabic,
}) {
  return List.generate(
    starterPlayerCount,
    (index) => PlayerProfile(
      id: 'player-$index',
      name: defaultPlayerName(index + 1, locale),
      avatarIndex: index,
      score: 0,
    ),
  );
}

String defaultPlayerName(int index, SupportedLocale locale) {
  final prefix = switch (locale) {
    SupportedLocale.arabic => 'لاعب',
    SupportedLocale.english => 'Player',
    SupportedLocale.chinese => '玩家',
    SupportedLocale.hindi => 'खिलाड़ी',
    SupportedLocale.spanish => 'Jugador',
    SupportedLocale.french => 'Joueur',
    SupportedLocale.bengali => 'খেলোয়াড়',
    SupportedLocale.portuguese => 'Jogador',
    SupportedLocale.russian => 'Игрок',
    SupportedLocale.indonesian => 'Pemain',
  };
  return '$prefix $index';
}

bool isDefaultPlayerName(String name) {
  final trimmed = name.trim();
  for (final locale in SupportedLocale.values) {
    for (var index = 1; index <= maxDefaultPlayerSlots + 20; index++) {
      if (trimmed == defaultPlayerName(index, locale)) {
        return true;
      }
    }
  }
  return false;
}

const seededCategoryPacks = [
  CategoryPack(
    id: 'countries',
    title: 'الدول',
    subtitle: 'اختر من قائمة دول معروفة ومباشرة لجولات التخمين والخداع.',
    difficultyLabel: 'أساسي',
    isPremium: false,
    topics: [
      'مصر',
      'السعودية',
      'الجزائر',
      'المغرب',
      'تونس',
      'قطر',
      'الكويت',
      'الأردن',
      'العراق',
      'سوريا',
      'لبنان',
      'تركيا',
      'فرنسا',
      'إيطاليا',
      'إسبانيا',
      'اليابان',
      'الصين',
      'الهند',
      'البرازيل',
      'كندا',
      'المكسيك',
      'جنوب أفريقيا',
      'الأرجنتين',
      'أستراليا',
    ],
  ),
  CategoryPack(
    id: 'historical-people',
    title: 'شخصيات تاريخية مشهورة',
    subtitle: 'شخصيات تاريخية معروفة من حضارات وعصور مختلفة.',
    difficultyLabel: 'أساسي',
    isPremium: false,
    topics: [
      'صلاح الدين الأيوبي',
      'كليوباترا',
      'يوليوس قيصر',
      'نابليون',
      'ألبرت أينشتاين',
      'إسحاق نيوتن',
      'ليوناردو دا فينشي',
      'جنكيز خان',
      'الإسكندر الأكبر',
      'عمر بن الخطاب',
      'هارون الرشيد',
      'Ibn Battuta',
      'Ibn Sina',
      'الخوارزمي',
      'الملكة فيكتوريا',
      'أبراهام لينكولن',
      'ونستون تشرشل',
      'مهاتما غاندي',
      'جان دارك',
      'ماري كوري',
      'نيكولا تسلا',
      'كريستوفر كولومبوس',
      'نيلسون مانديلا',
      'مارتن لوثر كينغ',
    ],
  ),
];
