import 'dart:math';

import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/data/local/local_game_session_store.dart';
import 'package:bara_alsalfa/data/local/seed_data.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/category_pack.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/persisted_game_session.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/round_phase.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:bara_alsalfa/domain/services/game_engine.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/groups/application/saved_groups_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

int maxOutsidersForPlayerCount(int count) {
  if (count <= 4) {
    return 1;
  }
  if (count <= 7) {
    return 2;
  }
  return 3;
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
  const legacyNames = {
    'سالم',
    'نورة',
    'خالد',
    'سارة',
    'فيصل',
    'ريم',
    'فهد',
    'مها',
    'طارق',
    'عبير',
    'ماجد',
    'ليلى',
    'Salem',
    'Noura',
    'Khaled',
    'Sara',
    'Faisal',
    'Reem',
    'Fahad',
    'Maha',
    'Tariq',
    'Abeer',
    'Majid',
    'Layla',
  };
  if (legacyNames.contains(trimmed)) return true;
  for (final locale in SupportedLocale.values) {
    for (var index = 1; index <= 32; index++) {
      if (trimmed == defaultPlayerName(index, locale)) return true;
    }
  }
  return false;
}

List<PlayerProfile> buildStarterPlayers({
  SupportedLocale locale = SupportedLocale.arabic,
}) {
  return [
    PlayerProfile(
      id: 'p1',
      name: defaultPlayerName(1, locale),
      avatarIndex: 0,
      score: 0,
    ),
    PlayerProfile(
      id: 'p2',
      name: defaultPlayerName(2, locale),
      avatarIndex: 1,
      score: 0,
    ),
    PlayerProfile(
      id: 'p3',
      name: defaultPlayerName(3, locale),
      avatarIndex: 2,
      score: 0,
    ),
    PlayerProfile(
      id: 'p4',
      name: defaultPlayerName(4, locale),
      avatarIndex: 3,
      score: 0,
    ),
    PlayerProfile(
      id: 'p5',
      name: defaultPlayerName(5, locale),
      avatarIndex: 4,
      score: 0,
    ),
  ];
}

@immutable
class PowerCardDefinition {
  const PowerCardDefinition({
    required this.id,
    required this.label,
    required this.description,
    this.isAppliedByRules = true,
  });

  final String id;
  final String label;
  final String description;
  final bool isAppliedByRules;
}

class PowerCardCatalog {
  static const doubleVote = 'double_vote';
  static const jackpot = 'jackpot';
  static const tacticalDrain = 'tactical_drain';
  static const karmaBackfire = 'karma_backfire';
  static const tacticalAlliance = 'tactical_alliance';
  static const highStakes = 'high_stakes';
  static const diplomaticImmunity = 'diplomatic_immunity';
  static const robinHood = 'robin_hood';
  static const outsiderSecondChance = 'outsider_second_chance';
  static const outsiderChoicesFocus = 'outsider_choices_focus';
  static const outsiderFourChoice = 'outsider_four_choice';
  static const outsiderUnlimitedTime = 'outsider_unlimited_time';
  static const outsiderHighRisk = 'outsider_high_risk';
  static const outsiderChaosWall = 'outsider_chaos_wall';
  static const outsiderPanicTimer = 'outsider_panic_timer';
  static const outsiderPointWager = 'outsider_point_wager';

  static const innocentCardIds = <String>[
    doubleVote,
    jackpot,
    tacticalDrain,
    karmaBackfire,
    tacticalAlliance,
    highStakes,
    diplomaticImmunity,
    robinHood,
  ];

  static const outsiderCardIds = <String>[
    outsiderSecondChance,
    outsiderChoicesFocus,
    outsiderFourChoice,
    outsiderUnlimitedTime,
    outsiderHighRisk,
    outsiderChaosWall,
    outsiderPanicTimer,
    outsiderPointWager,
  ];

