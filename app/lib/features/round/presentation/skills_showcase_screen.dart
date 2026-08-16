import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/player_profile.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/domain/models/round_phase.dart';
import 'package:bara_alsalfa/domain/models/secret_assignment.dart';
import 'package:bara_alsalfa/features/results/presentation/results_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SkillsShowcaseScreen extends ConsumerWidget {
  const SkillsShowcaseScreen({super.key, this.skillKey});

  final String? skillKey;
  static const routePath = '/skills-showcase';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (skillKey != null) {
      switch (skillKey) {
        case 'alliance':
          _setupReveal(
            ref: ref,
            cardPayload: '${PowerCardCatalog.tacticalAlliance}:p2',
            isOutsider: false,
            topic: 'طارق بن زياد',
          );
          return const RoundScreen(initialRevealed: true);

        case 'high-stakes':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.highStakes,
            isOutsider: false,
            topic: 'هارون الرشيد',
          );
          return const RoundScreen(initialRevealed: true);

        case 'diplomatic-immunity':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.diplomaticImmunity,
            isOutsider: false,
            topic: 'سيف الدين قطز',
          );
          return const RoundScreen(initialRevealed: true);

        case 'robin-hood':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.robinHood,
            isOutsider: false,
            topic: 'عمر المختار',
          );
          return const RoundScreen(initialRevealed: true);

        case 'choices-focus':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.outsiderChoicesFocus,
            isOutsider: true,
            topic: 'ابن سينا',
          );
          return const RoundScreen(initialRevealed: true);

        case 'choices-guess':
          _setupOutsider7ChoicesGuess(ref: ref);
          return const RoundScreen();

        case 'jackpot':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.jackpot,
            isOutsider: false,
            topic: 'ابن بطوطة',
          );
          return const RoundScreen(initialRevealed: true);

        case 'drain':
          _setupReveal(
            ref: ref,
            cardPayload: '${PowerCardCatalog.tacticalDrain}:p2',
            isOutsider: false,
            topic: 'صلاح الدين الأيوبي',
          );
          return const RoundScreen(initialRevealed: true);

        case 'karma':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.karmaBackfire,
            isOutsider: false,
            topic: 'الأهرامات',
          );
          return const RoundScreen(initialRevealed: true);

        case 'double-vote':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.doubleVote,
            isOutsider: false,
            topic: 'قصر الحمراء',
          );
          return const RoundScreen(initialRevealed: true);

        case 'outsider-chance':
          _setupReveal(
            ref: ref,
            cardPayload: PowerCardCatalog.outsiderSecondChance,
            isOutsider: true,
            topic: 'ابن خلدون',
          );
          return const RoundScreen(initialRevealed: true);

        case 'attempt-1':
          _setupOutsiderGuess(ref: ref, attempts: 0, hasSecondChance: true);
          return const RoundScreen();

        case 'attempt-2':
          _setupOutsiderGuess(ref: ref, attempts: 1, hasSecondChance: true);
          return const RoundScreen();

        case 'results':
          _setupResultsWithAllNewEvents(ref: ref);
          return const ResultsScreen();

        case 'scoreboard':
          _setupResultsWithAllNewEvents(ref: ref);
          return const ResultsScreen(initialScrollToScoreboard: true);
      }
    }

    return BaraScaffold(
      title: 'استعراض المهارات التكتيكية',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'اختر مهارة أو مرحلة لمعاينتها مباشرة داخل واجهة اللعبة:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context: context,
            title: '🤝 مهارة التحالف التكتيكي (Tactical Alliance)',
            subtitle:
                'كشف الدور السري مع اختيار الحليف السري (نورة) لكسب +3 نقاط معاً',
            onTap: () => context.push('/skills-showcase/alliance'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🔥 مهارة الرهان العالي (High Stakes)',
            subtitle:
                'كشف الدور السري مع مجازفة +4 نقاط عند الفوز و -4 نقاط عند الخطأ',
            onTap: () => context.push('/skills-showcase/high-stakes'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🛡️ مهارة الحصانة الدبلوماسية (Diplomatic Immunity)',
            subtitle: 'كشف الدور السري مع درع الحماية الكامل من أي خصم نقطي',
            onTap: () => context.push('/skills-showcase/diplomatic-immunity'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🏹 مهارة روبن هود (Robin Hood)',
            subtitle:
                'كشف الدور السري مع سحب نقطتين من متصدر الترتيب ونقلها لصاحب المهارة',
            onTap: () => context.push('/skills-showcase/robin-hood'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🔍 مهارة حصر السبعة خيارات (7-Choices Focus)',
            subtitle:
                'كشف كرت برا السالفة مع ميزة اختصار خيارات التخمين إلى 7 خيارات فقط',
            onTap: () => context.push('/skills-showcase/choices-focus'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🎯 تخمين برا السالفة: تطبيق حصر 7 خيارات',
            subtitle: 'معاينة قائمة التخمين النهائي المحصورة في 7 خيارات فقط',
            onTap: () => context.push('/skills-showcase/choices-guess'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '⚡ مهارة السطو التكتيكي (مجازفة السطو الكاملة)',
            subtitle:
                'كشف الدور السري مع تحديد اسم الضحية (نورة) لسحب رصيدها كاملاً',
            onTap: () => context.push('/skills-showcase/drain'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🎰 مهارة الجاكبوت (Jackpot)',
            subtitle: 'كشف الدور السري مع كرت الجاكبوت لكسب ثروات الجميع',
            onTap: () => context.push('/skills-showcase/jackpot'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🛡️ مهارة الارتداد العكسي (Karma Backfire)',
            subtitle: 'كشف الدور السري مع ميزة خصم النقاط من كل من يتهمك',
            onTap: () => context.push('/skills-showcase/karma'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '✨ مهارة صوتك يحسب بصوتين (Double Vote)',
            subtitle: 'كشف الدور السري مع ميزة مضاعفة النقاط (+2 / -2)',
            onTap: () => context.push('/skills-showcase/double-vote'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🎯 مهارة الفرصة المزدوجة (لبرا السالفة)',
            subtitle:
                'كشف كرت برا السالفة مع محاولتين للتخمين في التحدي الأخير',
            onTap: () => context.push('/skills-showcase/outsider-chance'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'شاشات النتائج والأحداث التكتيكية:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          _buildActionCard(
            context: context,
            title: '📊 شاشة النتائج: تفصيل أحداث كافة المهارات الجديدة',
            subtitle:
                'استعراض أحداث التحالف، الرهان العالي، الحصانة، روبن هود، والسطو التكتيكي',
            onTap: () => context.push('/skills-showcase/results'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context: context,
            title: '🏆 لوحة الصدارة: النقاط التراكمية بعد تطبيق المهارات',
            subtitle:
                'معاينة تصفير رصيد الضحية وسحب نقاط المتصدر وقفزة التحالف',
            onTap: () => context.push('/skills-showcase/scoreboard'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }

  static void _setupReveal({
    required WidgetRef ref,
    required String cardPayload,
    required bool isOutsider,
    required String topic,
  }) {
    final notifier = ref.read(gameSessionProvider.notifier);
    final p1 = const PlayerProfile(
      id: 'p1',
      name: 'أنت (سالم)',
      avatarIndex: 0,
      score: 4,
    );
    final p2 = const PlayerProfile(
      id: 'p2',
      name: 'نورة',
      avatarIndex: 1,
      score: 6,
    );
    final p3 = const PlayerProfile(
      id: 'p3',
      name: 'خالد',
      avatarIndex: 2,
      score: 3,
    );
    final p4 = const PlayerProfile(
      id: 'p4',
      name: 'سارة',
      avatarIndex: 3,
      score: -2,
    );
    final p5 = const PlayerProfile(
      id: 'p5',
      name: 'فيصل',
      avatarIndex: 4,
      score: 1,
    );

    final players = [p1, p2, p3, p4, p5];
    final outsiderIds = isOutsider ? ['p1'] : ['p5'];

    final assignments = [
      SecretAssignment(
        playerId: p1.id,
        playerName: p1.name,
        topic: topic,
        isOutsider: isOutsider,
      ),
      SecretAssignment(
        playerId: p2.id,
        playerName: p2.name,
        topic: topic,
        isOutsider: false,
      ),
      SecretAssignment(
        playerId: p3.id,
        playerName: p3.name,
        topic: topic,
        isOutsider: false,
      ),
      SecretAssignment(
        playerId: p4.id,
        playerName: p4.name,
        topic: topic,
        isOutsider: false,
      ),
      SecretAssignment(
        playerId: p5.id,
        playerName: p5.name,
        topic: topic,
        isOutsider: !isOutsider,
      ),
    ];

    final powerCards = <String, String>{p1.id: cardPayload};

    notifier.setCustomState(
      players: players,
      assignments: assignments,
      currentTopic: topic,
      outsiderIds: outsiderIds,
      powerCards: powerCards,
      phase: RoundPhase.reveal,
      revealIndex: 0,
    );
  }

  static void _setupOutsiderGuess({
    required WidgetRef ref,
    required int attempts,
    required bool hasSecondChance,
  }) {
    final notifier = ref.read(gameSessionProvider.notifier);
    final p1 = const PlayerProfile(
      id: 'p1',
      name: 'سالم',
      avatarIndex: 0,
      score: 5,
    );
    final p2 = const PlayerProfile(
      id: 'p2',
      name: 'نورة',
      avatarIndex: 1,
      score: 2,
    );
    final p3 = const PlayerProfile(
      id: 'p3',
      name: 'خالد (برا السالفة)',
      avatarIndex: 2,
      score: 4,
    );
    final players = [p1, p2, p3];

    final powerCards = <String, String>{
      if (hasSecondChance) p3.id: PowerCardCatalog.outsiderSecondChance,
    };

    final outcome = RoundOutcome(
      outsiderIds: ['p3'],
      survivingOutsiderIds: const [],
      accusedPlayerIds: ['p3'],
      topic: 'صلاح الدين الأيوبي',
      voteCounts: {'p3': 2},
      voteScoreDeltas: {'p1': 1, 'p2': 1, 'p3': 0},
      scoreDeltas: {'p1': 1, 'p2': 1, 'p3': 0},
      outsiderGuessOptions: const [
        'صلاح الدين الأيوبي',
        'قطز',
        'بيبرس',
        'هارون الرشيد',
        'طارق بن زياد',
        'عمر المختار',
        'ابن بطوطة',
      ],
      outsiderCaught: true,
      isTie: false,
      recapLine: 'تم كشف برا السالفة في التصويت الحاسم.',
      powerEvents: const [],
    );

    notifier.setCustomState(
      players: players,
      assignments: const [],
      currentTopic: 'صلاح الدين الأيوبي',
      outsiderIds: ['p3'],
      powerCards: powerCards,
      phase: RoundPhase.outsiderGuess,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: attempts,
      outcome: outcome,
    );
  }

  static void _setupOutsider7ChoicesGuess({required WidgetRef ref}) {
    final notifier = ref.read(gameSessionProvider.notifier);
    final p1 = const PlayerProfile(
      id: 'p1',
      name: 'سالم',
      avatarIndex: 0,
      score: 5,
    );
    final p2 = const PlayerProfile(
      id: 'p2',
      name: 'نورة',
      avatarIndex: 1,
      score: 2,
    );
    final p3 = const PlayerProfile(
      id: 'p3',
      name: 'خالد (برا السالفة)',
      avatarIndex: 2,
      score: 4,
    );
    final players = [p1, p2, p3];

    final powerCards = <String, String>{
      p3.id: PowerCardCatalog.outsiderChoicesFocus,
    };

    final outcome = RoundOutcome(
      outsiderIds: ['p3'],
      survivingOutsiderIds: const [],
      accusedPlayerIds: ['p3'],
      topic: 'ابن سينا',
      voteCounts: {'p3': 2},
      voteScoreDeltas: {'p1': 1, 'p2': 1, 'p3': 0},
      scoreDeltas: {'p1': 1, 'p2': 1, 'p3': 0},
      outsiderGuessOptions: const [
        'ابن سينا',
        'الرازي',
        'ابن النفيس',
        'الخوارزمي',
        'جابر بن حيان',
        'الكندي',
        'البيروني',
      ],
      outsiderCaught: true,
      isTie: false,
      recapLine: 'تم كشف برا السالفة وتطبيق مهارة حصر 7 خيارات ذكية.',
      powerEvents: const [
        '🔍 حصر الخيارات: تم تقليص خيارات التخمين لـ (خالد) إلى 7 خيارات ذكية فقط!',
      ],
    );

    notifier.setCustomState(
      players: players,
      assignments: const [],
      currentTopic: 'ابن سينا',
      outsiderIds: ['p3'],
      powerCards: powerCards,
      phase: RoundPhase.outsiderGuess,
      outsiderGuessIndex: 0,
      outsiderGuessAttempts: 0,
      outcome: outcome,
    );
  }

  static void _setupResultsWithAllNewEvents({required WidgetRef ref}) {
    final notifier = ref.read(gameSessionProvider.notifier);
    final p1 = const PlayerProfile(
      id: 'p1',
      name: 'سالم (التحالف التكتيكي)',
      avatarIndex: 0,
      score: 4,
    );
    final p2 = const PlayerProfile(
      id: 'p2',
      name: 'نورة (حليف سالم)',
      avatarIndex: 1,
      score: 6,
    );
    final p3 = const PlayerProfile(
      id: 'p3',
      name: 'خالد (الرهان العالي)',
      avatarIndex: 2,
      score: 2,
    );
    final p4 = const PlayerProfile(
      id: 'p4',
      name: 'سارة (روبن هود)',
      avatarIndex: 3,
      score: 1,
    );
    final p5 = const PlayerProfile(
      id: 'p5',
      name: 'فيصل (برا السالفة)',
      avatarIndex: 4,
      score: 5,
    );

    final players = [p1, p2, p3, p4, p5];

    final outcome = RoundOutcome(
      outsiderIds: ['p5'],
      survivingOutsiderIds: const [],
      accusedPlayerIds: ['p5'],
      topic: 'صلاح الدين الأيوبي',
      voteCounts: {'p5': 4},
      voteScoreDeltas: {'p1': 1, 'p2': 1, 'p3': 1, 'p4': 1, 'p5': 0},
      scoreDeltas: {
        'p1': 3, // Alliance: +3
        'p2': 1, // Leader: -2 from Robin Hood, +3 from Alliance = net +1
        'p3': 4, // High Stakes: +4
        'p4': 3, // Robin Hood: +1 win + 2 stolen = +3
        'p5': -1, // Outsider loss
      },
      outsiderGuesses: {'p5': 'صلاح الدين الأيوبي'},
      outsiderGuessResults: {'p5': false},
      outsiderGuessOptions: const [
        'صلاح الدين الأيوبي',
        'قطز',
        'بيبرس',
        'هارون الرشيد',
        'طارق بن زياد',
        'عمر المختار',
        'ابن بطوطة',
      ],
      outsiderCaught: true,
      isTie: false,
      recapLine: 'تم كشف برا السالفة وتطبيق كافة المهارات التكتيكية بنجاح!',
      powerEvents: const [
        '🤝 التحالف التكتيكي: نجح تحالف (سالم) و (نورة) في كشف برا السالفة معاً وحصلا على +3 نقاط لكل منهما!',
        '🔥 الرهان العالي: ربح (خالد) الرهان بتصويته الصحيح وحصل على +4 نقاط كاملة!',
        '🏹 روبن هود: صوّتت (سارة) صح وسحبت نقطتين من المتصدرة (نورة) وأضافتهما لرصيدها!',
        '🛡️ الحصانة الدبلوماسية: حمت اللاعب البريء من أي خصم نقطي!',
        '⚡ السطو التكتيكي: نقل رصيد الضحية بالكامل وتصفير رصيدها!',
      ],
    );

    notifier.setCustomState(
      players: players,
      assignments: const [],
      currentTopic: 'صلاح الدين الأيوبي',
      outsiderIds: ['p5'],
      powerCards: {
        'p1': '${PowerCardCatalog.tacticalAlliance}:p2',
        'p3': PowerCardCatalog.highStakes,
        'p4': PowerCardCatalog.robinHood,
      },
      phase: RoundPhase.results,
      outcome: outcome,
    );
  }
}
