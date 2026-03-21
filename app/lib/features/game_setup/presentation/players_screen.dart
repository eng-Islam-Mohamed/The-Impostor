import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/categories_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
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
    final playerCountIsValid =
        session.players.length >= mode.minPlayers && session.players.length <= mode.maxPlayers;

    return BaraScaffold(
      title: 'اللاعبون',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'العدد المناسب لـ ${mode.title}: ${mode.playerRange}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(gameSessionProvider.notifier).shufflePlayers(),
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('خلط'),
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
                          Text('اضغط على الصورة لتبديل الهوية البصرية.'),
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
            label: 'إضافة لاعب',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: session.players.length < mode.maxPlayers
                ? () => ref.read(gameSessionProvider.notifier).addPlayer()
                : null,
          ),
          if (!playerCountIsValid) ...[
            const SizedBox(height: 12),
            Text(
              'هذا الوضع يحتاج بين ${mode.minPlayers} و${mode.maxPlayers} لاعبين.',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
          const SizedBox(height: 24),
          BaraButton.primary(
            label: 'التالي: اختيار الفئة',
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
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'اكتب اسم اللاعب',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(gameSessionProvider.notifier).updatePlayerName(playerId, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
