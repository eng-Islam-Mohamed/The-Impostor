import 'package:bara_alsalfa/core/i18n/game_text.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/manage_subjects_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const routePath = '/setup/categories';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final packs = ref.watch(categoryLibraryProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    final topicLocalizer = ref.read(topicTranslationsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    warmUiPhrases(ref, const [
      'اختر نوع السوالف الذي ستُسحب منه كلمة الجولة.',
      'أمثلة:',
    ]);

    return BaraScaffold(
      title: l10n.selectCategories,
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            localizeUiPhrase(ref, 'اختر نوع السوالف الذي ستُسحب منه كلمة الجولة.'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          BaraButton.secondary(
            label: l10n.manageStories,
            icon: Icons.edit_note_rounded,
            onPressed: () => context.push(ManageSubjectsScreen.routePath),
          ),
          const SizedBox(height: 16),
          ...packs.map(
            (pack) {
              final examples = pack.topics.take(4).map((topic) {
                return topicLocalizer.localizedTopic(
                  packId: pack.id,
                  topic: topic,
                  locale: settings.locale,
                );
              }).join(' • ');

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlowCard(
                  isSelected: session.selectedPackId == pack.id,
                  onTap: () => ref.read(gameSessionProvider.notifier).selectPack(pack.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              pack.isPremium
                                  ? l10n.premium
                                  : localizedDifficultyLabel(pack, settings.locale),
                            ),
                          ),
                          const Spacer(),
                          Text(l10n.storyCount(pack.topics.length)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        localizedPackTitle(pack, settings.locale),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(localizedPackSubtitle(pack, settings.locale)),
                      const SizedBox(height: 12),
                      Text(
                        '${localizeUiPhrase(ref, 'أمثلة:')} $examples',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          BaraButton.primary(
            label: l10n.startRound,
            icon: Icons.arrow_back_rounded,
            onPressed: () async {
              await ref.read(gameSessionProvider.notifier).startRound();
              if (!context.mounted) {
                return;
              }
              context.go(RoundScreen.routePath);
            },
          ),
        ],
      ),
    );
  }
}
