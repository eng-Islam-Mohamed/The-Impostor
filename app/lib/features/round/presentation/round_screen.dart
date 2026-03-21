import 'dart:async';

import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/results/presentation/results_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
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
  bool _revealed = false;
  String? _selectedSuspectId;
  Timer? _discussionTimer;
  int? _remainingSeconds;
  bool _timerStarted = false;

  @override
  void dispose() {
    _discussionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final settings = ref.watch(appSettingsProvider);

    if (!session.hasActiveRound) {
      return BaraScaffold(
        title: 'لا توجد جولة نشطة',
        showBackButton: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: BaraButton.primary(
              label: 'العودة للرئيسية',
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
      title: 'الجولة ${session.roundNumber}',
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
                'مرر الجوال إلى ${assignment.playerName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text('اضغط مطولًا على البطاقة حتى يظهر الدور بشكل خاص.'),
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
          onLongPressEnd: (_) {},
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
                  _revealed ? 'دورك الآن' : 'اضغط مطولًا للكشف',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _revealed ? Colors.white : null,
                      ),
                ),
                const SizedBox(height: 22),
                Text(
                  _revealed
                      ? assignment.isOutsider
                          ? 'أنت برا السالفة'
                          : assignment.topic
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
                          ? 'اسمع التلميحات واندمج بدون ما تنكشف.'
                          : 'احتفظ بالكلمة لنفسك ولا تذكرها حرفيًا.'
                      : 'امسك الجهاز قريبًا منك فقط.',
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
          label: session.revealIndex == session.assignments.length - 1 ? 'ابدأ التلميحات' : 'التالي',
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
    final progress = '${session.clueIndex + 1}/${session.players.length}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            children: [
              Text('دور ${player?.name ?? ''}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              const Text(
                'قل تلميحًا قصيرًا أو إجابة ذكية بدون ذكر الكلمة نفسها.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Chip(label: Text('التقدّم $progress')),
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
        BaraButton.primary(
          label: session.clueIndex == session.players.length - 1 ? 'ابدأ النقاش' : 'تم',
          icon: Icons.check_rounded,
          onPressed: () => ref.read(gameSessionProvider.notifier).advanceClueTurn(),
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
              Text('وقت النقاش', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              const Text('ناقشوا بحرية: من يبدو خارج الموضوع؟'),
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
                    const Text('ثانية'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: BaraButton.secondary(
                      label: _timerStarted ? 'إيقاف' : 'ابدأ المؤقت',
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
                      label: 'ابدأ التصويت',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowCard(
          child: Column(
            children: [
              Text(
                'مرّر الجوال إلى ${voter?.name ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text('اختر من تظنه برا السالفة ثم أكّد التصويت.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: session.players.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final player = session.players[index];
            final isSelected = _selectedSuspectId == player.id;
            return GlowCard(
              isSelected: isSelected,
              onTap: () => setState(() => _selectedSuspectId = player.id),
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
          label: 'تأكيد التصويت',
          icon: Icons.check_circle_rounded,
          onPressed: _selectedSuspectId == null
              ? null
              : () {
                  ref.read(gameSessionProvider.notifier).submitVote(_selectedSuspectId!);
                  setState(() => _selectedSuspectId = null);
                  final updated = ref.read(gameSessionProvider);
                  if (updated.phase == RoundPhase.results) {
                    context.go(ResultsScreen.routePath);
                  }
                },
        ),
      ],
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
}

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({required this.phase});

  final RoundPhase phase;

  @override
  Widget build(BuildContext context) {
    final labels = {
      RoundPhase.reveal: 'كشف الأدوار',
      RoundPhase.clueTurns: 'جولة التلميحات',
      RoundPhase.discussion: 'نقاش مفتوح',
      RoundPhase.voting: 'التصويت',
      RoundPhase.results: 'النتيجة',
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
