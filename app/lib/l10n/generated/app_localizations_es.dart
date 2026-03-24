// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fuera del Tema';

  @override
  String get settings => 'Configuración';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeSubtitle =>
      'Una experiencia más tranquila para sesiones nocturnas';

  @override
  String get haptics => 'Vibración';

  @override
  String get hapticsSubtitle => 'Respuesta táctil al revelar roles';

  @override
  String get sound => 'Sonido';

  @override
  String get soundSubtitle => 'Efectos de sonido y música';

  @override
  String get reducedMotion => 'Reducir Animaciones';

  @override
  String get reducedMotionSubtitle =>
      'Transiciones más ligeras para dispositivos lentos';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Elige el idioma de la app';

  @override
  String get followMe => 'Sígueme';

  @override
  String get openLinkError => 'No se pudo abrir el enlace';

  @override
  String get builtBy => 'Creado por Benaboud Mohamed Islam';

  @override
  String get copyright => '© Fuera del Tema';

  @override
  String get home => 'Inicio';

  @override
  String get store => 'Tienda';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get appTagline =>
      'Sesiones más rápidas, revelaciones inteligentes, con toque árabe.';

  @override
  String get startYourNight => 'Comienza Tu Noche';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Último ajuste: $mode • $playerCount jugadores';
  }

  @override
  String get startNewGame => 'Nuevo Juego';

  @override
  String get quickRound => 'Ronda Rápida';

  @override
  String get manageStories => 'Gestionar Historias';

  @override
  String get readyModes => 'Modos Listos para Esta Noche';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get featuredCategories => 'Categorías Destacadas';

  @override
  String get packOfTheDay => 'Pack del Día';

  @override
  String get tonightChallenge => 'Desafío de Esta Noche';

  @override
  String get tonightChallengeDesc =>
      'Juega dos rondas consecutivas sin eliminar a ningún jugador.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'Historia';

  @override
  String get stories => 'Historias';

  @override
  String storyCount(int count) {
    return '$count historias';
  }

  @override
  String get addStory => 'Añadir Historia';

  @override
  String get enterStory => 'Introduce la historia';

  @override
  String get outsider => 'Intruso';

  @override
  String get youAreOutsider => 'Eres el Intruso';

  @override
  String get oneOfYouIsOutsider => 'Uno de ustedes es el Intruso';

  @override
  String get chooseOutsider => 'Elige quién crees que es el Intruso';

  @override
  String get outsiderIs => 'El Intruso es';

  @override
  String get outsidersAre => 'Los Intrusos son';

  @override
  String get players => 'Jugadores';

  @override
  String get player => 'Jugador';

  @override
  String playerCount(int count) {
    return '$count jugadores';
  }

  @override
  String get addPlayer => 'Añadir Jugador';

  @override
  String get enterPlayerName => 'Introduce nombre del jugador';

  @override
  String minPlayersRequired(int min) {
    return 'Se requieren al menos $min jugadores';
  }

  @override
  String get classic => 'Clásico';

  @override
  String get classicSubtitle => 'El modo original sin cambios';

  @override
  String get quick => 'Rápido';

  @override
  String get quickSubtitle => 'Rondas más cortas para juego ligero';

  @override
  String get teams => 'Equipos';

  @override
  String get teamsSubtitle => 'Competencia entre dos equipos';

  @override
  String get family => 'Familiar';

  @override
  String get familySubtitle => 'Historias seguras para todos';

  @override
  String get chaos => 'Caos';

  @override
  String get chaosSubtitle => 'Reglas invertidas y sorpresas';

  @override
  String get round => 'Ronda';

  @override
  String roundNumber(int number) {
    return 'Ronda $number';
  }

  @override
  String get revealPhase => 'Fase de Revelación';

  @override
  String get cluePhase => 'Fase de Pistas';

  @override
  String get discussionPhase => 'Fase de Discusión';

  @override
  String get votingPhase => 'Fase de Votación';

  @override
  String get guessPhase => 'Fase de Adivinanza';

  @override
  String get yourRole => 'Tu Rol';

  @override
  String get yourTopic => 'La Historia';

  @override
  String get tapToReveal => 'Toca para Revelar';

  @override
  String get hideRole => 'Ocultar Rol';

  @override
  String get nextPlayer => 'Siguiente Jugador';

  @override
  String get startRound => 'Iniciar Ronda';

  @override
  String get endRound => 'Terminar Ronda';

  @override
  String get vote => 'Votar';

  @override
  String get votes => 'Votos';

  @override
  String voteCount(int count) {
    return '$count votos';
  }

  @override
  String get confirmVote => 'Confirmar Voto';

  @override
  String get changeVote => 'Cambiar Voto';

  @override
  String get guess => 'Adivinar';

  @override
  String get guessTheTopic => 'Adivina la Historia';

  @override
  String get correctGuess => '¡Correcto!';

  @override
  String get wrongGuess => '¡Incorrecto!';

  @override
  String get results => 'Resultados';

  @override
  String get winner => 'Ganador';

  @override
  String get winners => 'Ganadores';

  @override
  String get insidersWin => '¡Los informados ganan!';

  @override
  String get outsiderWins => '¡El Intruso gana!';

  @override
  String get playAgain => 'Jugar de Nuevo';

  @override
  String get backToHome => 'Volver al Inicio';

  @override
  String get points => 'Puntos';

  @override
  String pointsCount(int count) {
    return '$count puntos';
  }

  @override
  String get totalPoints => 'Puntos Totales';

  @override
  String get timer => 'Temporizador';

  @override
  String get seconds => 'segundos';

  @override
  String get timeUp => '¡Tiempo!';

  @override
  String get continue_ => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get skip => 'Saltar';

  @override
  String get done => 'Hecho';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Añadir';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get selectCategories => 'Seleccionar Categorías';

  @override
  String get categories => 'Categorías';

  @override
  String get category => 'Categoría';

  @override
  String get allCategories => 'Todas las Categorías';

  @override
  String get setup => 'Configuración';

  @override
  String get gameSetup => 'Configurar Juego';

  @override
  String get selectMode => 'Seleccionar Modo';

  @override
  String get selectPlayers => 'Seleccionar Jugadores';

  @override
  String get onboardingTitle1 => 'Bienvenido a Fuera del Tema';

  @override
  String get onboardingDesc1 =>
      'Un divertido juego grupal para encontrar quién no conoce el tema';

  @override
  String get onboardingTitle2 => 'Cómo Jugar';

  @override
  String get onboardingDesc2 =>
      'Una persona no conoce la historia, el resto intenta encontrarla';

  @override
  String get onboardingTitle3 => 'Empieza Ahora';

  @override
  String get onboardingDesc3 => 'Reúne a tus amigos y comienza la diversión';

  @override
  String get getStarted => 'Empezar';

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
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get languageChanged => 'Idioma cambiado';
}
