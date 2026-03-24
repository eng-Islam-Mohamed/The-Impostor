// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'برا السالفة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeSubtitle => 'تجربة أكثر هدوءًا للسهرات الليلية';

  @override
  String get haptics => 'الاهتزازات';

  @override
  String get hapticsSubtitle => 'لمسات تكتيكية أثناء كشف الدور';

  @override
  String get sound => 'الصوت';

  @override
  String get soundSubtitle => 'جاهز لوصل المؤثرات والموسيقى لاحقًا';

  @override
  String get reducedMotion => 'تقليل الحركة';

  @override
  String get reducedMotionSubtitle =>
      'انتقالات أخف للأجهزة الأبطأ أو لمن يفضّل الهدوء';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'اختر لغة التطبيق';

  @override
  String get followMe => 'تابعني';

  @override
  String get openLinkError => 'تعذر فتح الرابط الآن';

  @override
  String get builtBy => 'Built by Benaboud Mohamed Islam';

  @override
  String get copyright => '© برا السالفة';

  @override
  String get home => 'الرئيسية';

  @override
  String get store => 'المتجر';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get appTagline => 'جلسات أسرع، كشف أذكى، ولمسة عربية محسوبة.';

  @override
  String get startYourNight => 'ابدأ سهرتك الآن';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'آخر إعداد محفوظ: $mode • $playerCount لاعبين';
  }

  @override
  String get startNewGame => 'ابدأ لعبة جديدة';

  @override
  String get quickRound => 'جولة سريعة';

  @override
  String get manageStories => 'إدارة السوالف';

  @override
  String get readyModes => 'أوضاع جاهزة لليلة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get featuredCategories => 'فئات مميزة';

  @override
  String get packOfTheDay => 'باك اليوم';

  @override
  String get tonightChallenge => 'تحدي الليلة';

  @override
  String get tonightChallengeDesc =>
      'العب جولتين متتاليتين بدون حذف أي لاعب من التصويت.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'سالفة';

  @override
  String get stories => 'سوالف';

  @override
  String storyCount(int count) {
    return '$count سالفة';
  }

  @override
  String get addStory => 'أضف سالفة';

  @override
  String get enterStory => 'أدخل السالفة';

  @override
  String get outsider => 'برا السالفة';

  @override
  String get youAreOutsider => 'أنت برا السالفة';

  @override
  String get oneOfYouIsOutsider => 'واحد منكم برا السالفة';

  @override
  String get chooseOutsider => 'اختر من تظنه برا السالفة';

  @override
  String get outsiderIs => 'برا السالفة هو';

  @override
  String get outsidersAre => 'برا السالفة هم';

  @override
  String get players => 'اللاعبون';

  @override
  String get player => 'لاعب';

  @override
  String playerCount(int count) {
    return '$count لاعبين';
  }

  @override
  String get addPlayer => 'أضف لاعب';

  @override
  String get enterPlayerName => 'أدخل اسم اللاعب';

  @override
  String minPlayersRequired(int min) {
    return 'يجب إضافة $min لاعبين على الأقل';
  }

  @override
  String get classic => 'كلاسيك';

  @override
  String get classicSubtitle => 'الوضع الأصلي بدون تعديل';

  @override
  String get quick => 'سريع';

  @override
  String get quickSubtitle => 'جولات أقصر للعب الخفيف';

  @override
  String get teams => 'فرق';

  @override
  String get teamsSubtitle => 'تنافس بين فريقين';

  @override
  String get family => 'عائلي';

  @override
  String get familySubtitle => 'سوالف آمنة للجميع';

  @override
  String get chaos => 'فوضى';

  @override
  String get chaosSubtitle => 'قواعد مقلوبة ومفاجآت';

  @override
  String get round => 'جولة';

  @override
  String roundNumber(int number) {
    return 'الجولة $number';
  }

  @override
  String get revealPhase => 'مرحلة الكشف';

  @override
  String get cluePhase => 'مرحلة التلميحات';

  @override
  String get discussionPhase => 'مرحلة النقاش';

  @override
  String get votingPhase => 'مرحلة التصويت';

  @override
  String get guessPhase => 'مرحلة التخمين';

  @override
  String get yourRole => 'دورك';

  @override
  String get yourTopic => 'السالفة';

  @override
  String get tapToReveal => 'اضغط للكشف';

  @override
  String get hideRole => 'إخفاء الدور';

  @override
  String get nextPlayer => 'اللاعب التالي';

  @override
  String get startRound => 'ابدأ الجولة';

  @override
  String get endRound => 'أنهِ الجولة';

  @override
  String get vote => 'صوّت';

  @override
  String get votes => 'أصوات';

  @override
  String voteCount(int count) {
    return '$count صوت';
  }

  @override
  String get confirmVote => 'تأكيد التصويت';

  @override
  String get changeVote => 'تغيير التصويت';

  @override
  String get guess => 'خمّن';

  @override
  String get guessTheTopic => 'خمّن السالفة';

  @override
  String get correctGuess => 'إجابة صحيحة!';

  @override
  String get wrongGuess => 'إجابة خاطئة!';

  @override
  String get results => 'النتائج';

  @override
  String get winner => 'الفائز';

  @override
  String get winners => 'الفائزون';

  @override
  String get insidersWin => 'فاز أصحاب السالفة!';

  @override
  String get outsiderWins => 'فاز من هو برا السالفة!';

  @override
  String get playAgain => 'العب مرة أخرى';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get points => 'نقاط';

  @override
  String pointsCount(int count) {
    return '$count نقطة';
  }

  @override
  String get totalPoints => 'مجموع النقاط';

  @override
  String get timer => 'المؤقت';

  @override
  String get seconds => 'ثانية';

  @override
  String get timeUp => 'انتهى الوقت!';

  @override
  String get continue_ => 'متابعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get skip => 'تخطي';

  @override
  String get done => 'تم';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get selectCategories => 'اختر الفئات';

  @override
  String get categories => 'الفئات';

  @override
  String get category => 'فئة';

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get setup => 'الإعداد';

  @override
  String get gameSetup => 'إعداد اللعبة';

  @override
  String get selectMode => 'اختر الوضع';

  @override
  String get selectPlayers => 'اختر اللاعبين';

  @override
  String get onboardingTitle1 => 'مرحبًا في برا السالفة';

  @override
  String get onboardingDesc1 => 'لعبة جماعية ممتعة لكشف من لا يعرف الموضوع';

  @override
  String get onboardingTitle2 => 'كيف تلعب';

  @override
  String get onboardingDesc2 =>
      'شخص واحد لا يعرف السالفة، والباقي يحاولون كشفه';

  @override
  String get onboardingTitle3 => 'ابدأ الآن';

  @override
  String get onboardingDesc3 => 'اجمع أصدقاءك وابدأ المتعة';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة';
}
