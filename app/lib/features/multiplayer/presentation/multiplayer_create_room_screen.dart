import 'package:bara_alsalfa/core/i18n/game_text.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_room_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_lobby_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MultiplayerCreateRoomScreen extends ConsumerStatefulWidget {
  const MultiplayerCreateRoomScreen({super.key});

  static const routePath = '/multiplayer/create';

  @override
  ConsumerState<MultiplayerCreateRoomScreen> createState() =>
      _MultiplayerCreateRoomScreenState();
}

class _MultiplayerCreateRoomScreenState
    extends ConsumerState<MultiplayerCreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  GameMode _mode = GameMode.classic;
  MultiplayerRoomVisibility _visibility = MultiplayerRoomVisibility.privateRoom;
  int _avatarIndex = 0;
  int _maxPlayers = 8;
  int _outsiderCount = 1;
  String? _packId;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Host';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packs = ref.watch(categoryLibraryProvider);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final selectedPackId = _packId ?? packs.first.id;

    warmUiPhrases(ref, const [
      'إنشاء غرفة أونلاين',
      'اسمك داخل الغرفة',
      'الوضع',
      'الفئة',
      'الخصوصية',
      'خاصة',
      'عامة',
      'أقصى عدد لاعبين',
      'عدد برا السالفة',
      'الأفاتار',
      'رقم',
      'أنشئ الغرفة وانتقل للردهة',
      'المضيف',
    ]);

    return BaraScaffold(
      title: localizeUiPhrase(ref, 'إنشاء غرفة أونلاين'),
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizeUiPhrase(ref, 'اسمك داخل الغرفة'),
                  ),
                ),
                const SizedBox(height: 18),
                Text(localizeUiPhrase(ref, 'الوضع'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: GameMode.values.take(2).map((mode) {
                    return ChoiceChip(
                      label: Text(mode.localizedTitle(l10n)),
                      selected: _mode == mode,
                      onSelected: (_) {
                        setState(() {
                          _mode = mode;
                          _maxPlayers = _maxPlayers.clamp(mode.minPlayers, 10);
                          _outsiderCount = _outsiderCount.clamp(
                            1,
                            multiplayerMaxOutsidersForPlayerCount(_maxPlayers),
                          );
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(localizeUiPhrase(ref, 'الفئة'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: packs.map((pack) {
                    return ChoiceChip(
                      label: Text(localizedPackTitle(pack, settings.locale)),
                      selected: selectedPackId == pack.id,
                      onSelected: (_) => setState(() => _packId = pack.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text(localizeUiPhrase(ref, 'الخصوصية'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: MultiplayerRoomVisibility.values.map((visibility) {
                    final label = visibility == MultiplayerRoomVisibility.privateRoom
                        ? localizeUiPhrase(ref, 'خاصة')
                        : localizeUiPhrase(ref, 'عامة');
                    return ChoiceChip(
                      label: Text(label),
                      selected: _visibility == visibility,
                      onSelected: (_) => setState(() => _visibility = visibility),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Text('${localizeUiPhrase(ref, 'أقصى عدد لاعبين')}: $_maxPlayers'),
                Slider(
                  value: _maxPlayers.toDouble(),
                  min: _mode.minPlayers.toDouble(),
                  max: 10,
                  divisions: 10 - _mode.minPlayers,
                  onChanged: (value) => setState(() {
                    _maxPlayers = value.round();
                    _outsiderCount = _outsiderCount.clamp(
                      1,
                      multiplayerMaxOutsidersForPlayerCount(_maxPlayers),
                    );
                  }),
                ),
                const SizedBox(height: 18),
                Text(localizeUiPhrase(ref, 'عدد برا السالفة'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                    multiplayerMaxOutsidersForPlayerCount(_maxPlayers),
                    (index) {
                      final count = index + 1;
                      return ChoiceChip(
                        label: Text('$count'),
                        selected: _outsiderCount == count,
                        onSelected: (_) => setState(() => _outsiderCount = count),
                      );
                    },
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
                Text(localizeUiPhrase(ref, 'الأفاتار'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
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
          const SizedBox(height: 22),
          BaraButton.primary(
            label: localizeUiPhrase(ref, 'أنشئ الغرفة وانتقل للردهة'),
            icon: Icons.arrow_back_rounded,
            onPressed: () async {
              await ref
                  .read(multiplayerClientConfigProvider.notifier)
                  .setUseLiveServer(true);
              await ref.read(multiplayerRoomProvider.notifier).createRoom(
                    displayName: _nameController.text.trim().isEmpty
                        ? localizeUiPhrase(ref, 'المضيف')
                        : _nameController.text.trim(),
                    avatarIndex: _avatarIndex,
                    modeSlug: _mode.slug,
                    packId: selectedPackId,
                    topicPool: packs.firstWhere((pack) => pack.id == selectedPackId).topics,
                    visibility: _visibility,
                    maxPlayers: _maxPlayers,
                    outsiderCount: _outsiderCount,
                  );
              if (!context.mounted) {
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
