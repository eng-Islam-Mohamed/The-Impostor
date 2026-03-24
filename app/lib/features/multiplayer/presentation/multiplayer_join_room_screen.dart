import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_room_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MultiplayerJoinRoomScreen extends ConsumerStatefulWidget {
  const MultiplayerJoinRoomScreen({super.key});

  static const routePath = '/multiplayer/join';

  @override
  ConsumerState<MultiplayerJoinRoomScreen> createState() =>
      _MultiplayerJoinRoomScreenState();
}

class _MultiplayerJoinRoomScreenState
    extends ConsumerState<MultiplayerJoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int _avatarIndex = 4;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Player';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(multiplayerRoomProvider);
    warmUiPhrases(ref, const [
      'الانضمام إلى غرفة',
      'رمز الغرفة',
      'اسمك',
      'رقم',
      'انضم الآن',
      'لاعب جديد',
      'Room not found',
      'Bad state: Room not found.',
    ]);

    return BaraScaffold(
      title: localizeUiPhrase(ref, 'الانضمام إلى غرفة'),
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: localizeUiPhrase(ref, 'رمز الغرفة'),
                    hintText: 'K7M4QX',
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizeUiPhrase(ref, 'اسمك'),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(8, (index) {
                    return ChoiceChip(
                      label: Text('${localizeUiPhrase(ref, 'رقم')} ${index + 1}'),
                      selected: _avatarIndex == index,
                      onSelected: (_) => setState(() => _avatarIndex = index),
                    );
                  }),
                ),
              ],
            ),
          ),
          if (roomState.hasError) ...[
            const SizedBox(height: 16),
            GlowCard(
              child: Text(localizeUiPhrase(ref, '${roomState.error}')),
            ),
          ],
          const SizedBox(height: 22),
          BaraButton.primary(
            label: localizeUiPhrase(ref, 'انضم الآن'),
            icon: Icons.arrow_back_rounded,
            onPressed: () async {
              await ref
                  .read(multiplayerClientConfigProvider.notifier)
                  .setUseLiveServer(true);
              await ref.read(multiplayerRoomProvider.notifier).joinRoom(
                    roomCode: _codeController.text.trim(),
                    displayName: _nameController.text.trim().isEmpty
                        ? localizeUiPhrase(ref, 'لاعب جديد')
                        : _nameController.text.trim(),
                    avatarIndex: _avatarIndex,
                  );
              final state = ref.read(multiplayerRoomProvider);
              if (!context.mounted || state.hasError) {
                return;
              }
              context.go(MultiplayerLobbyScreen.routePath);
            },
          ),
        ],
      ),
    );
  }
}
