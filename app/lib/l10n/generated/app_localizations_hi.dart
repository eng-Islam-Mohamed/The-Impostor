// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'बाहरी व्यक्ति';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get darkModeSubtitle => 'रात के सत्रों के लिए शांत अनुभव';

  @override
  String get haptics => 'हैप्टिक्स';

  @override
  String get hapticsSubtitle => 'भूमिका प्रकट करते समय स्पर्श प्रतिक्रिया';

  @override
  String get sound => 'ध्वनि';

  @override
  String get soundSubtitle => 'ध्वनि प्रभाव और संगीत';

  @override
  String get reducedMotion => 'कम मोशन';

  @override
  String get reducedMotionSubtitle => 'धीमे उपकरणों के लिए हल्के ट्रांज़िशन';

  @override
  String get language => 'भाषा';

  @override
  String get languageSubtitle => 'ऐप भाषा चुनें';

  @override
  String get followMe => 'मुझे फॉलो करें';

  @override
  String get openLinkError => 'लिंक नहीं खुल सका';

  @override
  String get builtBy => 'Benaboud Mohamed Islam द्वारा निर्मित';

  @override
  String get copyright => '© बाहरी व्यक्ति';

  @override
  String get home => 'होम';

  @override
  String get store => 'स्टोर';

  @override
  String get statistics => 'आँकड़े';

  @override
  String get appTagline => 'तेज़ सत्र, स्मार्ट खुलासे, अरबी स्पर्श के साथ।';

  @override
  String get startYourNight => 'अपनी रात शुरू करें';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'पिछला सेटअप: $mode • $playerCount खिलाड़ी';
  }

  @override
  String get startNewGame => 'नया गेम शुरू करें';

  @override
  String get quickRound => 'त्वरित राउंड';

  @override
  String get manageStories => 'कहानियाँ प्रबंधित करें';

  @override
  String get readyModes => 'आज रात के लिए तैयार मोड';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get featuredCategories => 'विशेष श्रेणियाँ';

  @override
  String get packOfTheDay => 'आज का पैक';

  @override
  String get tonightChallenge => 'आज की चुनौती';

  @override
  String get tonightChallengeDesc =>
      'बिना किसी खिलाड़ी को बाहर किए दो लगातार राउंड खेलें।';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get story => 'कहानी';

  @override
  String get stories => 'कहानियाँ';

  @override
  String storyCount(int count) {
    return '$count कहानियाँ';
  }

  @override
  String get addStory => 'कहानी जोड़ें';

  @override
  String get enterStory => 'कहानी दर्ज करें';

  @override
  String get outsider => 'बाहरी व्यक्ति';

  @override
  String get youAreOutsider => 'आप बाहरी व्यक्ति हैं';

  @override
  String get oneOfYouIsOutsider => 'आप में से एक बाहरी व्यक्ति है';

  @override
  String get chooseOutsider => 'चुनें कि आपको कौन बाहरी व्यक्ति लगता है';

  @override
  String get outsiderIs => 'बाहरी व्यक्ति है';

  @override
  String get outsidersAre => 'बाहरी व्यक्ति हैं';

  @override
  String get players => 'खिलाड़ी';

  @override
  String get player => 'खिलाड़ी';

  @override
  String playerCount(int count) {
    return '$count खिलाड़ी';
  }

  @override
  String get addPlayer => 'खिलाड़ी जोड़ें';

  @override
  String get enterPlayerName => 'खिलाड़ी का नाम दर्ज करें';

  @override
  String minPlayersRequired(int min) {
    return 'कम से कम $min खिलाड़ी आवश्यक';
  }

  @override
  String get classic => 'क्लासिक';

  @override
  String get classicSubtitle => 'मूल मोड अपरिवर्तित';

  @override
  String get quick => 'त्वरित';

  @override
  String get quickSubtitle => 'हल्के खेल के लिए छोटे राउंड';

  @override
  String get teams => 'टीमें';

  @override
  String get teamsSubtitle => 'दो टीमों के बीच प्रतियोगिता';

  @override
  String get family => 'पारिवारिक';

  @override
  String get familySubtitle => 'सभी के लिए सुरक्षित कहानियाँ';

  @override
  String get chaos => 'अराजकता';

  @override
  String get chaosSubtitle => 'उलटे नियम और आश्चर्य';

  @override
  String get round => 'राउंड';

  @override
  String roundNumber(int number) {
    return 'राउंड $number';
  }

  @override
  String get revealPhase => 'प्रकट चरण';

  @override
  String get cluePhase => 'सुराग चरण';

  @override
  String get discussionPhase => 'चर्चा चरण';

  @override
  String get votingPhase => 'मतदान चरण';

  @override
  String get guessPhase => 'अनुमान चरण';

  @override
  String get yourRole => 'आपकी भूमिका';

  @override
  String get yourTopic => 'कहानी';

  @override
  String get tapToReveal => 'प्रकट करने के लिए टैप करें';

  @override
  String get hideRole => 'भूमिका छुपाएं';

  @override
  String get nextPlayer => 'अगला खिलाड़ी';

  @override
  String get startRound => 'राउंड शुरू करें';

  @override
  String get endRound => 'राउंड समाप्त करें';

  @override
  String get vote => 'वोट';

  @override
  String get votes => 'वोट';

  @override
  String voteCount(int count) {
    return '$count वोट';
  }

  @override
  String get confirmVote => 'वोट की पुष्टि करें';

  @override
  String get changeVote => 'वोट बदलें';

  @override
  String get guess => 'अनुमान';

  @override
  String get guessTheTopic => 'कहानी का अनुमान लगाएं';

  @override
  String get correctGuess => 'सही!';

  @override
  String get wrongGuess => 'गलत!';

  @override
  String get results => 'परिणाम';

  @override
  String get winner => 'विजेता';

  @override
  String get winners => 'विजेता';

  @override
  String get insidersWin => 'जानकार जीते!';

  @override
  String get outsiderWins => 'बाहरी व्यक्ति जीता!';

  @override
  String get playAgain => 'फिर से खेलें';

  @override
  String get backToHome => 'होम पर वापस';

  @override
  String get points => 'अंक';

  @override
  String pointsCount(int count) {
    return '$count अंक';
  }

  @override
  String get totalPoints => 'कुल अंक';

  @override
  String get timer => 'टाइमर';

  @override
  String get seconds => 'सेकंड';

  @override
  String get timeUp => 'समय समाप्त!';

  @override
  String get continue_ => 'जारी रखें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get done => 'हो गया';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get selectCategories => 'श्रेणियाँ चुनें';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get category => 'श्रेणी';

  @override
  String get allCategories => 'सभी श्रेणियाँ';

  @override
  String get setup => 'सेटअप';

  @override
  String get gameSetup => 'गेम सेटअप';

  @override
  String get selectMode => 'मोड चुनें';

  @override
  String get selectPlayers => 'खिलाड़ी चुनें';

  @override
  String get onboardingTitle1 => 'बाहरी व्यक्ति में आपका स्वागत है';

  @override
  String get onboardingDesc1 =>
      'विषय नहीं जानने वाले को ढूंढने का एक मज़ेदार समूह खेल';

  @override
  String get onboardingTitle2 => 'कैसे खेलें';

  @override
  String get onboardingDesc2 =>
      'एक व्यक्ति कहानी नहीं जानता, बाकी उसे ढूंढने की कोशिश करते हैं';

  @override
  String get onboardingTitle3 => 'अभी शुरू करें';

  @override
  String get onboardingDesc3 => 'अपने दोस्तों को इकट्ठा करें और मज़ा शुरू करें';

  @override
  String get getStarted => 'शुरू करें';

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
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get languageChanged => 'भाषा बदली गई';
}