  static const all = <PowerCardDefinition>[
    PowerCardDefinition(
      id: doubleVote,
      label: 'صوتك يحسب بصوتين',
      description: 'تطبق في النقاط: التصويت الصحيح +2، والتصويت الخاطئ -2.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: jackpot,
      label: 'الجاكبوت (Jackpot)',
      description:
          'تعمل فقط إذا كانت كل اختياراتك صحيحة؛ عندها تحصل على مجموع الأرصدة الإيجابية لجميع اللاعبين.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: tacticalDrain,
      label: 'السطو التكتيكي (مجازفة السطو)',
      description:
          'تعمل فقط إذا كانت كل اختياراتك صحيحة؛ عندها تسحب رصيد اللاعب المستهدف كاملاً وتصفر رصيده.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: karmaBackfire,
      label: 'الارتداد العكسي',
      description:
          'إذا اتهمك زملاؤك وأنت بريء، يخصم نقطة من كل من صوّت عليك وتنتقل إليك!',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: tacticalAlliance,
      label: 'التحالف التكتيكي',
      description:
          'كل اختيار صحيح ومتطابق بينك وبين حليفك يصبح بقيمة +3 لكل واحد منكما.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: highStakes,
      label: 'الرهان العالي',
      description:
          'كل اختيار صحيح يمنح +4، وكل اختيار خاطئ يخصم -4، سواء كان هناك واحد أو ثلاثة من برا السالفة.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: diplomaticImmunity,
      label: 'الحصانة الدبلوماسية',
      description:
          'كل اختيار صحيح يمنحك نقطته، بينما تتحول كل عقوبة اختيار خاطئ إلى 0.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: robinHood,
      label: 'روبن هود',
      description:
          'إذا كانت كل اختياراتك صحيحة، تسحب نقطتين من متصدر الترتيب وتضيفهما لرصيدك.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: outsiderSecondChance,
      label: 'الفرصة المزدوجة (لبرا السالفة)',
      description:
          'تمنحك محاولتين لتخمين السالفة في التحدي الأخير بدلاً من محاولة واحدة!',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: outsiderChoicesFocus,
      label: 'حصر السبعة خيارات (لبرا السالفة)',
      description:
          'تختصر قائمة التخمين الخاصة بصاحب المهارة وحده إلى 7 خيارات، دون التأثير على بقية برا السالفة.',
      isAppliedByRules: true,
    ),
    PowerCardDefinition(
      id: outsiderFourChoice,
      label: 'زر الإنقاذ (لبرا السالفة)',
      description:
          'يمكنك تفعيل الزر مرة واحدة لتحويل جدار التخمين إلى 4 خيارات فقط، والسالفة الصحيحة مضمونة بينها.',
    ),
    PowerCardDefinition(
      id: outsiderUnlimitedTime,
      label: 'تجميد الوقت (لبرا السالفة)',
      description: 'لا يوجد عداد زمني أثناء تخمين السالفة.',
    ),
    PowerCardDefinition(
      id: outsiderHighRisk,
      label: 'كل شيء أو لا شيء (لبرا السالفة)',
      description: 'التخمين الصحيح يمنح +4 والخاطئ أو انتهاء الوقت يخصم -4.',
    ),
    PowerCardDefinition(
      id: outsiderChaosWall,
      label: 'جدار الفوضى (لبرا السالفة)',
      description:
          'عدد الخيارات عشوائي من خيار واحد حتى كل سوالف الفئة الحالية، مع ضمان وجود السالفة الصحيحة.',
    ),
    PowerCardDefinition(
      id: outsiderPanicTimer,
      label: 'عشر ثوانٍ (لبرا السالفة)',
      description: 'لديك 10 ثوانٍ فقط لاختيار السالفة.',
    ),
    PowerCardDefinition(
      id: outsiderPointWager,
      label: 'رهان الرصيد (لبرا السالفة)',
      description:
          'اختر لاعباً ثم خمن من كل سوالف الفئة. الصحيح يكسبك نصف رصيده ويخصمه منه، والخاطئ يخسرك الرهان ويمنحه +2.',
    ),
  ];

  static const defaultEnabledIds = <String>{
    doubleVote,
    jackpot,
    tacticalDrain,
    karmaBackfire,
    tacticalAlliance,
    highStakes,
    diplomaticImmunity,
    robinHood,
    outsiderSecondChance,
    outsiderChoicesFocus,
    outsiderFourChoice,
    outsiderUnlimitedTime,
    outsiderHighRisk,
    outsiderChaosWall,
    outsiderPanicTimer,
    outsiderPointWager,
  };

  static PowerCardDefinition byId(String payload) {
    final baseId = parseCardId(payload);
    return all.firstWhere((card) => card.id == baseId, orElse: () => all.first);
  }

  static String parseCardId(String payload) {
    if (payload.contains(':')) {
      return payload.split(':').first;
    }
    return payload;
  }

  static String? parseTargetId(String payload) {
    if (payload.contains(':')) {
      final parts = payload.split(':');
      return parts.length > 1 ? parts[1] : null;
    }
    return null;
  }
}

@immutable
class GameSessionState {
  const GameSessionState({
    required this.players,
    required this.selectedMode,
    required this.selectedPackId,
    required this.discussionSeconds,
    required this.scoringEnabled,
    required this.powerCardsEnabled,
    required this.activePowerCardIds,
    required this.outsidersKnowEachOther,
    required this.sequentialEliminationEnabled,
    required this.outsiderCount,
    required this.roundNumber,
    required this.hasSavedSession,
    required this.phase,
    required this.assignments,
    required this.revealIndex,
    required this.clueIndex,
    required this.clueLap,
    required this.outsiderGuessIndex,
    required this.outsiderGuessAttempts,
    required this.votes,
    required this.powerCards,
    required this.currentTopic,
    required this.outsiderIds,
    required this.outcome,
    required this.eliminatedPlayerIds,
    required this.eliminationRound,
    required this.activatedOutsiderSkillIds,
    required this.outsiderWagerTargetIds,
    this.powerDensity = PowerDensity.balanced,
  });

  factory GameSessionState.initial({
    List<PlayerProfile>? players,
    bool hasSavedSession = false,
  }) {
    return GameSessionState(
      players: players ?? buildStarterPlayers(),
      selectedMode: GameMode.classic,
      selectedPackId: seededCategoryPacks.first.id,
      discussionSeconds: GameMode.classic.defaultDiscussionSeconds,
      scoringEnabled: true,
      powerCardsEnabled: true,
      activePowerCardIds: PowerCardCatalog.defaultEnabledIds,
      outsidersKnowEachOther: false,
      sequentialEliminationEnabled: false,
      outsiderCount: 1,
      roundNumber: 1,
      hasSavedSession: hasSavedSession,
      phase: RoundPhase.reveal,
      assignments: const [],
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
      votes: const <String, List<String>>{},
      powerCards: const <String, String>{},
      currentTopic: null,
      outsiderIds: const [],
      outcome: null,
      eliminatedPlayerIds: const [],
      eliminationRound: 1,
      activatedOutsiderSkillIds: const {},
      outsiderWagerTargetIds: const {},
      powerDensity: PowerDensity.balanced,
    );
  }

