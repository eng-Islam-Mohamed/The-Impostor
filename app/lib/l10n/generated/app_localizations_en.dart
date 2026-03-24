// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Outside the Story';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'A calmer experience for night sessions';

  @override
  String get haptics => 'Haptics';

  @override
  String get hapticsSubtitle => 'Tactile feedback during role reveal';

  @override
  String get sound => 'Sound';

  @override
  String get soundSubtitle => 'Sound effects and music';

  @override
  String get reducedMotion => 'Reduced Motion';

  @override
  String get reducedMotionSubtitle =>
      'Lighter transitions for slower devices or preference';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Choose app language';

  @override
  String get followMe => 'Follow Me';

  @override
  String get openLinkError => 'Could not open link';

  @override
  String get builtBy => 'Built by Benaboud Mohamed Islam';

  @override
  String get copyright => '© Outside the Story';

  @override
  String get home => 'Home';

  @override
  String get store => 'Store';

  @override
  String get statistics => 'Statistics';

  @override
  String get appTagline =>
      'Faster sessions, smarter reveals, with an Arabic touch.';

  @override
  String get startYourNight => 'Start Your Night';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Last setup: $mode • $playerCount players';
  }

  @override
  String get startNewGame => 'Start New Game';

  @override
  String get quickRound => 'Quick Round';

  @override
  String get manageStories => 'Manage Stories';

  @override
  String get readyModes => 'Ready Modes for Tonight';

  @override
  String get viewAll => 'View All';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featuredCategories => 'Featured Categories';

  @override
  String get packOfTheDay => 'Pack of the Day';

  @override
  String get tonightChallenge => 'Tonight\'s Challenge';

  @override
  String get tonightChallengeDesc =>
      'Play two consecutive rounds without eliminating any player from voting.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'Story';

  @override
  String get stories => 'Stories';

  @override
  String storyCount(int count) {
    return '$count stories';
  }

  @override
  String get addStory => 'Add Story';

  @override
  String get enterStory => 'Enter the story';

  @override
  String get outsider => 'Outsider';

  @override
  String get youAreOutsider => 'You are the Outsider';

  @override
  String get oneOfYouIsOutsider => 'One of you is the Outsider';

  @override
  String get chooseOutsider => 'Choose who you think is the Outsider';

  @override
  String get outsiderIs => 'The Outsider is';

  @override
  String get outsidersAre => 'The Outsiders are';

  @override
  String get players => 'Players';

  @override
  String get player => 'Player';

  @override
  String playerCount(int count) {
    return '$count players';
  }

  @override
  String get addPlayer => 'Add Player';

  @override
  String get enterPlayerName => 'Enter player name';

  @override
  String minPlayersRequired(int min) {
    return 'At least $min players required';
  }

  @override
  String get classic => 'Classic';

  @override
  String get classicSubtitle => 'The original mode unchanged';

  @override
  String get quick => 'Quick';

  @override
  String get quickSubtitle => 'Shorter rounds for light play';

  @override
  String get teams => 'Teams';

  @override
  String get teamsSubtitle => 'Competition between two teams';

  @override
  String get family => 'Family';

  @override
  String get familySubtitle => 'Safe stories for everyone';

  @override
  String get chaos => 'Chaos';

  @override
  String get chaosSubtitle => 'Reversed rules and surprises';

  @override
  String get round => 'Round';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get revealPhase => 'Reveal Phase';

  @override
  String get cluePhase => 'Clue Phase';

  @override
  String get discussionPhase => 'Discussion Phase';

  @override
  String get votingPhase => 'Voting Phase';

  @override
  String get guessPhase => 'Guess Phase';

  @override
  String get yourRole => 'Your Role';

  @override
  String get yourTopic => 'The Story';

  @override
  String get tapToReveal => 'Tap to Reveal';

  @override
  String get hideRole => 'Hide Role';

  @override
  String get nextPlayer => 'Next Player';

  @override
  String get startRound => 'Start Round';

  @override
  String get endRound => 'End Round';

  @override
  String get vote => 'Vote';

  @override
  String get votes => 'Votes';

  @override
  String voteCount(int count) {
    return '$count votes';
  }

  @override
  String get confirmVote => 'Confirm Vote';

  @override
  String get changeVote => 'Change Vote';

  @override
  String get guess => 'Guess';

  @override
  String get guessTheTopic => 'Guess the Story';

  @override
  String get correctGuess => 'Correct!';

  @override
  String get wrongGuess => 'Wrong!';

  @override
  String get results => 'Results';

  @override
  String get winner => 'Winner';

  @override
  String get winners => 'Winners';

  @override
  String get insidersWin => 'The Insiders win!';

  @override
  String get outsiderWins => 'The Outsider wins!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get points => 'Points';

  @override
  String pointsCount(int count) {
    return '$count points';
  }

  @override
  String get totalPoints => 'Total Points';

  @override
  String get timer => 'Timer';

  @override
  String get seconds => 'seconds';

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get continue_ => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get selectCategories => 'Select Categories';

  @override
  String get categories => 'Categories';

  @override
  String get category => 'Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get setup => 'Setup';

  @override
  String get gameSetup => 'Game Setup';

  @override
  String get selectMode => 'Select Mode';

  @override
  String get selectPlayers => 'Select Players';

  @override
  String get onboardingTitle1 => 'Welcome to Outside the Story';

  @override
  String get onboardingDesc1 =>
      'A fun group game to find who doesn\'t know the topic';

  @override
  String get onboardingTitle2 => 'How to Play';

  @override
  String get onboardingDesc2 =>
      'One person doesn\'t know the story, the rest try to find them';

  @override
  String get onboardingTitle3 => 'Start Now';

  @override
  String get onboardingDesc3 => 'Gather your friends and start the fun';

  @override
  String get getStarted => 'Get Started';

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
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed';
}
