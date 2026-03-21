import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/categories_screen.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  static const routePath = '/results';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final outcome = session.outcome;

    if (outcome == null) {
      return BaraScaffold(
        title: 'لا توجد نتيجة',
        showBackButton: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BaraButton.primary(
              label: 'العودة للرئيسية',
              icon: Icons.home_rounded,
              onPressed: () => context.go(HomeScreen.routePath),
            ),
          ),
        ),
      );
    }

    final outsider = session.players.firstWhere((player) => player.id == outcome.outsiderId);

    return BaraScaffold(
      title: 'النتيجة',
      actions: [
        IconButton(
          onPressed: () => context.go(HomeScreen.routePath),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              children: [
                PlayerAvatar(
                  index: outsider.avatarIndex,
                  label: '${outsider.avatarIndex + 1}',
                  radius: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  'برا السالفة هو ${outsider.name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  outcome.outsiderCaught ? 'تم كشفه بنجاح' : 'نجا من التصويت',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: outcome.outsiderCaught
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الكلمة كانت', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(outcome.topic, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                Text(outcome.recapLine),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لوحة النقاط', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ...session.players.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        PlayerAvatar(
                          index: player.avatarIndex,
                          label: '${player.avatarIndex + 1}',
                          radius: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(player.name)),
                        Text(
                          '+${outcome.scoreDeltas[player.id] ?? 0}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${player.score}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BaraButton.primary(
            label: 'إعادة اللعب',
            icon: Icons.replay_rounded,
            onPressed: () {
              ref.read(gameSessionProvider.notifier).playAgain();
              context.go(RoundScreen.routePath);
            },
          ),
          const SizedBox(height: 12),
          BaraButton.secondary(
            label: 'تغيير الفئة',
            icon: Icons.category_rounded,
            onPressed: () => context.go(CategoriesScreen.routePath),
          ),
          const SizedBox(height: 12),
          BaraButton.secondary(
            label: 'الرجوع للرئيسية',
            icon: Icons.home_rounded,
            onPressed: () => context.go(HomeScreen.routePath),
          ),
        ],
      ),
    );
  }
}
