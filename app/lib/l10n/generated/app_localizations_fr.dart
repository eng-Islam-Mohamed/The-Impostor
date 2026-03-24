// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hors Sujet';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get darkModeSubtitle =>
      'Une expérience plus calme pour les sessions nocturnes';

  @override
  String get haptics => 'Vibrations';

  @override
  String get hapticsSubtitle =>
      'Retour tactile lors de la révélation des rôles';

  @override
  String get sound => 'Son';

  @override
  String get soundSubtitle => 'Effets sonores et musique';

  @override
  String get reducedMotion => 'Réduire les Animations';

  @override
  String get reducedMotionSubtitle =>
      'Transitions plus légères pour les appareils lents';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Choisir la langue de l\'application';

  @override
  String get followMe => 'Suivez-moi';

  @override
  String get openLinkError => 'Impossible d\'ouvrir le lien';

  @override
  String get builtBy => 'Créé par Benaboud Mohamed Islam';

  @override
  String get copyright => '© Hors Sujet';

  @override
  String get home => 'Accueil';

  @override
  String get store => 'Boutique';

  @override
  String get statistics => 'Statistiques';

  @override
  String get appTagline =>
      'Sessions plus rapides, révélations intelligentes, avec une touche arabe.';

  @override
  String get startYourNight => 'Commencez Votre Soirée';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Dernier réglage : $mode • $playerCount joueurs';
  }

  @override
  String get startNewGame => 'Nouvelle Partie';

  @override
  String get quickRound => 'Partie Rapide';

  @override
  String get manageStories => 'Gérer les Histoires';

  @override
  String get readyModes => 'Modes Prêts pour Ce Soir';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get featuredCategories => 'Catégories en Vedette';

  @override
  String get packOfTheDay => 'Pack du Jour';

  @override
  String get tonightChallenge => 'Défi de Ce Soir';

  @override
  String get tonightChallengeDesc =>
      'Jouez deux manches consécutives sans éliminer de joueur.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'Histoire';

  @override
  String get stories => 'Histoires';

  @override
  String storyCount(int count) {
    return '$count histoires';
  }

  @override
  String get addStory => 'Ajouter une Histoire';

  @override
  String get enterStory => 'Entrez l\'histoire';

  @override
  String get outsider => 'Intrus';

  @override
  String get youAreOutsider => 'Vous êtes l\'Intrus';

  @override
  String get oneOfYouIsOutsider => 'L\'un de vous est l\'Intrus';

  @override
  String get chooseOutsider => 'Choisissez qui vous pensez être l\'Intrus';

  @override
  String get outsiderIs => 'L\'Intrus est';

  @override
  String get outsidersAre => 'Les Intrus sont';

  @override
  String get players => 'Joueurs';

  @override
  String get player => 'Joueur';

  @override
  String playerCount(int count) {
    return '$count joueurs';
  }

  @override
  String get addPlayer => 'Ajouter un Joueur';

  @override
  String get enterPlayerName => 'Entrez le nom du joueur';

  @override
  String minPlayersRequired(int min) {
    return 'Au moins $min joueurs requis';
  }

  @override
  String get classic => 'Classique';

  @override
  String get classicSubtitle => 'Le mode original inchangé';

  @override
  String get quick => 'Rapide';

  @override
  String get quickSubtitle => 'Manches plus courtes pour un jeu léger';

  @override
  String get teams => 'Équipes';

  @override
  String get teamsSubtitle => 'Compétition entre deux équipes';

  @override
  String get family => 'Famille';

  @override
  String get familySubtitle => 'Histoires sûres pour tous';

  @override
  String get chaos => 'Chaos';

  @override
  String get chaosSubtitle => 'Règles inversées et surprises';

  @override
  String get round => 'Manche';

  @override
  String roundNumber(int number) {
    return 'Manche $number';
  }

  @override
  String get revealPhase => 'Phase de Révélation';

  @override
  String get cluePhase => 'Phase d\'Indices';

  @override
  String get discussionPhase => 'Phase de Discussion';

  @override
  String get votingPhase => 'Phase de Vote';

  @override
  String get guessPhase => 'Phase de Devinette';

  @override
  String get yourRole => 'Votre Rôle';

  @override
  String get yourTopic => 'L\'Histoire';

  @override
  String get tapToReveal => 'Appuyez pour Révéler';

  @override
  String get hideRole => 'Cacher le Rôle';

  @override
  String get nextPlayer => 'Joueur Suivant';

  @override
  String get startRound => 'Commencer la Manche';

  @override
  String get endRound => 'Terminer la Manche';

  @override
  String get vote => 'Voter';

  @override
  String get votes => 'Votes';

  @override
  String voteCount(int count) {
    return '$count votes';
  }

  @override
  String get confirmVote => 'Confirmer le Vote';

  @override
  String get changeVote => 'Changer de Vote';

  @override
  String get guess => 'Deviner';

  @override
  String get guessTheTopic => 'Devinez l\'Histoire';

  @override
  String get correctGuess => 'Correct !';

  @override
  String get wrongGuess => 'Faux !';

  @override
  String get results => 'Résultats';

  @override
  String get winner => 'Gagnant';

  @override
  String get winners => 'Gagnants';

  @override
  String get insidersWin => 'Les initiés gagnent !';

  @override
  String get outsiderWins => 'L\'Intrus gagne !';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get backToHome => 'Retour à l\'Accueil';

  @override
  String get points => 'Points';

  @override
  String pointsCount(int count) {
    return '$count points';
  }

  @override
  String get totalPoints => 'Points Totaux';

  @override
  String get timer => 'Minuteur';

  @override
  String get seconds => 'secondes';

  @override
  String get timeUp => 'Temps écoulé !';

  @override
  String get continue_ => 'Continuer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get skip => 'Passer';

  @override
  String get done => 'Terminé';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get selectCategories => 'Sélectionner les Catégories';

  @override
  String get categories => 'Catégories';

  @override
  String get category => 'Catégorie';

  @override
  String get allCategories => 'Toutes les Catégories';

  @override
  String get setup => 'Configuration';

  @override
  String get gameSetup => 'Configuration du Jeu';

  @override
  String get selectMode => 'Sélectionner le Mode';

  @override
  String get selectPlayers => 'Sélectionner les Joueurs';

  @override
  String get onboardingTitle1 => 'Bienvenue dans Hors Sujet';

  @override
  String get onboardingDesc1 =>
      'Un jeu de groupe amusant pour trouver qui ne connaît pas le sujet';

  @override
  String get onboardingTitle2 => 'Comment Jouer';

  @override
  String get onboardingDesc2 =>
      'Une personne ne connaît pas l\'histoire, les autres essaient de la trouver';

  @override
  String get onboardingTitle3 => 'Commencez Maintenant';

  @override
  String get onboardingDesc3 => 'Rassemblez vos amis et commencez le plaisir';

  @override
  String get getStarted => 'Commencer';

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
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get languageChanged => 'Langue changée';
}
