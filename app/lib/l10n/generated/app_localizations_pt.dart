// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Fora do Assunto';

  @override
  String get settings => 'Configurações';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get darkModeSubtitle =>
      'Uma experiência mais calma para sessões noturnas';

  @override
  String get haptics => 'Vibração';

  @override
  String get hapticsSubtitle => 'Feedback tátil ao revelar funções';

  @override
  String get sound => 'Som';

  @override
  String get soundSubtitle => 'Efeitos sonoros e música';

  @override
  String get reducedMotion => 'Reduzir Animações';

  @override
  String get reducedMotionSubtitle =>
      'Transições mais leves para dispositivos lentos';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Escolher idioma do app';

  @override
  String get followMe => 'Siga-me';

  @override
  String get openLinkError => 'Não foi possível abrir o link';

  @override
  String get builtBy => 'Criado por Benaboud Mohamed Islam';

  @override
  String get copyright => '© Fora do Assunto';

  @override
  String get home => 'Início';

  @override
  String get store => 'Loja';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get appTagline =>
      'Sessões mais rápidas, revelações inteligentes, com toque árabe.';

  @override
  String get startYourNight => 'Comece Sua Noite';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Última config: $mode • $playerCount jogadores';
  }

  @override
  String get startNewGame => 'Novo Jogo';

  @override
  String get quickRound => 'Rodada Rápida';

  @override
  String get manageStories => 'Gerenciar Histórias';

  @override
  String get readyModes => 'Modos Prontos para Esta Noite';

  @override
  String get viewAll => 'Ver Tudo';

  @override
  String get comingSoon => 'Em Breve';

  @override
  String get featuredCategories => 'Categorias em Destaque';

  @override
  String get packOfTheDay => 'Pack do Dia';

  @override
  String get tonightChallenge => 'Desafio de Hoje';

  @override
  String get tonightChallengeDesc =>
      'Jogue duas rodadas consecutivas sem eliminar nenhum jogador.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'História';

  @override
  String get stories => 'Histórias';

  @override
  String storyCount(int count) {
    return '$count histórias';
  }

  @override
  String get addStory => 'Adicionar História';

  @override
  String get enterStory => 'Digite a história';

  @override
  String get outsider => 'Intruso';

  @override
  String get youAreOutsider => 'Você é o Intruso';

  @override
  String get oneOfYouIsOutsider => 'Um de vocês é o Intruso';

  @override
  String get chooseOutsider => 'Escolha quem você acha que é o Intruso';

  @override
  String get outsiderIs => 'O Intruso é';

  @override
  String get outsidersAre => 'Os Intrusos são';

  @override
  String get players => 'Jogadores';

  @override
  String get player => 'Jogador';

  @override
  String playerCount(int count) {
    return '$count jogadores';
  }

  @override
  String get addPlayer => 'Adicionar Jogador';

  @override
  String get enterPlayerName => 'Digite o nome do jogador';

  @override
  String minPlayersRequired(int min) {
    return 'Mínimo de $min jogadores necessários';
  }

  @override
  String get classic => 'Clássico';

  @override
  String get classicSubtitle => 'O modo original sem alterações';

  @override
  String get quick => 'Rápido';

  @override
  String get quickSubtitle => 'Rodadas mais curtas para jogo leve';

  @override
  String get teams => 'Equipes';

  @override
  String get teamsSubtitle => 'Competição entre duas equipes';

  @override
  String get family => 'Família';

  @override
  String get familySubtitle => 'Histórias seguras para todos';

  @override
  String get chaos => 'Caos';

  @override
  String get chaosSubtitle => 'Regras invertidas e surpresas';

  @override
  String get round => 'Rodada';

  @override
  String roundNumber(int number) {
    return 'Rodada $number';
  }

  @override
  String get revealPhase => 'Fase de Revelação';

  @override
  String get cluePhase => 'Fase de Dicas';

  @override
  String get discussionPhase => 'Fase de Discussão';

  @override
  String get votingPhase => 'Fase de Votação';

  @override
  String get guessPhase => 'Fase de Adivinhação';

  @override
  String get yourRole => 'Seu Papel';

  @override
  String get yourTopic => 'A História';

  @override
  String get tapToReveal => 'Toque para Revelar';

  @override
  String get hideRole => 'Esconder Papel';

  @override
  String get nextPlayer => 'Próximo Jogador';

  @override
  String get startRound => 'Iniciar Rodada';

  @override
  String get endRound => 'Terminar Rodada';

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
  String get changeVote => 'Mudar Voto';

  @override
  String get guess => 'Adivinhar';

  @override
  String get guessTheTopic => 'Adivinhe a História';

  @override
  String get correctGuess => 'Correto!';

  @override
  String get wrongGuess => 'Errado!';

  @override
  String get results => 'Resultados';

  @override
  String get winner => 'Vencedor';

  @override
  String get winners => 'Vencedores';

  @override
  String get insidersWin => 'Os informados vencem!';

  @override
  String get outsiderWins => 'O Intruso vence!';

  @override
  String get playAgain => 'Jogar Novamente';

  @override
  String get backToHome => 'Voltar ao Início';

  @override
  String get points => 'Pontos';

  @override
  String pointsCount(int count) {
    return '$count pontos';
  }

  @override
  String get totalPoints => 'Pontos Totais';

  @override
  String get timer => 'Temporizador';

  @override
  String get seconds => 'segundos';

  @override
  String get timeUp => 'Tempo esgotado!';

  @override
  String get continue_ => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get skip => 'Pular';

  @override
  String get done => 'Pronto';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Adicionar';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Próximo';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get selectCategories => 'Selecionar Categorias';

  @override
  String get categories => 'Categorias';

  @override
  String get category => 'Categoria';

  @override
  String get allCategories => 'Todas as Categorias';

  @override
  String get setup => 'Configuração';

  @override
  String get gameSetup => 'Configurar Jogo';

  @override
  String get selectMode => 'Selecionar Modo';

  @override
  String get selectPlayers => 'Selecionar Jogadores';

  @override
  String get onboardingTitle1 => 'Bem-vindo ao Fora do Assunto';

  @override
  String get onboardingDesc1 =>
      'Um jogo de grupo divertido para encontrar quem não conhece o tema';

  @override
  String get onboardingTitle2 => 'Como Jogar';

  @override
  String get onboardingDesc2 =>
      'Uma pessoa não conhece a história, o resto tenta encontrá-la';

  @override
  String get onboardingTitle3 => 'Comece Agora';

  @override
  String get onboardingDesc3 => 'Reúna seus amigos e comece a diversão';

  @override
  String get getStarted => 'Começar';

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
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get languageChanged => 'Idioma alterado';
}
