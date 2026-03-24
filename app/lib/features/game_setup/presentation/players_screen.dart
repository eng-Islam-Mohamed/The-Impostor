import 'package:bara_alsalfa/core/i18n/game_text.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/categories_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  static const routePath = '/setup/players';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final mode = session.selectedMode;
    final l10n = AppLocalizations.of(context);
    final playerCountIsValid =
        session.players.length >= mode.minPlayers && session.players.length <= mode.maxPlayers;
    final maxOutsiders = maxOutsidersForPlayerCount(session.players.length);

    warmUiPhrases(
      ref,
      const [
        'العدد المناسب لـ',
        'برا السالفة الحالي',
        'من أصل',
        'متاح',
        'خلط',
        'اضغط على الصورة لتبديل الهوية البصرية.',
        'عدد برا السالفة',
        'يزيد تلقائيًا عندما يصبح عدد اللاعبين أكبر.',
        'يمكنك الآن اختيار حتى',
        'من برا السالفة.',
        'هذا الوضع يحتاج بين',
        'لاعبين.',
        'التالي: اختيار الفئة',
        'تعديل الاسم',
        'اكتب اسم اللاعب',
      ],
    );

    return BaraScaffold(
      title: l10n.players,
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizeUiPhrase(ref, 'العدد المناسب لـ')} ${mode.localizedTitle(l10n)}: ${mode.playerRange}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${localizeUiPhrase(ref, 'برا السالفة الحالي')}: ${session.outsiderCount} '
                        '${localizeUiPhrase(ref, 'من أصل')} $maxOutsiders ${localizeUiPhrase(ref, 'متاح')}',
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(gameSessionProvider.notifier).shufflePlayers(),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: Text(localizeUiPhrase(ref, 'خلط')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...session.players.map(
            (player) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(gameSessionProvider.notifier).cycleAvatar(player.id),
                      child: PlayerAvatar(
                        index: player.avatarIndex,
                        label: '${player.avatarIndex + 1}',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(player.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(localizeUiPhrase(ref, 'اضغط على الصورة لتبديل الهوية البصرية.')),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showRenameDialog(context, ref, player.id, player.name),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(gameSessionProvider.notifier).removePlayer(player.id),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BaraButton.secondary(
            label: l10n.addPlayer,
            icon: Icons.person_add_alt_1_rounded,
            onPressed: session.players.length < mode.maxPlayers
                ? () => ref.read(gameSessionProvider.notifier).addPlayer()
                : null,
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizeUiPhrase(ref, 'عدد برا السالفة'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  maxOutsiders == 1
                      ? localizeUiPhrase(ref, 'يزيد تلقائيًا عندما يصبح عدد اللاعبين أكبر.')
                      : '${localizeUiPhrase(ref, 'يمكنك الآن اختيار حتى')} '
                          '$maxOutsiders ${localizeUiPhrase(ref, 'من برا السالفة.')}',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(maxOutsiders, (index) {
                    final value = index + 1;
                    return ChoiceChip(
                      label: Text('$value'),
                      selected: session.outsiderCount == value,
                      onSelected: (_) =>
                          ref.read(gameSessionProvider.notifier).setOutsiderCount(value),
                    );
                  }),
                ),
              ],
            ),
          ),
          if (!playerCountIsValid) ...[
            const SizedBox(height: 12),
            Text(
              '${localizeUiPhrase(ref, 'هذا الوضع يحتاج بين')} '
              '${mode.minPlayers} ${localizeUiPhrase(ref, 'و')} ${mode.maxPlayers} '
              '${localizeUiPhrase(ref, 'لاعبين.')}',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 24),
          BaraButton.primary(
            label: localizeUiPhrase(ref, 'التالي: اختيار الفئة'),
            icon: Icons.arrow_back_rounded,
            onPressed: playerCountIsValid ? () => context.push(CategoriesScreen.routePath) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String playerId,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizeUiPhrase(ref, 'تعديل الاسم')),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: localizeUiPhrase(ref, 'اكتب اسم اللاعب'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: () {
                ref.read(gameSessionProvider.notifier).updatePlayerName(playerId, controller.text);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).save),
            ),
          ],
        );
      },
    );
  }
}
