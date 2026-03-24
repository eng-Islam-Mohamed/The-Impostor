import 'package:bara_alsalfa/core/i18n/game_text.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/manage_subjects_screen.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/setup_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_hub_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/profile_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/stats/presentation/stats_screen.dart';
import 'package:bara_alsalfa/features/store/presentation/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final packs = ref.watch(categoryLibraryProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    warmUiPhrases(ref, const ['غرفة أونلاين']);
    final l10n = AppLocalizations.of(context);

    return BaraScaffold(
      actions: [
        IconButton(
          onPressed: () => ref.read(appSettingsProvider.notifier).toggleThemeMode(),
          icon: Icon(
            settings.themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
        ),
      ],
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              context.push(StoreScreen.routePath);
              break;
            case 2:
              context.push(StatsScreen.routePath);
              break;
            case 3:
              context.push(ProfileScreen.routePath);
              break;
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.auto_awesome_rounded), label: l10n.store),
          NavigationDestination(icon: const Icon(Icons.insights_rounded), label: l10n.statistics),
          NavigationDestination(icon: const Icon(Icons.tune_rounded), label: l10n.settings),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
        children: [
          Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.appTagline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.startYourNight,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.lastSavedSetup(
                    session.selectedMode.localizedTitle(l10n),
                    session.players.length,
                  ),
                ),
                const SizedBox(height: 22),
                BaraButton.primary(
                  label: l10n.startNewGame,
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push(SetupScreen.routePath),
                ),
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: l10n.quickRound,
                  icon: Icons.flash_on_rounded,
                  onPressed: () => context.push('${SetupScreen.routePath}?mode=${GameMode.quick.slug}'),
                ),
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: l10n.manageStories,
                  icon: Icons.edit_note_rounded,
                  onPressed: () => context.push(ManageSubjectsScreen.routePath),
                ),
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: localizeUiPhrase(ref, 'غرفة أونلاين'),
                  icon: Icons.wifi_tethering_rounded,
                  onPressed: () => context.push(MultiplayerHubScreen.routePath),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: l10n.readyModes,
            actionLabel: l10n.viewAll,
          ),
          const SizedBox(height: 12),
          ...GameMode.values.take(3).map(
                (mode) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlowCard(
                    onTap: mode.isMvpAvailable
                        ? () => context.push('${SetupScreen.routePath}?mode=${mode.slug}')
                        : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.localizedTitle(l10n),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(mode.localizedSubtitle(l10n)),
                            ],
                          ),
                        ),
                        Chip(label: Text(mode.isMvpAvailable ? mode.playerRange : l10n.comingSoon)),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 10),
          _SectionHeader(
            title: l10n.featuredCategories,
            actionLabel: l10n.packOfTheDay,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: packs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final pack = packs[index];
                return SizedBox(
                  width: 260,
                  child: GlowCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(
                            pack.isPremium
                                ? l10n.premium
                                : localizedDifficultyLabel(pack, settings.locale),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          localizedPackTitle(pack, settings.locale),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          localizedPackSubtitle(pack, settings.locale),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GlowCard(
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.tonightChallenge, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(l10n.tonightChallengeDesc),
                    ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Text(
          actionLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}
