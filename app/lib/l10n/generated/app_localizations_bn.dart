// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'বহিরাগত';

  @override
  String get settings => 'সেটিংস';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get darkModeSubtitle => 'রাতের সেশনের জন্য শান্ত অভিজ্ঞতা';

  @override
  String get haptics => 'হ্যাপটিক্স';

  @override
  String get hapticsSubtitle => 'ভূমিকা প্রকাশের সময় স্পর্শ প্রতিক্রিয়া';

  @override
  String get sound => 'শব্দ';

  @override
  String get soundSubtitle => 'শব্দ প্রভাব এবং সঙ্গীত';

  @override
  String get reducedMotion => 'কম অ্যানিমেশন';

  @override
  String get reducedMotionSubtitle => 'ধীর ডিভাইসের জন্য হালকা ট্রানজিশন';

  @override
  String get language => 'ভাষা';

  @override
  String get languageSubtitle => 'অ্যাপের ভাষা নির্বাচন করুন';

  @override
  String get followMe => 'আমাকে অনুসরণ করুন';

  @override
  String get openLinkError => 'লিংক খুলতে পারেনি';

  @override
  String get builtBy => 'Benaboud Mohamed Islam দ্বারা নির্মিত';

  @override
  String get copyright => '© বহিরাগত';

  @override
  String get home => 'হোম';

  @override
  String get store => 'স্টোর';

  @override
  String get statistics => 'পরিসংখ্যান';

  @override
  String get appTagline => 'দ্রুত সেশন, স্মার্ট প্রকাশ, আরবীয় স্পর্শ সহ।';

  @override
  String get startYourNight => 'আপনার রাত শুরু করুন';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'শেষ সেটআপ: $mode • $playerCount জন খেলোয়াড়';
  }

  @override
  String get startNewGame => 'নতুন খেলা শুরু করুন';

  @override
  String get quickRound => 'দ্রুত রাউন্ড';

  @override
  String get manageStories => 'গল্প পরিচালনা';

  @override
  String get readyModes => 'আজ রাতের জন্য প্রস্তুত মোড';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get featuredCategories => 'বিশেষ বিভাগ';

  @override
  String get packOfTheDay => 'আজকের প্যাক';

  @override
  String get tonightChallenge => 'আজ রাতের চ্যালেঞ্জ';

  @override
  String get tonightChallengeDesc =>
      'কোনো খেলোয়াড়কে বাদ না দিয়ে পরপর দুটি রাউন্ড খেলুন।';

  @override
  String get premium => 'প্রিমিয়াম';

  @override
  String get story => 'গল্প';

  @override
  String get stories => 'গল্প';

  @override
  String storyCount(int count) {
    return '$count টি গল্প';
  }

  @override
  String get addStory => 'গল্প যোগ করুন';

  @override
  String get enterStory => 'গল্প লিখুন';

  @override
  String get outsider => 'বহিরাগত';

  @override
  String get youAreOutsider => 'আপনি বহিরাগত';

  @override
  String get oneOfYouIsOutsider => 'আপনাদের মধ্যে একজন বহিরাগত';

  @override
  String get chooseOutsider => 'আপনার মনে হয় কে বহিরাগত তা নির্বাচন করুন';

  @override
  String get outsiderIs => 'বহিরাগত হলো';

  @override
  String get outsidersAre => 'বহিরাগতরা হলো';

  @override
  String get players => 'খেলোয়াড়';

  @override
  String get player => 'খেলোয়াড়';

  @override
  String playerCount(int count) {
    return '$count জন খেলোয়াড়';
  }

  @override
  String get addPlayer => 'খেলোয়াড় যোগ করুন';

  @override
  String get enterPlayerName => 'খেলোয়াড়ের নাম লিখুন';

  @override
  String minPlayersRequired(int min) {
    return 'কমপক্ষে $min জন খেলোয়াড় প্রয়োজন';
  }

  @override
  String get classic => 'ক্লাসিক';

  @override
  String get classicSubtitle => 'মূল মোড অপরিবর্তিত';

  @override
  String get quick => 'দ্রুত';

  @override
  String get quickSubtitle => 'হালকা খেলার জন্য ছোট রাউন্ড';

  @override
  String get teams => 'দল';

  @override
  String get teamsSubtitle => 'দুই দলের মধ্যে প্রতিযোগিতা';

  @override
  String get family => 'পারিবারিক';

  @override
  String get familySubtitle => 'সবার জন্য নিরাপদ গল্প';

  @override
  String get chaos => 'বিশৃঙ্খলা';

  @override
  String get chaosSubtitle => 'উল্টো নিয়ম এবং চমক';

  @override
  String get round => 'রাউন্ড';

  @override
  String roundNumber(int number) {
    return 'রাউন্ড $number';
  }

  @override
  String get revealPhase => 'প্রকাশ পর্ব';

  @override
  String get cluePhase => 'ইঙ্গিত পর্ব';

  @override
  String get discussionPhase => 'আলোচনা পর্ব';

  @override
  String get votingPhase => 'ভোট পর্ব';

  @override
  String get guessPhase => 'অনুমান পর্ব';

  @override
  String get yourRole => 'আপনার ভূমিকা';

  @override
  String get yourTopic => 'গল্প';

  @override
  String get tapToReveal => 'প্রকাশ করতে ট্যাপ করুন';

  @override
  String get hideRole => 'ভূমিকা লুকান';

  @override
  String get nextPlayer => 'পরবর্তী খেলোয়াড়';

  @override
  String get startRound => 'রাউন্ড শুরু করুন';

  @override
  String get endRound => 'রাউন্ড শেষ করুন';

  @override
  String get vote => 'ভোট';

  @override
  String get votes => 'ভোট';

  @override
  String voteCount(int count) {
    return '$count ভোট';
  }

  @override
  String get confirmVote => 'ভোট নিশ্চিত করুন';

  @override
  String get changeVote => 'ভোট পরিবর্তন করুন';

  @override
  String get guess => 'অনুমান';

  @override
  String get guessTheTopic => 'গল্প অনুমান করুন';

  @override
  String get correctGuess => 'সঠিক!';

  @override
  String get wrongGuess => 'ভুল!';

  @override
  String get results => 'ফলাফল';

  @override
  String get winner => 'বিজয়ী';

  @override
  String get winners => 'বিজয়ীরা';

  @override
  String get insidersWin => 'জানেওয়ালারা জিতেছে!';

  @override
  String get outsiderWins => 'বহিরাগত জিতেছে!';

  @override
  String get playAgain => 'আবার খেলুন';

  @override
  String get backToHome => 'হোমে ফিরুন';

  @override
  String get points => 'পয়েন্ট';

  @override
  String pointsCount(int count) {
    return '$count পয়েন্ট';
  }

  @override
  String get totalPoints => 'মোট পয়েন্ট';

  @override
  String get timer => 'টাইমার';

  @override
  String get seconds => 'সেকেন্ড';

  @override
  String get timeUp => 'সময় শেষ!';

  @override
  String get continue_ => 'চালিয়ে যান';

  @override
  String get cancel => 'বাতিল';

  @override
  String get confirm => 'নিশ্চিত';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get add => 'যোগ';

  @override
  String get close => 'বন্ধ';

  @override
  String get back => 'পেছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get selectCategories => 'বিভাগ নির্বাচন করুন';

  @override
  String get categories => 'বিভাগ';

  @override
  String get category => 'বিভাগ';

  @override
  String get allCategories => 'সব বিভাগ';

  @override
  String get setup => 'সেটআপ';

  @override
  String get gameSetup => 'গেম সেটআপ';

  @override
  String get selectMode => 'মোড নির্বাচন করুন';

  @override
  String get selectPlayers => 'খেলোয়াড় নির্বাচন করুন';

  @override
  String get onboardingTitle1 => 'বহিরাগতে স্বাগতম';

  @override
  String get onboardingDesc1 =>
      'বিষয় না জানা ব্যক্তিকে খুঁজে বের করার একটি মজার গ্রুপ গেম';

  @override
  String get onboardingTitle2 => 'কীভাবে খেলবেন';

  @override
  String get onboardingDesc2 =>
      'একজন গল্প জানে না, বাকিরা তাকে খুঁজে বের করার চেষ্টা করে';

  @override
  String get onboardingTitle3 => 'এখনই শুরু করুন';

  @override
  String get onboardingDesc3 => 'আপনার বন্ধুদের জড়ো করুন এবং মজা শুরু করুন';

  @override
  String get getStarted => 'শুরু করুন';

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
  String get selectLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get languageChanged => 'ভাষা পরিবর্তন হয়েছে';
}