  factory GameSessionState.fromPersisted(PersistedGameSession session) {
    return GameSessionState(
      players: session.players,
      selectedMode: session.selectedMode,
      selectedPackId: session.selectedPackId,
      discussionSeconds: session.discussionSeconds,
      scoringEnabled: session.scoringEnabled,
      powerCardsEnabled: session.powerCardsEnabled,
      activePowerCardIds: session.activePowerCardIds,
      outsidersKnowEachOther: session.outsidersKnowEachOther,
      sequentialEliminationEnabled: session.sequentialEliminationEnabled,
      outsiderCount: session.outsiderCount,
      roundNumber: session.roundNumber,
      hasSavedSession: true,
      phase: RoundPhase.reveal,
      assignments: const [],
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
      votes: const <String, List<String>>{},
      powerCards: const <String, String>{},
      currentTopic: null,
      outsiderIds: const [],
      outcome: null,
      eliminatedPlayerIds: const [],
      eliminationRound: 1,
      activatedOutsiderSkillIds: const {},
      outsiderWagerTargetIds: const {},
      powerDensity: session.powerDensity,
    );
  }

  final List<PlayerProfile> players;
  final GameMode selectedMode;
  final String selectedPackId;
  final int discussionSeconds;
  final bool scoringEnabled;
  final bool powerCardsEnabled;
  final Set<String> activePowerCardIds;
  final bool outsidersKnowEachOther;
  final bool sequentialEliminationEnabled;
  final int outsiderCount;
  final int roundNumber;
  final bool hasSavedSession;
  final RoundPhase phase;
  final List<SecretAssignment> assignments;
  final int revealIndex;
  final int clueIndex;
  final int clueLap;
  final int outsiderGuessIndex;
  final int outsiderGuessAttempts;
  final Map<String, List<String>> votes;
  final Map<String, String> powerCards;
  final String? currentTopic;
  final List<String> outsiderIds;
  final RoundOutcome? outcome;
  final List<String> eliminatedPlayerIds;
  final int eliminationRound;
  final Set<String> activatedOutsiderSkillIds;
  final Map<String, String> outsiderWagerTargetIds;
  final PowerDensity powerDensity;

  bool get hasActiveRound => currentTopic != null && outsiderIds.isNotEmpty;

  bool get usesSequentialElimination => sequentialEliminationEnabled;

  int get votesPerPlayer => usesSequentialElimination ? 1 : outsiderCount;

  List<PlayerProfile> get activePlayers {
    final eliminated = eliminatedPlayerIds.toSet();
    return players
        .where((player) => !eliminated.contains(player.id))
        .toList(growable: false);
  }

  SecretAssignment? get currentRevealAssignment {
    if (revealIndex >= assignments.length) {
      return null;
    }
    return assignments[revealIndex];
  }

  PlayerProfile? get currentCluePlayer {
    if (clueIndex >= activePlayers.length) {
      return null;
    }
    return activePlayers[clueIndex];
  }

  PlayerProfile? get currentVoter {
    for (final player in activePlayers) {
      if (!votes.containsKey(player.id)) {
        return player;
      }
    }
    return null;
  }

  PlayerProfile? get currentOutsiderGuesser {
    final guessQueue = outcome?.outsiderIds ?? outsiderIds;
    if (outsiderGuessIndex >= guessQueue.length) {
      return null;
    }
    return players.firstWhereOrNull(
      (player) => player.id == guessQueue[outsiderGuessIndex],
    );
  }

  String? get currentOutsiderCardId {
    final outsider = currentOutsiderGuesser;
    if (outsider == null) return null;
    final payload = powerCards[outsider.id];
    return payload == null ? null : PowerCardCatalog.parseCardId(payload);
  }

  bool get currentOutsiderNeedsWagerTarget {
    final outsider = currentOutsiderGuesser;
    return outsider != null &&
        currentOutsiderCardId == PowerCardCatalog.outsiderPointWager &&
        !outsiderWagerTargetIds.containsKey(outsider.id);
  }

  List<PlayerProfile> get outsiderPlayers {
    final outsiderSet = outsiderIds.toSet();
    return players
        .where((player) => outsiderSet.contains(player.id))
        .toList(growable: false);
  }

