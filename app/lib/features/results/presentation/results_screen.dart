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

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key, this.initialScrollToScoreboard = false});

  final bool initialScrollToScoreboard;
  static const routePath = '/results';

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialScrollToScoreboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final outsiderNames = outsiderPlayers
        .map((player) => player.name)
        .join('، ');
    warmUiPhrases(ref, [
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
      'من',
      'إلى',
      'الرصيد قبل الجولة',
      'تغيير الجولة',
      'الرصيد الجديد',
      'نتيجة التصويت الصحيحة',
      'نتيجة التصويت الخاطئة',
      'نتيجة التصويت',
      'تأثير المهارات',
      'نتيجة تخمين برا السالفة الصحيح',
      'نتيجة تخمين برا السالفة الخاطئ',
    ]);
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
        controller: _scrollController,
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
                      ? localizeUiPhrase(
                          ref,
                          'تم كشف كل برا السالفة في التصويت',
                        )
                      : someOutsidersCaught
                      ? localizeUiPhrase(
                          ref,
                          'تم كشف بعض برا السالفة في التصويت',
                        )
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
                ...outsiderPlayers.map((outsider) {
                  final rawGuess = outcome.outsiderGuesses[outsider.id];
                  final guess = rawGuess == null
                      ? localizeUiPhrase(ref, 'لم يتم')
                      : rawGuess == 'انتهى الوقت'
                      ? l10n.timeUp
                      : localizeTopic(rawGuess);
                  final isCorrect =
                      outcome.outsiderGuessResults[outsider.id] ?? false;
                  final guessDelta =
                      outcome.scoreLedger[outsider.id]
                          ?.where(
                            (entry) =>
                                entry.label.contains('تخمين برا السالفة'),
                          )
                          .fold<int>(0, (sum, entry) => sum + entry.delta) ??
                      (isCorrect ? 1 : -1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text('${outsider.name}: $guess')),
                        Text(
                          _formatDelta(guessDelta),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isCorrect
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
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
          if (outcome.powerEvents.isNotEmpty) ...[
            const SizedBox(height: 16),
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.flash_on_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizeUiPhrase(ref, 'أحداث المهارات التكتيكية'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...outcome.powerEvents.map(
                    (event) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        event,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                ...session.players.map((player) {
                  final delta = outcome.scoreDeltas[player.id] ?? 0;
                  final ledger = outcome.scoreLedger[player.id] ?? const [];
                  final startingScore = player.score - delta;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      leading: PlayerAvatar(
                        index: player.avatarIndex,
                        label: '${player.avatarIndex + 1}',
                        radius: 18,
                      ),
                      title: Text(player.name),
                      subtitle: Text(
                        '${localizeUiPhrase(ref, 'من')} $startingScore '
                        '${localizeUiPhrase(ref, 'إلى')} ${player.score}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        _formatDelta(delta),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: delta >= 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        const Divider(height: 20),
                        _ScoreLine(
                          label: localizeUiPhrase(ref, 'الرصيد قبل الجولة'),
                          value: '$startingScore',
                        ),
                        ...ledger.map(
                          (entry) => _ScoreLine(
                            label: localizeUiPhrase(ref, entry.label),
                            value: _formatDelta(entry.delta),
                            valueColor: entry.delta >= 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const Divider(height: 20),
                        _ScoreLine(
                          label: localizeUiPhrase(ref, 'تغيير الجولة'),
                          value: _formatDelta(delta),
                          emphasize: true,
                        ),
                        _ScoreLine(
                          label: localizeUiPhrase(ref, 'الرصيد الجديد'),
                          value: '${player.score}',
                          emphasize: true,
                        ),
                      ],
                    ),
                  );
                }),
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
      ...outcome.outsiderGuessOptionsByPlayer.values.expand(
        (options) => options,
      ),
      ...outcome.outsiderGuesses.values,
    }..remove('انتهى الوقت');

    Future<void>.microtask(
      () =>
          topicLocalizer.ensureTopicsTranslated(packId: packId, topics: topics),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: style?.copyWith(
              color: valueColor,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
