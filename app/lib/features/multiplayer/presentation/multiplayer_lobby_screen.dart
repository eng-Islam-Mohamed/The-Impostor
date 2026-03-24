import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_room_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_hub_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MultiplayerLobbyScreen extends ConsumerWidget {
  const MultiplayerLobbyScreen({super.key});

  static const routePath = '/multiplayer/lobby';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(multiplayerRoomProvider);
    final room = roomAsync.asData?.value;

    warmUiPhrases(
      ref,
      [
        'الردهة',
        'العودة للغرف الأونلاين',
        'ردهة الغرفة',
        'الكود',
        'رابط الدعوة',
        'اللاعبون',
        'جاهز',
        'بانتظار',
        'ما يختبره هذا النموذج',
        'الجاهزية لكل لاعب من هاتفه',
        'صلاحيات المضيف',
        'الانتقال من الردهة إلى الجولة مع معلومات خاصة لكل لاعب',
        'إلغاء الجاهزية',
        'أنا جاهز',
        'ملء الغرفة بلاعبين تجريبيين',
        'ابدأ الجولة الحية',
        'غادر الغرفة',
        'جاري إعداد الردهة',
        'Host',
        if (room != null) room.systemMessage,
      ],
    );

    return roomAsync.when(
      data: (room) {
        if (room == null) {
          return BaraScaffold(
            title: localizeUiPhrase(ref, 'الردهة'),
            showBackButton: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BaraButton.primary(
                  label: localizeUiPhrase(ref, 'العودة للغرف الأونلاين'),
                  icon: Icons.home_rounded,
                  onPressed: () => context.go(MultiplayerHubScreen.routePath),
                ),
              ),
            ),
          );
        }

        final currentPlayer = room.currentPlayer;

        return BaraScaffold(
          title: localizeUiPhrase(ref, 'ردهة الغرفة'),
          showBackButton: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            children: [
              GlowCard(
                isSelected: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizeUiPhrase(ref, 'الكود')} ${room.roomCode}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(localizeUiPhrase(ref, room.systemMessage)),
                    const SizedBox(height: 8),
                    Text('${localizeUiPhrase(ref, 'رابط الدعوة')}: ${room.shareLink}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizeUiPhrase(ref, 'اللاعبون'),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    ...room.players.map(
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
                            if (player.isHost)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Chip(label: Text(localizeUiPhrase(ref, 'Host'))),
                              ),
                            Chip(
                              label: Text(
                                player.isReady
                                    ? localizeUiPhrase(ref, 'جاهز')
                                    : localizeUiPhrase(ref, 'بانتظار'),
                              ),
                            ),
                          ],
                        ),
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
                    Text(localizeUiPhrase(ref, 'ما يختبره هذا النموذج')),
                    const SizedBox(height: 10),
                    Text('• ${localizeUiPhrase(ref, 'الجاهزية لكل لاعب من هاتفه')}'),
                    const SizedBox(height: 6),
                    Text('• ${localizeUiPhrase(ref, 'صلاحيات المضيف')}'),
                    const SizedBox(height: 6),
                    Text('• ${localizeUiPhrase(ref, 'الانتقال من الردهة إلى الجولة مع معلومات خاصة لكل لاعب')}'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              BaraButton.secondary(
                label: currentPlayer?.isReady == true
                    ? localizeUiPhrase(ref, 'إلغاء الجاهزية')
                    : localizeUiPhrase(ref, 'أنا جاهز'),
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => ref.read(multiplayerRoomProvider.notifier).toggleReady(),
              ),
              if (room.isCurrentPlayerHost) ...[
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: localizeUiPhrase(ref, 'ملء الغرفة بلاعبين تجريبيين'),
                  icon: Icons.group_add_rounded,
                  onPressed: room.players.length >= 4
                      ? null
                      : () => ref.read(multiplayerRoomProvider.notifier).seedDemoPlayers(),
                ),
                const SizedBox(height: 12),
                BaraButton.primary(
                  label: localizeUiPhrase(ref, 'ابدأ الجولة الحية'),
                  icon: Icons.play_arrow_rounded,
                  onPressed: room.canStart
                      ? () async {
                          await ref.read(multiplayerRoomProvider.notifier).startGame();
                          if (!context.mounted) {
                            return;
                          }
                          context.go(MultiplayerRoomScreen.routePath);
                        }
                      : null,
                ),
              ],
              const SizedBox(height: 12),
              BaraButton.secondary(
                label: localizeUiPhrase(ref, 'غادر الغرفة'),
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(multiplayerRoomProvider.notifier).leaveRoom();
                  if (!context.mounted) {
                    return;
                  }
                  context.go(MultiplayerHubScreen.routePath);
                },
              ),
            ],
          ),
        );
      },
      loading: () => _MultiplayerLoadingScreen(title: localizeUiPhrase(ref, 'جاري إعداد الردهة')),
      error: (error, _) => BaraScaffold(
        title: localizeUiPhrase(ref, 'الردهة'),
        showBackButton: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(localizeUiPhrase(ref, '$error')),
          ),
        ),
      ),
    );
  }
}

class _MultiplayerLoadingScreen extends StatelessWidget {
  const _MultiplayerLoadingScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BaraScaffold(
      title: title,
      showBackButton: true,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
