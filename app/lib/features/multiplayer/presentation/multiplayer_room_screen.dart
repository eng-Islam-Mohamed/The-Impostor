import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/widgets/player_avatar.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_room_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_hub_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_lobby_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MultiplayerRoomScreen extends ConsumerStatefulWidget {
  const MultiplayerRoomScreen({super.key});

  static const routePath = '/multiplayer/room';

  @override
  ConsumerState<MultiplayerRoomScreen> createState() =>
      _MultiplayerRoomScreenState();
}

class _MultiplayerRoomScreenState extends ConsumerState<MultiplayerRoomScreen> {
  String? _selectedGuess;
  String? _selectedSuspectId;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(multiplayerRoomProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    final room = roomAsync.asData?.value;
    warmUiPhrases(
      ref,
      [
        'الغرفة الحية',
        'العودة إلى مركز الأونلاين',
        'الغرفة',
        'ينتهي الطور تقريبًا عند',
        'غير محدد',
        'عرضك الخاص على هذا الهاتف',
        'اللاعب',
        'دورك: برا السالفة',
        'دورك: داخل السالفة',
        'السالفة',
        'تم تسجيل صوتك.',
        'لم ترسل صوتك بعد.',
        'اللوحة الحية',
        'العودة للردهة',
        'خروج',
        'الردهة',
        'كشف خاص',
        'جولة التلميحات',
        'النقاش',
        'التصويت الخاص',
        'كشف نتائج التصويت',
        'تخمين برا السالفة',
        'النتيجة النهائية',
        'إجراءات الطور',
        'تم إرسال صوتك من هذا الهاتف.',
        'هذا المكان يمثل شاشة التصويت الخاصة بلاعب واحد فقط.',
        'تم إرسال الصوت',
        'إرسال صوتي',
        'أنت وحدك ترى هذه الخيارات على هاتفك.',
        'أرسل التخمين النهائي',
        'الهاتف الخاص ببرا السالفة فقط هو الذي يستقبل شاشة التخمين الآن.',
        'هذا الزر يحاكي انتقال الخادم للمرحلة التالية داخل النموذج.',
        'بانتظار بث الخادم للطور التالي في النسخة الحقيقية.',
        'المرحلة التالية',
        if (room != null) room.round.statusLine,
      ],
    );

    return roomAsync.when(
      data: (room) {
        if (room == null) {
          return BaraScaffold(
            title: localizeUiPhrase(ref, 'الغرفة الحية'),
            showBackButton: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BaraButton.primary(
                  label: localizeUiPhrase(ref, 'العودة إلى مركز الأونلاين'),
                  icon: Icons.home_rounded,
                  onPressed: () => context.go(MultiplayerHubScreen.routePath),
                ),
              ),
            ),
          );
        }

        final currentPlayer = room.currentPlayer;
        final privateView = room.privateView;
        _warmRoomTranslations(room);
        final localizedTopicLabel = privateView.topicLabel == null
            ? null
            : _localizedTopic(
                packId: room.packId,
                topic: privateView.topicLabel!,
                locale: settings.locale,
              );
        final localizedGuessOptions = [
          for (final topic in privateView.guessOptions)
            _localizedTopic(
              packId: room.packId,
              topic: topic,
              locale: settings.locale,
            ),
        ];

        return BaraScaffold(
          title: '${localizeUiPhrase(ref, 'الغرفة')} ${room.roomCode}',
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
                      _phaseLabel(room.round.phase),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(localizeUiPhrase(ref, room.round.statusLine)),
                    const SizedBox(height: 8),
                    Text(
                      '${localizeUiPhrase(ref, 'ينتهي الطور تقريبًا عند')}: '
                      '${room.round.phaseEndsAt ?? localizeUiPhrase(ref, 'غير محدد')}',
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
                      localizeUiPhrase(ref, 'عرضك الخاص على هذا الهاتف'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('${localizeUiPhrase(ref, 'اللاعب')}: ${currentPlayer?.name ?? '---'}'),
                    const SizedBox(height: 8),
                    Text(
                      privateView.isOutsider
                          ? localizeUiPhrase(ref, 'دورك: برا السالفة')
                          : localizeUiPhrase(ref, 'دورك: داخل السالفة'),
                    ),
                    if (privateView.topicLabel != null) ...[
                      const SizedBox(height: 8),
                      Text('${localizeUiPhrase(ref, 'السالفة')}: $localizedTopicLabel'),
                    ],
                    if (room.round.phase == MultiplayerRoomPhase.voting) ...[
                      const SizedBox(height: 8),
                      Text(
                        privateView.voteSubmitted
                            ? localizeUiPhrase(ref, 'تم تسجيل صوتك.')
                            : localizeUiPhrase(ref, 'لم ترسل صوتك بعد.'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeUiPhrase(ref, 'اللوحة الحية'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    ...room.players.map(
                      (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            PlayerAvatar(
                              index: player.avatarIndex,
                              label: '${player.avatarIndex + 1}',
                              radius: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(player.name)),
                            Text('${player.score}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PhaseActionCard(
                room: room,
                localizedGuessOptions: localizedGuessOptions,
                selectedGuess: _selectedGuess,
                selectedSuspectId: _selectedSuspectId,
                onGuessSelected: (value) => setState(() => _selectedGuess = value),
                onSuspectSelected: (value) => setState(() => _selectedSuspectId = value),
                onSubmitGuess: (value) async {
                  await ref.read(multiplayerRoomProvider.notifier).submitOutsiderGuess(value);
                  setState(() => _selectedGuess = null);
                },
                onSubmitVote: (suspectId) async {
                  await ref.read(multiplayerRoomProvider.notifier).submitVote(suspectId);
                  setState(() => _selectedSuspectId = null);
                },
                onAdvance: () => ref.read(multiplayerRoomProvider.notifier).advancePrototypePhase(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: BaraButton.secondary(
                      label: localizeUiPhrase(ref, 'العودة للردهة'),
                      icon: Icons.meeting_room_rounded,
                      onPressed: () => context.go(MultiplayerLobbyScreen.routePath),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BaraButton.secondary(
                      label: localizeUiPhrase(ref, 'خروج'),
                      icon: Icons.logout_rounded,
                      onPressed: () async {
                        await ref.read(multiplayerRoomProvider.notifier).leaveRoom();
                        if (!context.mounted) {
                          return;
                        }
                        context.go(MultiplayerHubScreen.routePath);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const _RoomLoadingState(),
      error: (error, _) => BaraScaffold(
        title: localizeUiPhrase(ref, 'الغرفة الحية'),
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

  String _phaseLabel(MultiplayerRoomPhase phase) {
    return switch (phase) {
      MultiplayerRoomPhase.lobby => localizeUiPhrase(ref, 'الردهة'),
      MultiplayerRoomPhase.privateReveal => localizeUiPhrase(ref, 'كشف خاص'),
      MultiplayerRoomPhase.clueTurns => localizeUiPhrase(ref, 'جولة التلميحات'),
      MultiplayerRoomPhase.discussion => localizeUiPhrase(ref, 'النقاش'),
      MultiplayerRoomPhase.voting => localizeUiPhrase(ref, 'التصويت الخاص'),
      MultiplayerRoomPhase.voteReveal => localizeUiPhrase(ref, 'كشف نتائج التصويت'),
      MultiplayerRoomPhase.outsiderGuess => localizeUiPhrase(ref, 'تخمين برا السالفة'),
      MultiplayerRoomPhase.results => localizeUiPhrase(ref, 'النتيجة النهائية'),
    };
  }
  void _warmRoomTranslations(MultiplayerRoomState room) {
    final locale = ref.read(appSettingsProvider).locale;
    if (locale == SupportedLocale.arabic) {
      return;
    }

    final topics = <String>{
      if (room.privateView.topicLabel != null) room.privateView.topicLabel!,
      ...room.privateView.guessOptions,
    };
    final uiPhrases = <String>{
      room.round.statusLine,
      room.systemMessage,
    }..removeWhere((item) => item.trim().isEmpty);
    if (topics.isEmpty && uiPhrases.isEmpty) {
      return;
    }

    Future<void>.microtask(() async {
      if (topics.isNotEmpty) {
        await ref.read(topicTranslationsProvider.notifier).ensureTopicsTranslated(
              packId: room.packId,
              topics: topics,
            );
      }
      if (uiPhrases.isNotEmpty) {
        warmUiPhrases(ref, uiPhrases);
      }
    });
  }

  String _localizedTopic({
    required String packId,
    required String topic,
    required SupportedLocale locale,
  }) {
    return ref.read(topicTranslationsProvider.notifier).localizedTopic(
          packId: packId,
          topic: topic,
          locale: locale,
        );
  }
}

class _PhaseActionCard extends ConsumerWidget {
  const _PhaseActionCard({
    required this.room,
    required this.localizedGuessOptions,
    required this.selectedGuess,
    required this.selectedSuspectId,
    required this.onGuessSelected,
    required this.onSuspectSelected,
    required this.onSubmitGuess,
    required this.onSubmitVote,
    required this.onAdvance,
  });

  final MultiplayerRoomState room;
  final List<String> localizedGuessOptions;
  final String? selectedGuess;
  final String? selectedSuspectId;
  final ValueChanged<String> onGuessSelected;
  final ValueChanged<String> onSuspectSelected;
  final ValueChanged<String> onSubmitGuess;
  final ValueChanged<String> onSubmitVote;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = room.round.phase;
    final isHost = room.isCurrentPlayerHost;

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizeUiPhrase(ref, 'إجراءات الطور'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (phase == MultiplayerRoomPhase.voting) ...[
            Text(room.privateView.voteSubmitted
                ? localizeUiPhrase(ref, 'تم إرسال صوتك من هذا الهاتف.')
                : localizeUiPhrase(ref, 'هذا المكان يمثل شاشة التصويت الخاصة بلاعب واحد فقط.')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: room.players
                  .where((player) => player.id != room.currentPlayerId)
                  .map(
                    (player) => ChoiceChip(
                      label: Text(player.name),
                      selected: selectedSuspectId == player.id,
                      onSelected: room.privateView.voteSubmitted
                          ? null
                          : (_) => onSuspectSelected(player.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            BaraButton.primary(
              label: room.privateView.voteSubmitted
                  ? localizeUiPhrase(ref, 'تم إرسال الصوت')
                  : localizeUiPhrase(ref, 'إرسال صوتي'),
              icon: Icons.how_to_vote_rounded,
              onPressed: room.privateView.voteSubmitted || selectedSuspectId == null
                  ? null
                  : () => onSubmitVote(selectedSuspectId!),
            ),
          ] else if (phase == MultiplayerRoomPhase.outsiderGuess &&
              room.privateView.isOutsider) ...[
            Text(localizeUiPhrase(ref, 'أنت وحدك ترى هذه الخيارات على هاتفك.')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: room.privateView.guessOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value;
                return ChoiceChip(
                  label: Text(localizedGuessOptions[index]),
                  selected: selectedGuess == topic,
                  onSelected: (_) => onGuessSelected(topic),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            BaraButton.primary(
              label: localizeUiPhrase(ref, 'أرسل التخمين النهائي'),
              icon: Icons.lightbulb_rounded,
              onPressed: selectedGuess == null ? null : () => onSubmitGuess(selectedGuess!),
            ),
          ] else if (phase == MultiplayerRoomPhase.outsiderGuess) ...[
            Text(localizeUiPhrase(ref, 'الهاتف الخاص ببرا السالفة فقط هو الذي يستقبل شاشة التخمين الآن.')),
          ] else ...[
            Text(
              isHost
                  ? localizeUiPhrase(ref, 'هذا الزر يحاكي انتقال الخادم للمرحلة التالية داخل النموذج.')
                  : localizeUiPhrase(ref, 'بانتظار بث الخادم للطور التالي في النسخة الحقيقية.'),
            ),
          ],
          if (isHost && phase != MultiplayerRoomPhase.results) ...[
            const SizedBox(height: 12),
            BaraButton.secondary(
              label: localizeUiPhrase(ref, 'المرحلة التالية'),
              icon: Icons.skip_next_rounded,
              onPressed: onAdvance,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomLoadingState extends ConsumerWidget {
  const _RoomLoadingState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaraScaffold(
      title: localizeUiPhrase(ref, 'الغرفة الحية'),
      showBackButton: true,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
