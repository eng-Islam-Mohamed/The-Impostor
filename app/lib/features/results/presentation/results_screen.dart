import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/round_outcome.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/categories_screen.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
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
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    final topicLocalizer = ref.read(topicTranslationsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    if (outcome == null) {
      return BaraScaffold(
        title: l10n.results,
        showBackButton: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BaraButton.primary(
              label: l10n.backToHome,
              icon: Icons.home_rounded,
              onPressed: () => context.go(HomeScreen.routePath),
            ),
          ),
        ),
      );
    }

    final outsiderPlayers = session.outsiderPlayers;
    final outsiderNames = outsiderPlayers.map((player) => player.name).join('، ');
    warmUiPhrases(
      ref,
      [
        outcome.recapLine,
        'برا السالفة هم',
        'برا السالفة هو',
        'تم كشف كل برا السالفة في التصويت',
        'تم كشف بعض برا السالفة في التصويت',
        'لم يتم كشفهم في التصويت الأول',
        'التحدي الأخير',
        'لم يتم',
        'السالفة كانت',
        'لوحة النقاط',
      ],
    );
    _warmResultTranslations(
      packId: session.selectedPackId,
      outcome: outcome,
      locale: settings.locale,
      topicLocalizer: topicLocalizer,
    );

    String localizeTopic(String topic) {
      return topicLocalizer.localizedTopic(
        packId: session.selectedPackId,
        topic: topic,
        locale: settings.locale,
      );
    }

    final allOutsidersCaught = outcome.survivingOutsiderIds.isEmpty;
    final someOutsidersCaught = outcome.outsiderCaught && !allOutsidersCaught;

    return BaraScaffold(
      title: l10n.results,
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: outsiderPlayers
                      .map(
                        (player) => PlayerAvatar(
                          index: player.avatarIndex,
                          label: '${player.avatarIndex + 1}',
                          radius: 28,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  outsiderPlayers.length > 1
                      ? '${localizeUiPhrase(ref, 'برا السالفة هم')} $outsiderNames'
                      : '${localizeUiPhrase(ref, 'برا السالفة هو')} $outsiderNames',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  allOutsidersCaught
                      ? localizeUiPhrase(ref, 'تم كشف كل برا السالفة في التصويت')
                      : someOutsidersCaught
                          ? localizeUiPhrase(ref, 'تم كشف بعض برا السالفة في التصويت')
                          : localizeUiPhrase(ref, 'لم يتم كشفهم في التصويت الأول'),
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
                Text(
                  localizeUiPhrase(ref, 'التحدي الأخير'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...outsiderPlayers.map(
                  (outsider) {
                    final rawGuess = outcome.outsiderGuesses[outsider.id];
                    final guess = rawGuess == null
                        ? localizeUiPhrase(ref, 'لم يتم')
                        : rawGuess == 'انتهى الوقت'
                            ? l10n.timeUp
                            : localizeTopic(rawGuess);
                    final isCorrect = outcome.outsiderGuessResults[outsider.id] ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${outsider.name}: $guess'),
                          ),
                          Text(
                            isCorrect ? '+1' : '-1',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isCorrect
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  localizeUiPhrase(ref, 'السالفة كانت'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  localizeTopic(outcome.topic),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Text(localizeUiPhrase(ref, outcome.recapLine)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeUiPhrase(ref, 'لوحة النقاط'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                          _formatDelta(outcome.scoreDeltas[player.id] ?? 0),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: (outcome.scoreDeltas[player.id] ?? 0) >= 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
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
            label: l10n.playAgain,
            icon: Icons.replay_rounded,
            onPressed: () async {
              await ref.read(gameSessionProvider.notifier).playAgain();
              if (!context.mounted) {
                return;
              }
              context.go(RoundScreen.routePath);
            },
          ),
          const SizedBox(height: 12),
          BaraButton.secondary(
            label: l10n.selectCategories,
            icon: Icons.category_rounded,
            onPressed: () => context.go(CategoriesScreen.routePath),
          ),
          const SizedBox(height: 12),
          BaraButton.secondary(
            label: l10n.backToHome,
            icon: Icons.home_rounded,
            onPressed: () => context.go(HomeScreen.routePath),
          ),
        ],
      ),
    );
  }

  String _formatDelta(int value) {
    if (value > 0) {
      return '+$value';
    }
    return '$value';
  }

  void _warmResultTranslations({
    required String packId,
    required RoundOutcome outcome,
    required SupportedLocale locale,
    required TopicTranslationsController topicLocalizer,
  }) {
    if (locale == SupportedLocale.arabic) {
      return;
    }

    final topics = <String>{
      outcome.topic,
      ...outcome.outsiderGuessOptions,
      ...outcome.outsiderGuesses.values,
    }..remove('انتهى الوقت');

    Future<void>.microtask(
      () => topicLocalizer.ensureTopicsTranslated(
            packId: packId,
            topics: topics,
          ),
    );
  }
}
