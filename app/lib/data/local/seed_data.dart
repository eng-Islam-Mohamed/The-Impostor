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
      'الجزائر',
      'المغرب',
      'تونس',
      'مصر',
      'السعودية',
      'الإمارات',
      'قطر',
      'الكويت',
      'تركيا',
      'فرنسا',
      'ألمانيا',
      'إيطاليا',
      'إسبانيا',
      'البرتغال',
      'بريطانيا',
      'روسيا',
      'أوكرانيا',
      'الولايات المتحدة',
      'كندا',
      'المكسيك',
      'البرازيل',
      'الأرجنتين',
      'اليابان',
      'الصين',
      'كوريا الجنوبية',
      'كوريا الشمالية',
      'الهند',
      'باكستان',
      'إيران',
      'العراق',
      'سوريا',
      'فلسطين',
      'الأردن',
      'لبنان',
      'جنوب أفريقيا',
      'أستراليا',
      'سويسرا',
      'هولندا',
      'بلجيكا',
      'اليونان',
      'النرويج',
      'السويد',
      'الدنمارك',
      'فنلندا',
      'النمسا',
      'بولندا',
      'التشيك',
      'رومانيا',
      'صربيا',
      'كرواتيا',
      'أيرلندا',
      'نيوزيلندا',
      'إندونيسيا',
      'ماليزيا',
      'تايلاند',
      'فيتنام',
      'أفغانستان',
      'إثيوبيا',
      'نيجيريا',
      'السنغال',
      'كولومبيا',
    ],
  ),
  CategoryPack(
    id: 'historical-people',
    title: 'شخصيات تاريخية مشهورة',
    subtitle: 'شخصيات تاريخية معروفة من حضارات وعصور مختلفة.',
    difficultyLabel: 'أساسي',
    isPremium: false,
    topics: [
      'نابليون بونابرت',
      'يوليوس قيصر',
      'الإسكندر الأكبر',
      'جنكيز خان',
      'صلاح الدين الأيوبي',
      'خالد بن الوليد',
      'طارق بن زياد',
      'هارون الرشيد',
      'محمد الفاتح',
      'سليمان القانوني',
      'كليوباترا',
      'الملكة إليزابيث الثانية',
      'أدولف هتلر',
      'جوزيف ستالين',
      'نيلسون مانديلا',
      'المهاتما غاندي',
      'ألبرت أينشتاين',
      'إسحاق نيوتن',
      'غاليليو غاليلي',
      'نيكولا تسلا',
      'توماس إديسون',
      'ماري كوري',
      'تشارلز داروين',
      'ستيفن هوكينغ',
      'ابن سينا',
      'الخوارزمي',
      'ابن الهيثم',
      'ليوناردو دا فينشي',
      'كريستوفر كولومبوس',
      'ماركو بولو',
      'وليام شكسبير',
      'بيتهوفن',
      'موزارت',
      'بيكاسو',
      'محمد علي كلاي',
      'أرخميدس',
      'نيكولاس كوبرنيكوس',
      'يوهانس كبلر',
      'مايكل فاراداي',
      'جيمس كليرك ماكسويل',
      'أنطوان لافوازييه',
      'نيلز بور',
      'ماكس بلانك',
      'إرفين شرودنغر',
      'ريتشارد فاينمان',
      'هانيبال برقا',
      'سكيبيو الإفريقي',
      'سبارتاكوس',
      'ليونيداس',
      'سون تزو',
      'أتيلا الهوني',
      'ريتشارد قلب الأسد',
      'بيبرس',
      'تيمورلنك',
      'عمر بن الخطاب',
      'ابن بطوطة',
      'الملكة فيكتوريا',
      'أبراهام لينكولن',
      'ونستون تشرشل',
      'جان دارك',
      'مارتن لوثر كينغ',
    ],
  ),
];