  GameSessionState copyWith({
    List<PlayerProfile>? players,
    GameMode? selectedMode,
    String? selectedPackId,
    int? discussionSeconds,
    bool? scoringEnabled,
    bool? powerCardsEnabled,
    Set<String>? activePowerCardIds,
    bool? outsidersKnowEachOther,
    bool? sequentialEliminationEnabled,
    int? outsiderCount,
    int? roundNumber,
    bool? hasSavedSession,
    RoundPhase? phase,
    List<SecretAssignment>? assignments,
    int? revealIndex,
    int? clueIndex,
    int? clueLap,
    int? outsiderGuessIndex,
    int? outsiderGuessAttempts,
    Map<String, List<String>>? votes,
    Map<String, String>? powerCards,
    Object? currentTopic = _sentinel,
    List<String>? outsiderIds,
    Object? outcome = _sentinel,
    List<String>? eliminatedPlayerIds,
    int? eliminationRound,
    Set<String>? activatedOutsiderSkillIds,
    Map<String, String>? outsiderWagerTargetIds,
    PowerDensity? powerDensity,
  }) {
    return GameSessionState(
      players: players ?? this.players,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedPackId: selectedPackId ?? this.selectedPackId,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      scoringEnabled: scoringEnabled ?? this.scoringEnabled,
      powerCardsEnabled: powerCardsEnabled ?? this.powerCardsEnabled,
      activePowerCardIds: activePowerCardIds ?? this.activePowerCardIds,
      outsidersKnowEachOther:
          outsidersKnowEachOther ?? this.outsidersKnowEachOther,
      sequentialEliminationEnabled:
          sequentialEliminationEnabled ?? this.sequentialEliminationEnabled,
      outsiderCount: outsiderCount ?? this.outsiderCount,
      roundNumber: roundNumber ?? this.roundNumber,
      hasSavedSession: hasSavedSession ?? this.hasSavedSession,
      phase: phase ?? this.phase,
      assignments: assignments ?? this.assignments,
      revealIndex: revealIndex ?? this.revealIndex,
      clueIndex: clueIndex ?? this.clueIndex,
      clueLap: clueLap ?? this.clueLap,
      outsiderGuessIndex: outsiderGuessIndex ?? this.outsiderGuessIndex,
      outsiderGuessAttempts:
          outsiderGuessAttempts ?? this.outsiderGuessAttempts,
      votes: votes ?? this.votes,
      powerCards: powerCards ?? this.powerCards,
      currentTopic: identical(currentTopic, _sentinel)
          ? this.currentTopic
          : currentTopic as String?,
      outsiderIds: outsiderIds ?? this.outsiderIds,
      outcome: identical(outcome, _sentinel)
          ? this.outcome
          : outcome as RoundOutcome?,
      eliminatedPlayerIds: eliminatedPlayerIds ?? this.eliminatedPlayerIds,
      eliminationRound: eliminationRound ?? this.eliminationRound,
      activatedOutsiderSkillIds:
          activatedOutsiderSkillIds ?? this.activatedOutsiderSkillIds,
      outsiderWagerTargetIds:
          outsiderWagerTargetIds ?? this.outsiderWagerTargetIds,
      powerDensity: powerDensity ?? this.powerDensity,
    );
  }
}

const _sentinel = Object();

class GameSessionController extends Notifier<GameSessionState> {
  late final GameEngine _engine;
  Future<void> _writeQueue = Future<void>.value();

  GameSessionStore get _sessionStore => ref.read(gameSessionStoreProvider);

  @override
  GameSessionState build() {
    _engine = GameEngine(random: Random());
    ref.listen(appSettingsProvider, (previous, next) {
      if (previous?.locale == next.locale) {
        return;
      }
      _refreshDefaultPlayerNames(next.locale);
    });
    final locale = ref.read(appSettingsProvider).locale;
    final savedSession = ref.read(initialGameSessionProvider);
    if (savedSession != null && savedSession.players.length >= 3) {
      final availablePacks = ref.read(categoryLibraryProvider);
      final selectedPackId =
          availablePacks.any((pack) => pack.id == savedSession.selectedPackId)
          ? savedSession.selectedPackId
          : availablePacks.first.id;
      final maxOutsiders = maxOutsidersForPlayerCount(
        savedSession.players.length,
      );
      return GameSessionState.fromPersisted(savedSession).copyWith(
        players: _localizedDefaultPlayers(savedSession.players, locale),
        selectedPackId: selectedPackId,
        outsiderCount: savedSession.outsiderCount.clamp(1, maxOutsiders),
        roundNumber: savedSession.roundNumber < 1
            ? 1
            : savedSession.roundNumber,
      );
    }
    return GameSessionState.initial(
      players: buildStarterPlayers(locale: locale),
    );
  }

  void selectMode(GameMode mode) {
    state = state.copyWith(
      selectedMode: mode,
      discussionSeconds: mode.defaultDiscussionSeconds,
    );
    _clampOutsiderCount();
    _persist();
  }

  void setDiscussionSeconds(int seconds) {
    state = state.copyWith(discussionSeconds: seconds);
    _persist();
  }

  void toggleScoring(bool enabled) {
    state = state.copyWith(scoringEnabled: enabled);
    _persist();
  }

  void togglePowerCards(bool enabled) {
    state = state.copyWith(powerCardsEnabled: enabled);
    _persist();
  }

  void setPowerDensity(PowerDensity density) {
    state = state.copyWith(powerDensity: density);
    _persist();
  }

  void togglePowerCardType(String cardId, bool enabled) {
    final nextIds = {...state.activePowerCardIds};
    if (enabled) {
      nextIds.add(cardId);
    } else {
      nextIds.remove(cardId);
    }
    state = state.copyWith(activePowerCardIds: nextIds);
    _persist();
  }

  void toggleOutsidersKnowEachOther(bool enabled) {
    state = state.copyWith(outsidersKnowEachOther: enabled);
    _persist();
  }

  void toggleSequentialElimination(bool enabled) {
    state = state.copyWith(sequentialEliminationEnabled: enabled);
    _persist();
  }

  void setOutsiderCount(int count) {
    state = state.copyWith(
      outsiderCount: count.clamp(
        1,
        maxOutsidersForPlayerCount(state.players.length),
      ),
    );
    _persist();
  }

