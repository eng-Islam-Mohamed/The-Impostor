import 'dart:async';

import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
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
  const RoundScreen({super.key});

  static const routePath = '/round';

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  static const int _outsiderGuessSeconds = 20;

  bool _revealed = false;
  final Set<String> _selectedSuspectIds = <String>{};
  String? _selectedTopicGuess;
  Timer? _discussionTimer;
  Timer? _outsiderGuessTimer;
  int? _remainingSeconds;
  int? _outsiderRemainingSeconds;
  bool _timerStarted = false;
  bool _suspenseScheduled = false;
  int? _armedOutsiderGuessIndex;

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
    warmUiPhrases(
      ref,
      const [
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
        'اختر السالفة الصحيحة من بين 15 خيارًا قبل انتهاء الوقت.',
        'جدار الاختيارات',
        'اختر بسرعة. إذا انتهى الوقت تُسجل إجابة خاطئة تلقائيًا.',
        'انتهى الوقت',
      ],
    );
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
        _outsiderRemainingSeconds = _outsiderGuessSeconds;
        _selectedTopicGuess = null;
        _armedOutsiderGuessIndex = null;
      }
      _armOutsiderGuessTimer();
    } else {
      _outsiderGuessTimer?.cancel();
      _outsiderGuessTimer = null;
      _outsiderRemainingSeconds = _outsiderGuessSeconds;
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
            RoundPhase.reveal => _buildRevealPhase(context, session, settings.hapticsEnabled),
            RoundPhase.clueTurns => _buildCluePhase(context, session),
            RoundPhase.discussion => _buildDiscussionPhase(context, session),
            RoundPhase.voting => _buildVotingPhase(context, session),
            RoundPhase.suspense => _buildSuspensePhase(context, session),
            RoundPhase.outsiderGuess => _buildOutsiderGuessPhase(context, session),
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
              Text(localizeUiPhrase(ref, 'اضغط مطولًا على البطاقة حتى يظهر الدور بشكل خاص.')),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onLongPressStart: (_) async {
            if (hapticsEnabled) {
              await HapticFeedback.mediumImpact();
            }
            setState(() => _revealed = true);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: _revealed
                    ? assignment.isOutsider
                        ? const [Color(0xFFF06A5F), Color(0xFFD14E44)]
                        : const [Color(0xFF0F8F78), Color(0xFF43C0A4)]
                    : [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
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
                          : _localizedTopic(session.selectedPackId, assignment.topic)
                      : '••••••',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: _revealed ? Colors.white : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  _revealed
                      ? assignment.isOutsider
                          ? localizeUiPhrase(ref, 'اسمع التلميحات واندمج بدون ما تنكشف.')
                          : localizeUiPhrase(ref, 'احتفظ بالسالفة لنفسك ولا تذكرها حرفيًا.')
                      : localizeUiPhrase(ref, 'أمسك الجهاز قريبًا منك فقط.'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _revealed ? Colors.white.withValues(alpha: 0.9) : null,
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
          onPressed: _revealed
              ? () {
                  setState(() => _revealed = false);
                  ref.read(gameSessionProvider.notifier).advanceReveal();
                }
              : null,
        ),
      ],
    );
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
                localizeUiPhrase(ref, 'قل تلميحًا قصيرًا أو كلمة ذكية بدون ذكر السالفة نفسها.'),
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
                      '${localizeUiPhrase(ref, 'اللاعب')} ${session.clueIndex + 1}/${session.players.length}',
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
          children: session.players.asMap().entries.map((entry) {
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
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
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
                onPressed: () => ref.read(gameSessionProvider.notifier).advanceClueTurn(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BaraButton.secondary(
                label: localizeUiPhrase(ref, 'ابدأ النقاش'),
                icon: Icons.forum_rounded,
                onPressed: () => ref.read(gameSessionProvider.notifier).startDiscussion(),
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
              Text(localizeUiPhrase(ref, 'ناقشوا بحرية: من يبدو خارج السالفة؟')),
              const SizedBox(height: 20),
              Container(
                width: 180,
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
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
                      icon: _timerStarted ? Icons.pause_rounded : Icons.timer_rounded,
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
    final visiblePlayers = session.players.where((player) => player.id != voter?.id).toList();

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
                localizeUiPhrase(ref, 'اختر المشتبهين بعدد برا السالفة. لا يمكنك التصويت لنفسك.'),
              ),
              const SizedBox(height: 12),
              Chip(
                label: Text(
                  '${localizeUiPhrase(ref, 'عدد الأصوات المتاحة')}: ${session.outsiderCount}',
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
            return GlowCard(
              isSelected: isSelected,
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedSuspectIds.remove(player.id);
                  return;
                }
                if (_selectedSuspectIds.length >= session.outsiderCount) {
                  return;
                }
                _selectedSuspectIds.add(player.id);
              }),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayerAvatar(
                    index: player.avatarIndex,
                    label: '${player.avatarIndex + 1}',
                  ),
                  const SizedBox(height: 10),
                  Text(player.name, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        BaraButton.primary(
          label: AppLocalizations.of(context).confirmVote,
          icon: Icons.check_circle_rounded,
          playSound: false,
          onPressed: _selectedSuspectIds.length != session.outsiderCount
              ? null
              : () {
                  AppAudio.instance.playVoteConfirm();
                  ref.read(gameSessionProvider.notifier).submitVote(
                        _selectedSuspectIds.toList(growable: false),
                      );
                  setState(_selectedSuspectIds.clear);
                },
        ),
      ],
    );
  }

  Widget _buildSuspensePhase(BuildContext context, GameSessionState session) {
    return GlowCard(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
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
              session.outsiderIds.length > 1
                  ? localizeUiPhrase(
                      ref,
                      'يتم الآن كشف أصحاب برا السالفة وتجهيز التحدي الأخير لهم واحدًا تلو الآخر.',
                    )
                  : localizeUiPhrase(ref, 'يتم الآن كشف برا السالفة وتجهيز التحدي الأخير.'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const _SuspenseDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutsiderGuessPhase(BuildContext context, GameSessionState session) {
    final outsider = session.currentOutsiderGuesser;
    final outcome = session.outcome;
    if (outsider == null || outcome == null) {
      return const SizedBox.shrink();
    }
    final totalOutsiderCount = outcome.outsiderIds.length;
    final remaining = _outsiderRemainingSeconds ?? _outsiderGuessSeconds;

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
                colors: [
                  Color(0xFF12392F),
                  Color(0xFF0B1E1A),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localizeUiPhrase(
                                ref,
                                'اختر السالفة الصحيحة من بين 15 خيارًا قبل انتهاء الوقت.',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      _GuessTimerBadge(seconds: remaining),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: remaining / _outsiderGuessSeconds,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                  ),
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
              const SizedBox(height: 8),
              Text(
                localizeUiPhrase(ref, 'اختر بسرعة. إذا انتهى الوقت تُسجل إجابة خاطئة تلقائيًا.'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 460,
                child: GridView.builder(
                  itemCount: outcome.outsiderGuessOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.9,
                  ),
                  itemBuilder: (context, index) {
                    final topic = outcome.outsiderGuessOptions[index];
                    final isSelected = _selectedTopicGuess == topic;

                    return AnimatedScale(
                      scale: isSelected ? 1.02 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: GlowCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedTopicGuess = topic),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                _localizedGuessLabel(session.selectedPackId, topic),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 15,
                                      height: 1.15,
                                    ),
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        BaraButton.primary(
          label: AppLocalizations.of(context).confirm,
          icon: Icons.lightbulb_rounded,
          playSound: false,
          onPressed: _selectedTopicGuess == null
              ? null
              : () {
                  final outsiderId = outsider.id;
                  _outsiderGuessTimer?.cancel();
                  ref.read(gameSessionProvider.notifier).submitOutsiderGuess(_selectedTopicGuess!);
                  final updatedOutcome = ref.read(gameSessionProvider).outcome;
                  if (updatedOutcome?.outsiderGuessResults[outsiderId] == true) {
                    AppAudio.instance.playCorrectGuess();
                  } else {
                    AppAudio.instance.playWrongGuess();
                  }
                  setState(() => _selectedTopicGuess = null);
                },
        ),
      ],
    );
  }

  String _localizedTopic(String packId, String topic) {
    final locale = ref.read(appSettingsProvider).locale;
    return ref.read(topicTranslationsProvider.notifier).localizedTopic(
          packId: packId,
          topic: topic,
          locale: locale,
        );
  }

  String _localizedGuessLabel(String packId, String guessedTopic) {
    final l10n = AppLocalizations.of(context);
    if (guessedTopic == 'انتهى الوقت') {
      return l10n.timeUp;
    }
    return _localizedTopic(packId, guessedTopic);
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
      ...?session.outcome?.outsiderGuesses.values,
    }..remove('انتهى الوقت');

    if (topics.isEmpty) {
      return;
    }

    Future<void>.microtask(
      () => ref.read(topicTranslationsProvider.notifier).ensureTopicsTranslated(
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
    if (_armedOutsiderGuessIndex == session.outsiderGuessIndex || outsider == null) {
      return;
    }

    _armedOutsiderGuessIndex = session.outsiderGuessIndex;
    _outsiderRemainingSeconds = _outsiderGuessSeconds;
    _outsiderGuessTimer?.cancel();
    _outsiderGuessTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _outsiderRemainingSeconds ?? _outsiderGuessSeconds;
      if (remaining <= 1) {
        timer.cancel();
        _outsiderGuessTimer = null;
        final expiredOutsider = ref.read(gameSessionProvider).currentOutsiderGuesser;
        ref.read(gameSessionProvider.notifier).submitOutsiderGuess('انتهى الوقت');
        AppAudio.instance.playWrongGuess();
        setState(() {
          _outsiderRemainingSeconds = 0;
          _selectedTopicGuess = null;
        });
        if (expiredOutsider == null) {
          _armedOutsiderGuessIndex = null;
        }
        return;
      }

      setState(() {
        _outsiderRemainingSeconds = remaining - 1;
      });
    });
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
          Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.primary),
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

class _SuspenseDotsState extends State<_SuspenseDots> with SingleTickerProviderStateMixin {
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.35 + (offset * 0.65)),
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
