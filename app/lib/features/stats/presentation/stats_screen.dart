import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const routePath = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(gameSessionProvider).players;

    return BaraScaffold(
      title: 'الإحصائيات',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أفضل اللاعبين الليلة', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ...players.map(
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
                        Text('${player.score}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Best moments'),
                SizedBox(height: 10),
                Text('سيتم هنا لاحقًا حفظ أفضل الخدع، أطول نقاش، وأكثر لاعب مثير للشك.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