  void updatePlayerName(String playerId, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(
      players: [
        for (final player in state.players)
          if (player.id == playerId) player.copyWith(name: trimmed) else player,
      ],
    );
    _persist();
  }

  void addPlayer() {
    if (state.players.length >= 12) {
      return;
    }

    final locale = ref.read(appSettingsProvider).locale;
    final nextIndex = state.players.length + 1;
    final newPlayer = PlayerProfile(
      id: 'p$nextIndex',
      name: defaultPlayerName(nextIndex, locale),
      avatarIndex: nextIndex % 8,
      score: 0,
    );

    state = state.copyWith(players: [...state.players, newPlayer]);
    _clampOutsiderCount();
    _persist();
  }

  void removePlayer(String playerId) {
    if (state.players.length <= 3) {
      return;
    }

    state = state.copyWith(
      players: state.players.where((p) => p.id != playerId).toList(),
    );
    _clampOutsiderCount();
    _persist();
  }

  void cycleAvatar(String playerId) {
    state = state.copyWith(
      players: [
        for (final player in state.players)
          if (player.id == playerId)
            player.copyWith(avatarIndex: (player.avatarIndex + 1) % 8)
          else
            player,
      ],
    );
    _persist();
  }

  void shufflePlayers() {
    final shuffled = [...state.players]..shuffle();
    state = state.copyWith(players: shuffled);
    _persist();
  }

  void selectPack(String packId) {
    state = state.copyWith(selectedPackId: packId);
    _persist();
  }

  void setTacticalAlly(String voterId, String allyId) {
    final currentCard = state.powerCards[voterId];
    if (currentCard != null &&
        currentCard.startsWith(PowerCardCatalog.tacticalAlliance)) {
      final nextCards = Map<String, String>.from(state.powerCards)
        ..[voterId] = '${PowerCardCatalog.tacticalAlliance}:$allyId';
      state = state.copyWith(powerCards: nextCards);
      _persist();
    }
  }

  Future<void> startRound() async {
    final pack = ref
        .read(categoryLibraryProvider.notifier)
        .getPackById(state.selectedPackId);
    await _ensurePackTranslations(pack);
    final seed = _engine.createRound(
      players: state.players,
      pack: pack,
      outsiderCount: state.outsiderCount,
    );

    final assignedPowers = _buildAssignedPowerCards(
      outsiderIds: seed.outsiderIds.toSet(),
    );

    state = state.copyWith(
      assignments: seed.assignments,
      currentTopic: seed.topic,
      outsiderIds: seed.outsiderIds,
      votes: const <String, List<String>>{},
      powerCards: assignedPowers,
      phase: RoundPhase.reveal,
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
      outcome: null,
      eliminatedPlayerIds: const [],
      eliminationRound: 1,
      activatedOutsiderSkillIds: const {},
      outsiderWagerTargetIds: const {},
    );
    _persist();
  }

  void advanceReveal() {
    final nextIndex = state.revealIndex + 1;
    state = state.copyWith(revealIndex: nextIndex);
    if (nextIndex >= state.assignments.length) {
      state = state.copyWith(phase: RoundPhase.clueTurns);
    }
    _persist();
  }

  void advanceClueTurn() {
    final activeCount = state.activePlayers.length;
    if (activeCount == 0) return;
    final nextIndex = (state.clueIndex + 1) % activeCount;
    final nextLap = nextIndex == 0 ? state.clueLap + 1 : state.clueLap;
    state = state.copyWith(clueIndex: nextIndex, clueLap: nextLap);
    _persist();
  }

  void startDiscussion() {
    state = state.copyWith(phase: RoundPhase.discussion);
    _persist();
  }

  void proceedToVoting() {
    state = state.copyWith(phase: RoundPhase.voting);
    _persist();
  }

  void startVoting() => proceedToVoting();

  void submitVote(List<String> suspectIds) {
    final voter = state.currentVoter;
    if (voter == null) {
      return;
    }

    final activeIds = state.activePlayers.map((player) => player.id).toSet();
    final sanitized = suspectIds
        .where((id) => id != voter.id && activeIds.contains(id))
        .toSet()
        .take(state.votesPerPlayer)
        .toList(growable: false);
    if (sanitized.length != state.votesPerPlayer) return;
    final nextVotes = Map<String, List<String>>.from(state.votes)
      ..[voter.id] = sanitized;
    state = state.copyWith(votes: nextVotes);

    if (state.currentVoter == null) {
      final pack = selectedPack;
      final cycleOutcome = _engine.resolveRound(
        players: state.players,
        outsiderIds: state.outsiderIds,
        topic: state.currentTopic ?? '',
        votes: nextVotes,
        topicPool: pack.topics,
        voteScoreMultipliers: _voteScoreMultipliers(),
        assignedPowerCards: state.powerCards,
        accusationLimit: state.usesSequentialElimination
            ? 1
            : state.outsiderCount,
      );
      final newlyEliminated = state.usesSequentialElimination
          ? cycleOutcome.latestAccusedPlayerIds
          : const <String>[];
      final survivingOutsiders = state.outsiderIds
          .where(
            (id) =>
                !state.eliminatedPlayerIds.contains(id) &&
                !newlyEliminated.contains(id),
          )
          .toList(growable: false);
      final outcome = state.usesSequentialElimination && state.outcome != null
          ? _engine.mergeVotingOutcomes(
              previous: state.outcome!,
              current: cycleOutcome,
              survivingOutsiderIds: survivingOutsiders,
            )
          : cycleOutcome.copyWith(survivingOutsiderIds: survivingOutsiders);

      state = state.copyWith(
        phase: RoundPhase.suspense,
        outcome: outcome,
        outsiderGuessIndex: 0,
        outsiderGuessAttempts: 0,
      );
    }

    _persist();
  }

