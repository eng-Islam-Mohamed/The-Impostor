import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const routePath = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(gameSessionProvider).players;
    final l10n = AppLocalizations.of(context);

    warmUiPhrases(
      ref,
      const [
        'أفضل اللاعبين الليلة',
        'تصفير النقاط',
        'أفضل اللحظات',
        'سيتم هنا لاحقًا حفظ أفضل الخدع، أطول نقاش، وأكثر لاعب مثير للشك.',
      ],
    );

    return BaraScaffold(
      title: l10n.statistics,
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeUiPhrase(ref, 'أفضل اللاعبين الليلة'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                        Text(
                          '${player.score}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                BaraButton.secondary(
                  label: localizeUiPhrase(ref, 'تصفير النقاط'),
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.read(gameSessionProvider.notifier).resetScores(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizeUiPhrase(ref, 'أفضل اللحظات')),
                const SizedBox(height: 10),
                Text(
                  localizeUiPhrase(
                    ref,
                    'سيتم هنا لاحقًا حفظ أفضل الخدع، أطول نقاش، وأكثر لاعب مثير للشك.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
