import 'dart:async';

import 'package:collection/collection.dart';
import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/round_phase.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/results/presentation/results_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({super.key, this.initialRevealed = false});

  final bool initialRevealed;
  static const routePath = '/round';

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  static const int _defaultOutsiderGuessSeconds = 25;

  late bool _revealed = widget.initialRevealed;
  late bool _hasRevealedCurrent = widget.initialRevealed;
  final Set<String> _selectedSuspectIds = <String>{};
  String? _selectedTopicGuess;
  Timer? _discussionTimer;
  Timer? _outsiderGuessTimer;
  int? _remainingSeconds;
  int? _outsiderRemainingSeconds;
  bool _timerStarted = false;
  bool _suspenseScheduled = false;
  int? _armedOutsiderGuessIndex;
  final GlobalKey _revealCardKey = GlobalKey();
  bool _secretGestureReachedTopRight = false;
  bool _showSecretPrankIntel = false;

  @override
  void dispose() {
    _discussionTimer?.cancel();
    _outsiderGuessTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    warmUiPhrases(ref, const [
      'لا توجد جولة نشطة',
      'العودة للرئيسية',
      'مرر الجوال إلى',
      'اضغط مطولًا على البطاقة حتى يظهر الدور بشكل خاص.',
      'دورك الآن',
      'اضغط مطولًا للكشف',
      'اسمع التلميحات واندمج بدون ما تنكشف.',
      'احتفظ بالسالفة لنفسك ولا تذكرها حرفيًا.',
      'أمسك الجهاز قريبًا منك فقط.',
      'دور',
      'قل تلميحًا قصيرًا أو كلمة ذكية بدون ذكر السالفة نفسها.',
      'الدورة',
      'اللاعب',
      'ابدأ النقاش',
      'وقت النقاش',
      'ناقشوا بحرية: من يبدو خارج السالفة؟',
      'ثانية',
      'إيقاف',
      'ابدأ المؤقت',
      'ابدأ التصويت',
      'اختر المشتبهين بعدد برا السالفة. لا يمكنك التصويت لنفسك.',
      'عدد الأصوات المتاحة',
      'لحظة حاسمة...',
      'يتم الآن كشف أصحاب برا السالفة وتجهيز التحدي الأخير لهم واحدًا تلو الآخر.',
      'يتم الآن كشف برا السالفة وتجهيز التحدي الأخير.',
      'اختر السالفة الصحيحة قبل انتهاء الوقت.',
      'جدار الاختيارات',
      'اختر بسرعة. إذا انتهى الوقت تُسجل إجابة خاطئة تلقائيًا.',
      'انتهى الوقت',
    ]);
    _warmRoundTranslations(session, settings.locale);
    final l10n = AppLocalizations.of(context);

    if (session.phase != RoundPhase.discussion) {
      _discussionTimer?.cancel();
      _discussionTimer = null;
      _timerStarted = false;
      _remainingSeconds = session.discussionSeconds;
    }

    if (session.phase != RoundPhase.voting && _selectedSuspectIds.isNotEmpty) {
      _selectedSuspectIds.clear();
    }

    if (session.phase == RoundPhase.suspense) {
      _scheduleSuspenseTransition();
    } else {
      _suspenseScheduled = false;
    }

    if (session.phase == RoundPhase.outsiderGuess) {
      if (_armedOutsiderGuessIndex != session.outsiderGuessIndex) {
        _outsiderGuessTimer?.cancel();
        _outsiderGuessTimer = null;
        _outsiderRemainingSeconds = _guessDurationFor(session);
        _selectedTopicGuess = null;
        _armedOutsiderGuessIndex = null;
      }
      _armOutsiderGuessTimer();
    } else {
      _outsiderGuessTimer?.cancel();
      _outsiderGuessTimer = null;
      _outsiderRemainingSeconds = _defaultOutsiderGuessSeconds;
      _armedOutsiderGuessIndex = null;
      _selectedTopicGuess = null;
    }

    if (!session.hasActiveRound) {
      return BaraScaffold(
        title: localizeUiPhrase(ref, 'لا توجد جولة نشطة'),
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: BaraButton.primary(
              label: localizeUiPhrase(ref, 'العودة للرئيسية'),
              icon: Icons.home_rounded,
              onPressed: () => context.go(HomeScreen.routePath),
            ),
          ),
        ),
      );
    }

    if (session.phase == RoundPhase.results) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(ResultsScreen.routePath);
        }
      });
    }

    return BaraScaffold(
      title: l10n.roundNumber(session.roundNumber),
      actions: [
        IconButton(
          onPressed: () => context.go(HomeScreen.routePath),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          _PhaseHeader(phase: session.phase),
          const SizedBox(height: 18),
          switch (session.phase) {
            RoundPhase.reveal => _buildRevealPhase(
              context,
              session,
              settings.hapticsEnabled,
            ),
            RoundPhase.clueTurns => _buildCluePhase(context, session),
            RoundPhase.discussion => _buildDiscussionPhase(context, session),
            RoundPhase.voting => _buildVotingPhase(context, session),
            RoundPhase.suspense => _buildSuspensePhase(context, session),
            RoundPhase.outsiderGuess => _buildOutsiderGuessPhase(
              context,
              session,
            ),
            RoundPhase.results => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  Widget _buildRevealPhase(
    BuildContext context,
    GameSessionState session,
    bool hapticsEnabled,
  ) {
    final assignment = session.currentRevealAssignment;
    if (assignment == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizeUiPhrase(ref, 'مرر الجوال إلى')} ${assignment.playerName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                localizeUiPhrase(
                  ref,
                  'اضغط مطولًا على البطاقة حتى يظهر الدور بشكل خاص.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onLongPressStart: (_) async {
            if (hapticsEnabled) {
              await HapticFeedback.mediumImpact();
            }
            setState(() {
              _revealed = true;
              _hasRevealedCurrent = true;
              _secretGestureReachedTopRight = false;
              _showSecretPrankIntel = false;
            });
          },
          onLongPressMoveUpdate: (details) =>
              _trackSecretRevealGesture(details, session, assignment.playerId),
          onLongPressEnd: (_) {
            if (!mounted) return;
            setState(() {
              _revealed = false;
              _secretGestureReachedTopRight = false;
              _showSecretPrankIntel = false;
            });
          },
          onLongPressCancel: () {
            if (!mounted) return;
            setState(() {
              _revealed = false;
              _secretGestureReachedTopRight = false;
              _showSecretPrankIntel = false;
            });
          },
          child: AnimatedContainer(
            key: _revealCardKey,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: _revealed
                    ? [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ]
                    : [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  _revealed
                      ? localizeUiPhrase(ref, 'دورك الآن')
                      : localizeUiPhrase(ref, 'اضغط مطولًا للكشف'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _revealed ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _revealed
                      ? assignment.isOutsider
                            ? AppLocalizations.of(context).youAreOutsider
                            : _localizedTopic(
                                session.selectedPackId,
                                assignment.topic,
                              )
                      : '••••••',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _revealed
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_revealed &&
                    assignment.isOutsider &&
                    session.outsidersKnowEachOther) ...[
                  const SizedBox(height: 14),
                  _RevealInfoPill(
                    icon: Icons.groups_rounded,
                    text: _knownOutsiderNames(session, assignment.playerId),
                  ),
                ],
                if (_revealed &&
                    session.powerCards.containsKey(assignment.playerId)) ...[
                  const SizedBox(height: 14),
                  _RevealInfoPill(
                    icon: Icons.auto_awesome_rounded,
                    text: _powerCardLabel(
                      session.powerCards[assignment.playerId]!,
                      session,
                    ),
                  ),
                ],
                if (_revealed && _showSecretPrankIntel) ...[
                  const SizedBox(height: 14),
                  _RevealInfoPill(
                    icon: Icons.visibility_off_rounded,
                    text:
                        '${localizeUiPhrase(ref, 'السالفة:')} ${_localizedTopic(session.selectedPackId, assignment.topic)}\n'
                        '${localizeUiPhrase(ref, 'برا السالفة:')} ${_secretOutsiderNames(session)}',
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  _revealed
                      ? assignment.isOutsider
                            ? localizeUiPhrase(
                                ref,
                                'اسمع التلميحات واندمج بدون ما تنكشف.',
                              )
                            : localizeUiPhrase(
                                ref,
                                'احتفظ بالسالفة لنفسك ولا تذكرها حرفيًا.',
                              )
                      : localizeUiPhrase(ref, 'أمسك الجهاز قريبًا منك فقط.'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _revealed
                        ? Colors.white.withValues(alpha: 0.9)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        BaraButton.primary(
          label: session.revealIndex == session.assignments.length - 1
              ? AppLocalizations.of(context).cluePhase
              : AppLocalizations.of(context).next,
          icon: Icons.arrow_back_rounded,
          onPressed: (_revealed || _hasRevealedCurrent)
              ? () {
                  setState(() {
                    _revealed = false;
                    _hasRevealedCurrent = false;
                    _secretGestureReachedTopRight = false;
                    _showSecretPrankIntel = false;
                  });
                  ref.read(gameSessionProvider.notifier).advanceReveal();
                }
              : null,
        ),
      ],
    );
  }

  void _trackSecretRevealGesture(
    LongPressMoveUpdateDetails details,
    GameSessionState session,
    String playerId,
  ) {
    if (!session.secretPrankConfig.isInsider(playerId)) return;
    final renderObject = _revealCardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final position = details.localPosition;
    final size = renderObject.size;
    if (!_secretGestureReachedTopRight &&
        position.dx >= size.width * 0.68 &&
        position.dy <= size.height * 0.35) {
      _secretGestureReachedTopRight = true;
      return;
    }
    if (_secretGestureReachedTopRight &&
        !_showSecretPrankIntel &&
        position.dx <= size.width * 0.32 &&
        position.dy >= size.height * 0.65) {
      HapticFeedback.lightImpact();
      setState(() => _showSecretPrankIntel = true);
    }
  }

  String _secretOutsiderNames(GameSessionState session) {
    return session.players
        .where((player) => session.outsiderIds.contains(player.id))
        .map((player) => player.name)
        .join('، ');
  }

  Widget _buildCluePhase(BuildContext context, GameSessionState session) {
    final player = session.currentCluePlayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            children: [
              Text(
                '${localizeUiPhrase(ref, 'دور')} ${player?.name ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                localizeUiPhrase(
                  ref,
                  'قل تلميحًا قصيرًا أو كلمة ذكية بدون ذكر السالفة نفسها.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    label: Text(
                      '${localizeUiPhrase(ref, 'الدورة')} ${session.clueLap + 1}',
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${localizeUiPhrase(ref, 'اللاعب')} ${session.clueIndex + 1}/${session.activePlayers.length}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: session.activePlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == session.clueIndex;

            return Chip(
              avatar: PlayerAvatar(
                index: item.avatarIndex,
                label: '${item.avatarIndex + 1}',
                radius: 16,
              ),
              label: Text(item.name),
              backgroundColor: isActive
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15)
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: BaraButton.primary(
                label: 'التالي',
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    ref.read(gameSessionProvider.notifier).advanceClueTurn(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BaraButton.secondary(
                label: localizeUiPhrase(ref, 'ابدأ النقاش'),
                icon: Icons.forum_rounded,
                onPressed: () =>
                    ref.read(gameSessionProvider.notifier).startDiscussion(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscussionPhase(BuildContext context, GameSessionState session) {
    _remainingSeconds ??= session.discussionSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            children: [
              Text(
                localizeUiPhrase(ref, 'وقت النقاش'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                localizeUiPhrase(ref, 'ناقشوا بحرية: من يبدو خارج السالفة؟'),
              ),
              const SizedBox(height: 20),
              Container(
                width: 180,
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.18),
                    width: 12,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_remainingSeconds ?? session.discussionSeconds}',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text(localizeUiPhrase(ref, 'ثانية')),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: BaraButton.secondary(
                      label: _timerStarted
                          ? localizeUiPhrase(ref, 'إيقاف')
                          : localizeUiPhrase(ref, 'ابدأ المؤقت'),
                      icon: _timerStarted
                          ? Icons.pause_rounded
                          : Icons.timer_rounded,
                      onPressed: () {
                        if (_timerStarted) {
                          _discussionTimer?.cancel();
                          setState(() => _timerStarted = false);
                          return;
                        }
                        _startDiscussionTimer();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BaraButton.primary(
                      label: localizeUiPhrase(ref, 'ابدأ التصويت'),
                      icon: Icons.how_to_vote_rounded,
                      onPressed: () {
                        _discussionTimer?.cancel();
                        setState(() {
                          _timerStarted = false;
                          _remainingSeconds = session.discussionSeconds;
                        });
                        ref.read(gameSessionProvider.notifier).startVoting();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVotingPhase(BuildContext context, GameSessionState session) {
    final voter = session.currentVoter;
    final visiblePlayers = session.activePlayers
        .where((player) => player.id != voter?.id)
        .toList();
    final requiredVotes = session.votesPerPlayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            children: [
              Text(
                '${localizeUiPhrase(ref, 'مرر الجوال إلى')} ${voter?.name ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                session.usesSequentialElimination
                    ? 'اختر مشتبهًا واحدًا. سيتم إقصاء لاعب واحد فقط، ثم تبدأ جولة جديدة إذا استمرت المواجهة.'
                    : localizeUiPhrase(
                        ref,
                        'اختر المشتبهين بعدد برا السالفة. لا يمكنك التصويت لنفسك.',
                      ),
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(
                  '${localizeUiPhrase(ref, 'عدد الأصوات المتاحة')}: $requiredVotes',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visiblePlayers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final player = visiblePlayers[index];
            final isSelected = _selectedSuspectIds.contains(player.id);
            final selectionIndex = _selectedSuspectIds
                .toList(growable: false)
                .indexOf(player.id);
            return GlowCard(
              isSelected: isSelected,
              onTap: isSelected
                  ? null
                  : () => _confirmSuspectChoice(
                      session: session,
                      playerId: player.id,
                      playerName: player.name,
                    ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayerAvatar(
                    index: player.avatarIndex,
                    label: '${player.avatarIndex + 1}',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    player.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Text(
                      'الاختيار ${selectionIndex + 1}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: _selectedSuspectIds.length / requiredVotes,
          minHeight: 8,
          borderRadius: BorderRadius.circular(99),
        ),
        const SizedBox(height: 10),
        Text(
          'تم تأكيد ${_selectedSuspectIds.length} من $requiredVotes. '
          'يُرسل التصويت تلقائيًا بعد آخر اختيار.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _confirmSuspectChoice({
    required GameSessionState session,
    required String playerId,
    required String playerName,
  }) async {
    if (_selectedSuspectIds.contains(playerId)) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(localizeUiPhrase(ref, 'تأكيد التصويت')),
            content: Text(
              '${localizeUiPhrase(ref, 'هل تؤكد التصويت لهذا اللاعب؟')}\n$playerName',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(dialogContext).cancel),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.how_to_vote_rounded),
                label: Text(localizeUiPhrase(ref, 'تأكيد')),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirmed) return;

    final currentSession = ref.read(gameSessionProvider);
    if (currentSession.phase != RoundPhase.voting ||
        currentSession.currentVoter?.id != session.currentVoter?.id ||
        _selectedSuspectIds.contains(playerId)) {
      return;
    }
    final nextChoices = {..._selectedSuspectIds, playerId};
    AppAudio.instance.playVoteConfirm();
    HapticFeedback.selectionClick();
    if (nextChoices.length == currentSession.votesPerPlayer) {
      ref
          .read(gameSessionProvider.notifier)
          .submitVote(nextChoices.toList(growable: false));
      setState(_selectedSuspectIds.clear);
      return;
    }
    setState(() {
      _selectedSuspectIds
        ..clear()
        ..addAll(nextChoices);
    });
  }

  Widget _buildSuspensePhase(BuildContext context, GameSessionState session) {
    final outcome = session.outcome;
    final revealedPlayers = session.usesSequentialElimination
        ? session.players
              .where(
                (player) =>
                    outcome?.latestAccusedPlayerIds.contains(player.id) ??
                    false,
              )
              .toList(growable: false)
        : session.outsiderPlayers;
    return GlowCard(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Column(
          children: [
            const Icon(Icons.visibility_rounded, size: 46),
            const SizedBox(height: 16),
            Text(
              localizeUiPhrase(ref, 'لحظة حاسمة...'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              session.usesSequentialElimination
                  ? outcome?.isTie == true
                        ? 'تعادل التصويت، لن يتم إقصاء أي لاعب في هذه الجولة.'
                        : 'يتم الآن كشف اللاعب الذي اختارته المجموعة فقط.'
                  : session.outsiderIds.length > 1
                  ? localizeUiPhrase(
                      ref,
                      'يتم الآن كشف أصحاب برا السالفة وتجهيز التحدي الأخير لهم واحدًا تلو الآخر.',
                    )
                  : localizeUiPhrase(
                      ref,
                      'يتم الآن كشف برا السالفة وتجهيز التحدي الأخير.',
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: revealedPlayers
                  .map(
                    (player) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.72, end: 1),
                      duration: const Duration(milliseconds: 720),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayerAvatar(
                            index: player.avatarIndex,
                            label: '${player.avatarIndex + 1}',
                            radius: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            player.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (session.usesSequentialElimination) ...[
                            const SizedBox(height: 4),
                            Text(
                              session.outsiderIds.contains(player.id)
                                  ? 'كان برا السالفة'
                                  : 'لم يكن برا السالفة',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const _SuspenseDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutsiderGuessPhase(
    BuildContext context,
    GameSessionState session,
  ) {
    final outsider = session.currentOutsiderGuesser;
    final outcome = session.outcome;
    if (outsider == null || outcome == null) {
      return const SizedBox.shrink();
    }
    final totalOutsiderCount = outcome.outsiderIds.length;
    final duration = _guessDurationFor(session);
    final remaining = _outsiderRemainingSeconds ?? duration ?? 0;
    final guessOptions = outcome.guessOptionsFor(outsider.id);

    if (session.currentOutsiderNeedsWagerTarget) {
      return _buildWagerTargetPhase(context, session, outsider.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1),
          duration: const Duration(milliseconds: 620),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF12392F), Color(0xFF0B1E1A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.22),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      PlayerAvatar(
                        index: outsider.avatarIndex,
                        label: '${outsider.avatarIndex + 1}',
                        radius: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).youAreOutsider} ${session.outsiderGuessIndex + 1}/$totalOutsiderCount: ${outsider.name}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localizeUiPhrase(
                                ref,
                                'اختر السالفة الصحيحة قبل انتهاء الوقت.',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (duration == null)
                        const Chip(
                          avatar: Icon(Icons.all_inclusive_rounded, size: 18),
                          label: Text('وقت غير محدود'),
                        )
                      else
                        _GuessTimerBadge(seconds: remaining),
                    ],
                  ),
                  if (duration != null) ...[
                    const SizedBox(height: 18),
                    LinearProgressIndicator(
                      value: remaining / duration,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                    ),
                  ],
                  if (session.powerCards[outsider.id] ==
                      PowerCardCatalog.outsiderSecondChance) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: session.outsiderGuessAttempts == 0
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                            : const Color(0xFFEF4444).withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: session.outsiderGuessAttempts == 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFEF4444),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            session.outsiderGuessAttempts == 0
                                ? Icons.auto_awesome_rounded
                                : Icons.warning_amber_rounded,
                            color: session.outsiderGuessAttempts == 0
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              session.outsiderGuessAttempts == 0
                                  ? '🎯 مهارة الفرصة المزدوجة: لديك محاولتان للتخمين! (المحاولة 1/2)'
                                  : '⚠️ المحاولة الأولى خاطئة! تبقت لك المحاولة الثانية، اختر السالفة الآن!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlowCard(
          playSound: false,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizeUiPhrase(ref, 'جدار الاختيارات'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (session.currentOutsiderCardId ==
                      PowerCardCatalog.outsiderFourChoice &&
                  !session.activatedOutsiderSkillIds.contains(outsider.id)) ...[
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: 'فعّل زر الإنقاذ: 4 خيارات',
                  icon: Icons.filter_4_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(gameSessionProvider.notifier)
                        .activateFourChoiceForCurrentOutsider();
                  },
                ),
              ],
              const SizedBox(height: 8),
              Text(
                localizeUiPhrase(
                  ref,
                  'اختر بسرعة. إذا انتهى الوقت تُسجل إجابة خاطئة تلقائيًا.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: guessOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.9,
                ),
                itemBuilder: (context, index) {
                  final topic = guessOptions[index];
                  final isSelected = _selectedTopicGuess == topic;

                  return AnimatedScale(
                    scale: isSelected ? 1.02 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: GlowCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      isSelected: isSelected,
                      onTap: () => _confirmTopicGuess(
                        session: session,
                        outsiderId: outsider.id,
                        topic: topic,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _localizedGuessLabel(
                                session.selectedPackId,
                                topic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontSize: 15, height: 1.15),
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWagerTargetPhase(
    BuildContext context,
    GameSessionState session,
    String outsiderId,
  ) {
    final candidates = session.players
        .where((player) => player.id != outsiderId)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          playSound: false,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.casino_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'رهان الرصيد',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'اختر لاعباً قبل بدء الوقت. ستخمن بعدها من جميع سوالف الفئة.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'الصحيح: تكسب نصف رصيده ويُخصم منه. الخاطئ: تخسر الرهان ويحصل هو على +2.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final player in candidates) ...[
          GlowCard(
            onTap: () => _confirmWagerTarget(session, player.id),
            child: Row(
              children: [
                PlayerAvatar(
                  index: player.avatarIndex,
                  label: '${player.avatarIndex + 1}',
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    player.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${player.score} نقطة',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_left_rounded),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _confirmWagerTarget(
    GameSessionState session,
    String playerId,
  ) async {
    final player = session.players.firstWhere((item) => item.id == playerId);
    final stake = ((player.score.abs() + 1) ~/ 2).clamp(1, 1 << 30);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('تأكيد رهان الرصيد'),
            content: Text(
              'هل تختار ${player.name}؟ قيمة الرهان $stake نقطة، وبعد التأكيد يبدأ وقت التخمين.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(dialogContext).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;
    if (!mounted || !confirmed) return;
    ref.read(gameSessionProvider.notifier).selectOutsiderWagerTarget(playerId);
    setState(() {
      _armedOutsiderGuessIndex = null;
      _outsiderRemainingSeconds = _defaultOutsiderGuessSeconds;
    });
  }

  String _localizedTopic(String packId, String topic) {
    final locale = ref.read(appSettingsProvider).locale;
    return ref
        .read(topicTranslationsProvider.notifier)
        .localizedTopic(packId: packId, topic: topic, locale: locale);
  }

  String _localizedGuessLabel(String packId, String guessedTopic) {
    final l10n = AppLocalizations.of(context);
    if (guessedTopic == 'انتهى الوقت') {
      return l10n.timeUp;
    }
    return _localizedTopic(packId, guessedTopic);
  }

  Future<void> _confirmTopicGuess({
    required GameSessionState session,
    required String outsiderId,
    required String topic,
  }) async {
    setState(() => _selectedTopicGuess = topic);
    final label = _localizedGuessLabel(session.selectedPackId, topic);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('تأكيد التخمين'),
              content: Text('هل تريد اختيار "$label"؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(AppLocalizations.of(dialogContext).cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!mounted) {
      return;
    }
    if (!confirmed) {
      setState(() => _selectedTopicGuess = null);
      return;
    }
    _outsiderGuessTimer?.cancel();
    ref.read(gameSessionProvider.notifier).submitOutsiderGuess(topic);
    final updatedSession = ref.read(gameSessionProvider);
    final updatedOutcome = updatedSession.outcome;
    final attemptFinished =
        updatedOutcome?.outsiderGuessResults.containsKey(outsiderId) ?? false;
    if (!attemptFinished) {
      _armedOutsiderGuessIndex = null;
      _outsiderRemainingSeconds = _guessDurationFor(updatedSession);
    }
    if (updatedOutcome?.outsiderGuessResults[outsiderId] == true) {
      AppAudio.instance.playCorrectGuess();
    } else {
      AppAudio.instance.playWrongGuess();
    }
    setState(() => _selectedTopicGuess = null);
  }

  String _knownOutsiderNames(GameSessionState session, String currentPlayerId) {
    final names = session.players
        .where(
          (player) =>
              session.outsiderIds.contains(player.id) &&
              player.id != currentPlayerId,
        )
        .map((player) => player.name)
        .toList(growable: false);
    if (names.isEmpty) {
      return 'أنت برا السالفة الوحيد';
    }
    return 'معك: ${names.join('، ')}';
  }

  String _powerCardLabel(String payload, GameSessionState session) {
    final baseId = PowerCardCatalog.parseCardId(payload);
    final targetId = PowerCardCatalog.parseTargetId(payload);
    final card = PowerCardCatalog.byId(baseId);
    if (baseId == PowerCardCatalog.tacticalDrain && targetId != null) {
      final victim = session.players.firstWhereOrNull((p) => p.id == targetId);
      final victimName = victim?.name ?? 'لاعب مستهدف';
      return '⚡ ${card.label}\n${card.description}\nالهدف: $victimName';
    }
    if (baseId == PowerCardCatalog.tacticalAlliance && targetId != null) {
      final ally = session.players.firstWhereOrNull((p) => p.id == targetId);
      final allyName = ally?.name ?? 'حليفك المختار';
      return '🤝 ${card.label}\n${card.description}\nالحليف: $allyName';
    }
    return '${card.label}\n${card.description}';
  }

  void _warmRoundTranslations(
    GameSessionState session,
    SupportedLocale locale,
  ) {
    if (locale == SupportedLocale.arabic) {
      return;
    }

    final topics = <String>{
      if (session.currentTopic != null) session.currentTopic!,
      ...session.assignments.map((assignment) => assignment.topic),
      ...?session.outcome?.outsiderGuessOptions,
      ...?session.outcome?.outsiderGuessOptionsByPlayer.values.expand(
        (options) => options,
      ),
      ...?session.outcome?.outsiderGuesses.values,
    }..remove('انتهى الوقت');

    if (topics.isEmpty) {
      return;
    }

    Future<void>.microtask(
      () => ref
          .read(topicTranslationsProvider.notifier)
          .ensureTopicsTranslated(
            packId: session.selectedPackId,
            topics: topics,
          ),
    );
  }

  void _startDiscussionTimer() {
    final state = ref.read(gameSessionProvider);
    _discussionTimer?.cancel();
    setState(() {
      _remainingSeconds = _remainingSeconds ?? state.discussionSeconds;
      _timerStarted = true;
    });
    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _remainingSeconds ?? state.discussionSeconds;
      if (remaining <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = state.discussionSeconds;
          _timerStarted = false;
        });
        return;
      }
      setState(() => _remainingSeconds = remaining - 1);
    });
  }

  void _scheduleSuspenseTransition() {
    if (_suspenseScheduled) {
      return;
    }
    _suspenseScheduled = true;
    AppAudio.instance.playSuspenseReveal();
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) {
        return;
      }
      ref.read(gameSessionProvider.notifier).finishSuspense();
    });
  }

  void _armOutsiderGuessTimer() {
    final session = ref.read(gameSessionProvider);
    final outsider = session.currentOutsiderGuesser;
    final duration = _guessDurationFor(session);
    if (_armedOutsiderGuessIndex == session.outsiderGuessIndex ||
        outsider == null ||
        duration == null ||
        session.currentOutsiderNeedsWagerTarget) {
      return;
    }

    _armedOutsiderGuessIndex = session.outsiderGuessIndex;
    _outsiderRemainingSeconds = duration;
    _outsiderGuessTimer?.cancel();
    _outsiderGuessTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _outsiderRemainingSeconds ?? duration;
      if (remaining <= 1) {
        timer.cancel();
        _outsiderGuessTimer = null;
        final expiredOutsider = ref
            .read(gameSessionProvider)
            .currentOutsiderGuesser;
        ref
            .read(gameSessionProvider.notifier)
            .submitOutsiderGuess('انتهى الوقت');
        final updatedSession = ref.read(gameSessionProvider);
        final attemptFinished =
            expiredOutsider == null ||
            (updatedSession.outcome?.outsiderGuessResults.containsKey(
                  expiredOutsider.id,
                ) ??
                false);
        AppAudio.instance.playWrongGuess();
        setState(() {
          _outsiderRemainingSeconds = attemptFinished ? 0 : duration;
          _selectedTopicGuess = null;
          if (!attemptFinished) {
            _armedOutsiderGuessIndex = null;
          }
        });
        if (attemptFinished) {
          _armedOutsiderGuessIndex = null;
        }
        return;
      }

      setState(() {
        _outsiderRemainingSeconds = remaining - 1;
      });
    });
  }

  int? _guessDurationFor(GameSessionState session) {
    return switch (session.currentOutsiderCardId) {
      PowerCardCatalog.outsiderUnlimitedTime => null,
      PowerCardCatalog.outsiderPanicTimer => 10,
      _ => _defaultOutsiderGuessSeconds,
    };
  }
}

class _RevealInfoPill extends StatelessWidget {
  const _RevealInfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({required this.phase});

  final RoundPhase phase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      RoundPhase.reveal: l10n.revealPhase,
      RoundPhase.clueTurns: l10n.cluePhase,
      RoundPhase.discussion: l10n.discussionPhase,
      RoundPhase.voting: l10n.votingPhase,
      RoundPhase.suspense: l10n.guessPhase,
      RoundPhase.outsiderGuess: l10n.guessTheTopic,
      RoundPhase.results: l10n.results,
    };

    return GlowCard(
      child: Row(
        children: [
          Icon(
            Icons.bolt_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              labels[phase]!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuspenseDots extends StatefulWidget {
  const _SuspenseDots();

  @override
  State<_SuspenseDots> createState() => _SuspenseDotsState();
}

class _SuspenseDotsState extends State<_SuspenseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final offset = (_controller.value - (index * 0.18)).clamp(0.0, 1.0);
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.35 + (offset * 0.65)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _GuessTimerBadge extends StatelessWidget {
  const _GuessTimerBadge({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final isUrgent = seconds <= 5;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isUrgent
            ? const Color(0xFFF06A5F).withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFF06A5F).withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$seconds',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'ث',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}