  void finishSuspense() {
    final outcome = state.outcome;
    if (outcome == null) {
      return;
    }
    if (!state.usesSequentialElimination) {
      state = state.copyWith(phase: RoundPhase.outsiderGuess);
      _persist();
      return;
    }

    final eliminated = <String>{
      ...state.eliminatedPlayerIds,
      ...outcome.latestAccusedPlayerIds,
    };
    final survivingOutsiders = state.outsiderIds
        .where((id) => !eliminated.contains(id))
        .toList(growable: false);
    final remainingPlayers = state.players
        .where((player) => !eliminated.contains(player.id))
        .toList(growable: false);
    final remainingInnocents =
        remainingPlayers.length - survivingOutsiders.length;
    final outsidersReachedParity =
        survivingOutsiders.isNotEmpty &&
        survivingOutsiders.length >= remainingInnocents;
    final sequenceFinished =
        survivingOutsiders.isEmpty || outsidersReachedParity;
    final updatedOutcome = outcome.copyWith(
      survivingOutsiderIds: survivingOutsiders,
      outsiderCaught: survivingOutsiders.length < state.outsiderIds.length,
    );

    state = state.copyWith(
      phase: sequenceFinished ? RoundPhase.outsiderGuess : RoundPhase.clueTurns,
      outcome: updatedOutcome,
      eliminatedPlayerIds: eliminated.toList(growable: false),
      votes: sequenceFinished ? state.votes : const <String, List<String>>{},
      clueIndex: 0,
      clueLap: 0,
      eliminationRound: sequenceFinished
          ? state.eliminationRound
          : state.eliminationRound + 1,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
    );
    _persist();
  }

  void submitOutsiderGuess(String guessedTopic) {
    final outcome = state.outcome;
    final currentOutsider = state.currentOutsiderGuesser;
    if (outcome == null || currentOutsider == null) {
      return;
    }

    final card = PowerCardCatalog.parseCardId(
      state.powerCards[currentOutsider.id] ?? '',
    );
    if (card == PowerCardCatalog.outsiderPointWager &&
        !state.outsiderWagerTargetIds.containsKey(currentOutsider.id)) {
      return;
    }
    final isSecondChance = card == PowerCardCatalog.outsiderSecondChance;
    final isCorrect = guessedTopic == outcome.topic;

    if (!isCorrect && isSecondChance && state.outsiderGuessAttempts == 0) {
      state = state.copyWith(outsiderGuessAttempts: 1);
      _persist();
      return;
    }

    final wagerTargetId = state.outsiderWagerTargetIds[currentOutsider.id];
    final wagerTarget = wagerTargetId == null
        ? null
        : state.players.firstWhereOrNull(
            (player) => player.id == wagerTargetId,
          );
    final wagerStake = wagerTarget == null
        ? 0
        : max(1, (wagerTarget.score.abs() + 1) ~/ 2);
    final highRisk = card == PowerCardCatalog.outsiderHighRisk;
    final nextOutcome = _engine.finalizeOutsiderGuess(
      outcome: outcome,
      outsiderId: currentOutsider.id,
      guessedTopic: guessedTopic,
      correctPoints: highRisk
          ? 4
          : wagerStake > 0
          ? wagerStake
          : 1,
      wrongPoints: highRisk
          ? 4
          : wagerStake > 0
          ? wagerStake
          : 1,
      wagerTargetId: wagerTargetId,
      wagerStake: wagerStake,
    );

    final nextGuessIndex = state.outsiderGuessIndex + 1;
    final isLastGuess = nextGuessIndex >= outcome.outsiderIds.length;
    final updatedPlayers = isLastGuess && state.scoringEnabled
        ? _engine.applyOutcome(players: state.players, outcome: nextOutcome)
        : state.players;

    state = state.copyWith(
      players: updatedPlayers,
      outcome: nextOutcome,
      outsiderGuessIndex: isLastGuess
          ? state.outsiderGuessIndex
          : nextGuessIndex,
      outsiderGuessAttempts: 0,
      phase: isLastGuess ? RoundPhase.results : RoundPhase.outsiderGuess,
    );

    _persist();
  }

  void activateFourChoiceForCurrentOutsider() {
    final outsider = state.currentOutsiderGuesser;
    final outcome = state.outcome;
    if (outsider == null ||
        outcome == null ||
        state.currentOutsiderCardId != PowerCardCatalog.outsiderFourChoice ||
        state.activatedOutsiderSkillIds.contains(outsider.id)) {
      return;
    }
    final options = _engine.buildOutsiderGuessOptions(
      topic: outcome.topic,
      topicPool: selectedPack.topics,
      optionCount: 4,
    );
    state = state.copyWith(
      outcome: outcome.copyWith(
        outsiderGuessOptionsByPlayer: {
          ...outcome.outsiderGuessOptionsByPlayer,
          outsider.id: options,
        },
      ),
      activatedOutsiderSkillIds: {
        ...state.activatedOutsiderSkillIds,
        outsider.id,
      },
    );
    _persist();
  }

