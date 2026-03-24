import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// The app title
  ///
  /// In ar, this message translates to:
  /// **'برا السالفة'**
  String get appTitle;

  /// Settings page title
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تجربة أكثر هدوءًا للسهرات الليلية'**
  String get darkModeSubtitle;

  /// No description provided for @haptics.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزازات'**
  String get haptics;

  /// No description provided for @hapticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لمسات تكتيكية أثناء كشف الدور'**
  String get hapticsSubtitle;

  /// No description provided for @sound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get sound;

  /// No description provided for @soundSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لوصل المؤثرات والموسيقى لاحقًا'**
  String get soundSubtitle;

  /// No description provided for @reducedMotion.
  ///
  /// In ar, this message translates to:
  /// **'تقليل الحركة'**
  String get reducedMotion;

  /// No description provided for @reducedMotionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انتقالات أخف للأجهزة الأبطأ أو لمن يفضّل الهدوء'**
  String get reducedMotionSubtitle;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق'**
  String get languageSubtitle;

  /// No description provided for @followMe.
  ///
  /// In ar, this message translates to:
  /// **'تابعني'**
  String get followMe;

  /// No description provided for @openLinkError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط الآن'**
  String get openLinkError;

  /// No description provided for @builtBy.
  ///
  /// In ar, this message translates to:
  /// **'Built by Benaboud Mohamed Islam'**
  String get builtBy;

  /// No description provided for @copyright.
  ///
  /// In ar, this message translates to:
  /// **'© برا السالفة'**
  String get copyright;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @store.
  ///
  /// In ar, this message translates to:
  /// **'المتجر'**
  String get store;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'جلسات أسرع، كشف أذكى، ولمسة عربية محسوبة.'**
  String get appTagline;

  /// No description provided for @startYourNight.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ سهرتك الآن'**
  String get startYourNight;

  /// No description provided for @lastSavedSetup.
  ///
  /// In ar, this message translates to:
  /// **'آخر إعداد محفوظ: {mode} • {playerCount} لاعبين'**
  String lastSavedSetup(String mode, int playerCount);

  /// No description provided for @startNewGame.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ لعبة جديدة'**
  String get startNewGame;

  /// No description provided for @quickRound.
  ///
  /// In ar, this message translates to:
  /// **'جولة سريعة'**
  String get quickRound;

  /// No description provided for @manageStories.
  ///
  /// In ar, this message translates to:
  /// **'إدارة السوالف'**
  String get manageStories;

  /// No description provided for @readyModes.
  ///
  /// In ar, this message translates to:
  /// **'أوضاع جاهزة لليلة'**
  String get readyModes;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get comingSoon;

  /// No description provided for @featuredCategories.
  ///
  /// In ar, this message translates to:
  /// **'فئات مميزة'**
  String get featuredCategories;

  /// No description provided for @packOfTheDay.
  ///
  /// In ar, this message translates to:
  /// **'باك اليوم'**
  String get packOfTheDay;

  /// No description provided for @tonightChallenge.
  ///
  /// In ar, this message translates to:
  /// **'تحدي الليلة'**
  String get tonightChallenge;

  /// No description provided for @tonightChallengeDesc.
  ///
  /// In ar, this message translates to:
  /// **'العب جولتين متتاليتين بدون حذف أي لاعب من التصويت.'**
  String get tonightChallengeDesc;

  /// No description provided for @premium.
  ///
  /// In ar, this message translates to:
  /// **'Premium'**
  String get premium;

  /// The word for story/topic in the game context
  ///
  /// In ar, this message translates to:
  /// **'سالفة'**
  String get story;

  /// Plural form of story
  ///
  /// In ar, this message translates to:
  /// **'سوالف'**
  String get stories;

  /// No description provided for @storyCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سالفة'**
  String storyCount(int count);

  /// No description provided for @addStory.
  ///
  /// In ar, this message translates to:
  /// **'أضف سالفة'**
  String get addStory;

  /// No description provided for @enterStory.
  ///
  /// In ar, this message translates to:
  /// **'أدخل السالفة'**
  String get enterStory;

  /// The outsider role - someone who doesn't know the topic
  ///
  /// In ar, this message translates to:
  /// **'برا السالفة'**
  String get outsider;

  /// No description provided for @youAreOutsider.
  ///
  /// In ar, this message translates to:
  /// **'أنت برا السالفة'**
  String get youAreOutsider;

  /// No description provided for @oneOfYouIsOutsider.
  ///
  /// In ar, this message translates to:
  /// **'واحد منكم برا السالفة'**
  String get oneOfYouIsOutsider;

  /// No description provided for @chooseOutsider.
  ///
  /// In ar, this message translates to:
  /// **'اختر من تظنه برا السالفة'**
  String get chooseOutsider;

  /// No description provided for @outsiderIs.
  ///
  /// In ar, this message translates to:
  /// **'برا السالفة هو'**
  String get outsiderIs;

  /// No description provided for @outsidersAre.
  ///
  /// In ar, this message translates to:
  /// **'برا السالفة هم'**
  String get outsidersAre;

  /// No description provided for @players.
  ///
  /// In ar, this message translates to:
  /// **'اللاعبون'**
  String get players;

  /// No description provided for @player.
  ///
  /// In ar, this message translates to:
  /// **'لاعب'**
  String get player;

  /// No description provided for @playerCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} لاعبين'**
  String playerCount(int count);

  /// No description provided for @addPlayer.
  ///
  /// In ar, this message translates to:
  /// **'أضف لاعب'**
  String get addPlayer;

  /// No description provided for @enterPlayerName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم اللاعب'**
  String get enterPlayerName;

  /// No description provided for @minPlayersRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب إضافة {min} لاعبين على الأقل'**
  String minPlayersRequired(int min);

  /// No description provided for @classic.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيك'**
  String get classic;

  /// No description provided for @classicSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الأصلي بدون تعديل'**
  String get classicSubtitle;

  /// No description provided for @quick.
  ///
  /// In ar, this message translates to:
  /// **'سريع'**
  String get quick;

  /// No description provided for @quickSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'جولات أقصر للعب الخفيف'**
  String get quickSubtitle;

  /// No description provided for @teams.
  ///
  /// In ar, this message translates to:
  /// **'فرق'**
  String get teams;

  /// No description provided for @teamsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنافس بين فريقين'**
  String get teamsSubtitle;

  /// No description provided for @family.
  ///
  /// In ar, this message translates to:
  /// **'عائلي'**
  String get family;

  /// No description provided for @familySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سوالف آمنة للجميع'**
  String get familySubtitle;

  /// No description provided for @chaos.
  ///
  /// In ar, this message translates to:
  /// **'فوضى'**
  String get chaos;

  /// No description provided for @chaosSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قواعد مقلوبة ومفاجآت'**
  String get chaosSubtitle;

  /// No description provided for @round.
  ///
  /// In ar, this message translates to:
  /// **'جولة'**
  String get round;

  /// No description provided for @roundNumber.
  ///
  /// In ar, this message translates to:
  /// **'الجولة {number}'**
  String roundNumber(int number);

  /// No description provided for @revealPhase.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة الكشف'**
  String get revealPhase;

  /// No description provided for @cluePhase.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة التلميحات'**
  String get cluePhase;

  /// No description provided for @discussionPhase.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة النقاش'**
  String get discussionPhase;

  /// No description provided for @votingPhase.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة التصويت'**
  String get votingPhase;

  /// No description provided for @guessPhase.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة التخمين'**
  String get guessPhase;

  /// No description provided for @yourRole.
  ///
  /// In ar, this message translates to:
  /// **'دورك'**
  String get yourRole;

  /// No description provided for @yourTopic.
  ///
  /// In ar, this message translates to:
  /// **'السالفة'**
  String get yourTopic;

  /// No description provided for @tapToReveal.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للكشف'**
  String get tapToReveal;

  /// No description provided for @hideRole.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الدور'**
  String get hideRole;

  /// No description provided for @nextPlayer.
  ///
  /// In ar, this message translates to:
  /// **'اللاعب التالي'**
  String get nextPlayer;

  /// No description provided for @startRound.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الجولة'**
  String get startRound;

  /// No description provided for @endRound.
  ///
  /// In ar, this message translates to:
  /// **'أنهِ الجولة'**
  String get endRound;

  /// No description provided for @vote.
  ///
  /// In ar, this message translates to:
  /// **'صوّت'**
  String get vote;

  /// No description provided for @votes.
  ///
  /// In ar, this message translates to:
  /// **'أصوات'**
  String get votes;

  /// No description provided for @voteCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} صوت'**
  String voteCount(int count);

  /// No description provided for @confirmVote.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التصويت'**
  String get confirmVote;

  /// No description provided for @changeVote.
  ///
  /// In ar, this message translates to:
  /// **'تغيير التصويت'**
  String get changeVote;

  /// No description provided for @guess.
  ///
  /// In ar, this message translates to:
  /// **'خمّن'**
  String get guess;

  /// No description provided for @guessTheTopic.
  ///
  /// In ar, this message translates to:
  /// **'خمّن السالفة'**
  String get guessTheTopic;

  /// No description provided for @correctGuess.
  ///
  /// In ar, this message translates to:
  /// **'إجابة صحيحة!'**
  String get correctGuess;

  /// No description provided for @wrongGuess.
  ///
  /// In ar, this message translates to:
  /// **'إجابة خاطئة!'**
  String get wrongGuess;

  /// No description provided for @results.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get results;

  /// No description provided for @winner.
  ///
  /// In ar, this message translates to:
  /// **'الفائز'**
  String get winner;

  /// No description provided for @winners.
  ///
  /// In ar, this message translates to:
  /// **'الفائزون'**
  String get winners;

  /// No description provided for @insidersWin.
  ///
  /// In ar, this message translates to:
  /// **'فاز أصحاب السالفة!'**
  String get insidersWin;

  /// No description provided for @outsiderWins.
  ///
  /// In ar, this message translates to:
  /// **'فاز من هو برا السالفة!'**
  String get outsiderWins;

  /// No description provided for @playAgain.
  ///
  /// In ar, this message translates to:
  /// **'العب مرة أخرى'**
  String get playAgain;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backToHome;

  /// No description provided for @points.
  ///
  /// In ar, this message translates to:
  /// **'نقاط'**
  String get points;

  /// No description provided for @pointsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نقطة'**
  String pointsCount(int count);

  /// No description provided for @totalPoints.
  ///
  /// In ar, this message translates to:
  /// **'مجموع النقاط'**
  String get totalPoints;

  /// No description provided for @timer.
  ///
  /// In ar, this message translates to:
  /// **'المؤقت'**
  String get timer;

  /// No description provided for @seconds.
  ///
  /// In ar, this message translates to:
  /// **'ثانية'**
  String get seconds;

  /// No description provided for @timeUp.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت!'**
  String get timeUp;

  /// No description provided for @continue_.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continue_;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @selectCategories.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئات'**
  String get selectCategories;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'فئة'**
  String get category;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'جميع الفئات'**
  String get allCategories;

  /// No description provided for @setup.
  ///
  /// In ar, this message translates to:
  /// **'الإعداد'**
  String get setup;

  /// No description provided for @gameSetup.
  ///
  /// In ar, this message translates to:
  /// **'إعداد اللعبة'**
  String get gameSetup;

  /// No description provided for @selectMode.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوضع'**
  String get selectMode;

  /// No description provided for @selectPlayers.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللاعبين'**
  String get selectPlayers;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا في برا السالفة'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ar, this message translates to:
  /// **'لعبة جماعية ممتعة لكشف من لا يعرف الموضوع'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'كيف تلعب'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ar, this message translates to:
  /// **'شخص واحد لا يعرف السالفة، والباقي يحاولون كشفه'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ar, this message translates to:
  /// **'اجمع أصدقاءك وابدأ المتعة'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get getStarted;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In ar, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageHindi.
  ///
  /// In ar, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageSpanish.
  ///
  /// In ar, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In ar, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageBengali.
  ///
  /// In ar, this message translates to:
  /// **'বাংলা'**
  String get languageBengali;

  /// No description provided for @languagePortuguese.
  ///
  /// In ar, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageRussian.
  ///
  /// In ar, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageIndonesian.
  ///
  /// In ar, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة'**
  String get languageChanged;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
