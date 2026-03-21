import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';

const List<String> playerNameSeeds = [
  'لاعب 1',
  'لاعب 2',
  'لاعب 3',
  'لاعب 4',
  'لاعب 5',
  'لاعب 6',
  'لاعب 7',
  'لاعب 8',
];

List<PlayerProfile> buildStarterPlayers() {
  return List.generate(
    5,
    (index) => PlayerProfile(
      id: 'player-$index',
      name: playerNameSeeds[index],
      avatarIndex: index,
      score: 0,
    ),
  );
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