  void selectOutsiderWagerTarget(String playerId) {
    final outsider = state.currentOutsiderGuesser;
    if (outsider == null ||
        state.currentOutsiderCardId != PowerCardCatalog.outsiderPointWager ||
        playerId == outsider.id ||
        !state.players.any((player) => player.id == playerId)) {
      return;
    }
    state = state.copyWith(
      outsiderWagerTargetIds: {
        ...state.outsiderWagerTargetIds,
        outsider.id: playerId,
      },
    );
    _persist();
  }

  void finalizeRound() {
    final outcome = state.outcome;
    if (outcome == null) {
      return;
    }

    state = state.copyWith(
      phase: RoundPhase.reveal,
      currentTopic: null,
      outsiderIds: const [],
      votes: const <String, List<String>>{},
      powerCards: const <String, String>{},
      assignments: const [],
      revealIndex: 0,
      clueIndex: 0,
      clueLap: 0,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
      outcome: null,
      eliminatedPlayerIds: const [],
      eliminationRound: 1,
      activatedOutsiderSkillIds: const {},
      outsiderWagerTargetIds: const {},
    );

    _persist();
  }

  void resetScores() {
    state = state.copyWith(
      players: [for (final player in state.players) player.copyWith(score: 0)],
    );
    _persist();
  }

  void setCustomState({
    required List<PlayerProfile> players,
    required List<SecretAssignment> assignments,
    required String currentTopic,
    required List<String> outsiderIds,
    required Map<String, String> powerCards,
    required RoundPhase phase,
    int revealIndex = 0,
    int outsiderGuessIndex = 0,
    int outsiderGuessAttempts = 0,
    RoundOutcome? outcome,
  }) {
    state = state.copyWith(
      players: players,
      assignments: assignments,
      currentTopic: currentTopic,
      outsiderIds: outsiderIds,
      powerCards: powerCards,
      phase: phase,
      revealIndex: revealIndex,
      outsiderGuessIndex: outsiderGuessIndex,
      outsiderGuessAttempts: outsiderGuessAttempts,
      outcome: outcome,
      eliminatedPlayerIds: const [],
      eliminationRound: 1,
      activatedOutsiderSkillIds: const {},
      outsiderWagerTargetIds: const {},
    );
    _persist();
  }

  Future<void> playAgain() async {
    state = state.copyWith(roundNumber: state.roundNumber + 1);
    _persist();
    await startRound();
  }

  Future<void> beginNewSession(GameMode mode) async {
    final locale = ref.read(appSettingsProvider).locale;
    state =
        GameSessionState.initial(
          players: buildStarterPlayers(locale: locale),
          hasSavedSession: false,
        ).copyWith(
          selectedMode: mode,
          discussionSeconds: mode.defaultDiscussionSeconds,
        );
    await ref.read(savedGroupsProvider.notifier).activate(null);
    _writeQueue = _writeQueue
        .then<void>((_) => _sessionStore.clear())
        .catchError(_handlePersistenceError);
    await _writeQueue;
  }

  PersistedGameSession exportSnapshot() => _snapshot();

  Future<void> loadSavedSession(
    PersistedGameSession session, {
    bool resetScores = false,
  }) async {
    final restoredPlayers = resetScores
        ? [for (final player in session.players) player.copyWith(score: 0)]
        : session.players;
    final locale = ref.read(appSettingsProvider).locale;
    final players = _localizedDefaultPlayers(restoredPlayers, locale);
    final availablePacks = ref.read(categoryLibraryProvider);
    final selectedPackId =
        availablePacks.any((pack) => pack.id == session.selectedPackId)
        ? session.selectedPackId
        : availablePacks.first.id;
    state = GameSessionState.fromPersisted(
      PersistedGameSession(
        players: players,
        selectedMode: session.selectedMode,
        selectedPackId: selectedPackId,
        discussionSeconds: session.discussionSeconds,
        scoringEnabled: session.scoringEnabled,
        powerCardsEnabled: session.powerCardsEnabled,
        activePowerCardIds: session.activePowerCardIds,
        outsidersKnowEachOther: session.outsidersKnowEachOther,
        outsiderCount: session.outsiderCount.clamp(
          1,
          maxOutsidersForPlayerCount(players.length),
        ),
        roundNumber: resetScores ? 1 : session.roundNumber,
        powerDensity: session.powerDensity,
        sequentialEliminationEnabled: session.sequentialEliminationEnabled,
      ),
    );
    _persist();
    await flushPendingSaves();
  }

  Future<void> clearSavedSession() async {
    final locale = ref.read(appSettingsProvider).locale;
    state = GameSessionState.initial(
      players: buildStarterPlayers(locale: locale),
      hasSavedSession: false,
    );
    _writeQueue = _writeQueue
        .then<void>((_) => _sessionStore.clear())
        .catchError(_handlePersistenceError);
    await _writeQueue;
  }

  Future<void> flushPendingSaves() => _writeQueue;

  void _clampOutsiderCount() {
    final maxAllowed = maxOutsidersForPlayerCount(state.players.length);
    if (state.outsiderCount > maxAllowed) {
      state = state.copyWith(outsiderCount: maxAllowed);
    }
  }

  void _refreshDefaultPlayerNames(SupportedLocale locale) {
    state = state.copyWith(
      players: _localizedDefaultPlayers(state.players, locale),
    );
    if (state.hasSavedSession) {
      _persist();
    }
  }

  List<PlayerProfile> _localizedDefaultPlayers(
    List<PlayerProfile> players,
    SupportedLocale locale,
  ) {
    return [
      for (var index = 0; index < players.length; index++)
        if (isDefaultPlayerName(players[index].name))
          players[index].copyWith(name: defaultPlayerName(index + 1, locale))
        else
          players[index],
    ];
  }

  Future<void> _ensurePackTranslations(CategoryPack pack) async {
    final locale = ref.read(appSettingsProvider).locale;
    if (locale == SupportedLocale.arabic) {
      return;
    }

    await ref
        .read(topicTranslationsProvider.notifier)
        .ensureTopicsTranslated(packId: pack.id, topics: pack.topics);
  }

  CategoryPack get selectedPack {
    return ref
        .read(categoryLibraryProvider.notifier)
        .getPackById(state.selectedPackId);
  }

  Map<String, String> _buildAssignedPowerCards({
    required Set<String> outsiderIds,
  }) {
    if (!state.powerCardsEnabled ||
        state.activePowerCardIds.isEmpty ||
        (state.selectedMode != GameMode.classic &&
            state.selectedMode != GameMode.quick)) {
      return const <String, String>{};
    }

    final random = Random();
    final playerCount = state.players.length;
    final assignCount = switch (state.powerDensity) {
      PowerDensity.mayhem => playerCount,
      PowerDensity.intense => min(
        playerCount,
        max(2, min(4, (playerCount * 0.6).round())),
      ),
      PowerDensity.balanced =>
        playerCount <= 4
            ? (random.nextBool() ? 2 : 1)
            : (random.nextBool() ? 3 : 2),
    };

    final shuffledPlayers = [...state.players]..shuffle(random);
    final chosenPlayers = shuffledPlayers
        .take(assignCount)
        .toList(growable: false);

    final assigned = <String, String>{};
    final innocentPool = PowerCardCatalog.innocentCardIds
        .where((id) => state.activePowerCardIds.contains(id))
        .toList(growable: true);
    final outsiderPool = PowerCardCatalog.outsiderCardIds
        .where((id) => state.activePowerCardIds.contains(id))
        .toList(growable: true);

    for (final player in chosenPlayers) {
      if (outsiderIds.contains(player.id)) {
        if (outsiderPool.isNotEmpty) {
          outsiderPool.shuffle(random);
          assigned[player.id] = outsiderPool.first;
        }
      } else {
        if (innocentPool.isNotEmpty) {
          innocentPool.shuffle(random);
          final picked = innocentPool.first;
          if (picked == PowerCardCatalog.tacticalDrain) {
            final victimPool = state.players
                .where((p) => p.id != player.id)
                .toList();
            if (victimPool.isNotEmpty) {
              victimPool.shuffle(random);
              assigned[player.id] =
                  '${PowerCardCatalog.tacticalDrain}:${victimPool.first.id}';
            } else {
              assigned[player.id] = PowerCardCatalog.doubleVote;
            }
          } else if (picked == PowerCardCatalog.tacticalAlliance) {
            final allyPool = state.players
                .where((p) => p.id != player.id)
                .toList();
            if (allyPool.isNotEmpty) {
              allyPool.shuffle(random);
              assigned[player.id] =
                  '${PowerCardCatalog.tacticalAlliance}:${allyPool.first.id}';
            } else {
              assigned[player.id] = PowerCardCatalog.doubleVote;
            }
          } else {
            assigned[player.id] = picked;
          }
        }
      }
    }

    return assigned;
  }

  Map<String, int> _voteScoreMultipliers() {
    if (!state.powerCardsEnabled) {
      return const <String, int>{};
    }
    return {
      for (final entry in state.powerCards.entries)
        if (entry.value == PowerCardCatalog.doubleVote) entry.key: 2,
    };
  }

  PersistedGameSession _snapshot() {
    return PersistedGameSession(
      players: state.players,
      selectedMode: state.selectedMode,
      selectedPackId: state.selectedPackId,
      discussionSeconds: state.discussionSeconds,
      scoringEnabled: state.scoringEnabled,
      powerCardsEnabled: state.powerCardsEnabled,
      activePowerCardIds: state.activePowerCardIds,
      outsidersKnowEachOther: state.outsidersKnowEachOther,
      sequentialEliminationEnabled: state.sequentialEliminationEnabled,
      outsiderCount: state.outsiderCount,
      roundNumber: state.roundNumber,
      powerDensity: state.powerDensity,
    );
  }

  void _persist() {
    if (!state.hasSavedSession) {
      state = state.copyWith(hasSavedSession: true);
    }
    final snapshot = _snapshot();
    final sessionStore = _sessionStore;
    final groupsController = ref.read(savedGroupsProvider.notifier);
    final groupSave = groupsController.syncActive(snapshot);
    _writeQueue = _writeQueue
        .then<void>((_) async {
          await sessionStore.save(snapshot);
          await groupSave;
        })
        .catchError(_handlePersistenceError);
  }

  void _handlePersistenceError(Object error, StackTrace stackTrace) {
    debugPrint('Could not persist the local game session: $error');
  }
}

final gameSessionStoreProvider = Provider<GameSessionStore>(
  (ref) => LocalGameSessionStore(),
);

final initialGameSessionProvider = Provider<PersistedGameSession?>(
  (ref) => null,
);

final gameSessionProvider =
    NotifierProvider<GameSessionController, GameSessionState>(
      GameSessionController.new,
    );
