import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/multiplayer_room.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_config_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/application/multiplayer_room_controller.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_create_room_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_join_room_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_lobby_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MultiplayerHubScreen extends ConsumerWidget {
  const MultiplayerHubScreen({super.key});

  static const routePath = '/multiplayer';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(multiplayerRoomProvider);
    final activeRoom = roomState.asData?.value;
    final config = ref.watch(multiplayerClientConfigProvider);

    warmUiPhrases(ref, const [
      'الغرف الأونلاين',
      'طور متعدد الأجهزة',
      'كل لاعب يدخل من هاتفه، والخادم يكون هو المرجع النهائي لكل حالة وتصويت وتخمين.',
      'إنشاء غرفة',
      'الانضمام برمز',
      'اتصال الخادم',
      'استخدام الخادم الحقيقي',
      'سيتصل التطبيق بخادم حي يعمل عبر الإنترنت',
      'سيبقى التطبيق على الوضع التجريبي المحلي',
      'الرابط الحالي',
      'تعديل رابط الخادم',
      'غرفة حالية نشطة',
      'الكود',
      'المرحلة',
      'العودة إلى الردهة',
      'متابعة الجولة',
      'تعذر تحميل الغرفة',
      'مسح الخطأ',
      'ما تم تجهيزه الآن',
      'نماذج غرف، لاعبين، مراحل، وعقود أحداث جاهزة للربط مع Socket.IO',
      'ردهة حية مع حالة الجاهزية، المضيف، والمزامنة الشكلية',
      'شاشة جولة أولية تُظهر كيف ستبقى المعلومة الخاصة على الهاتف نفسه',
      'رابط الخادم',
      'حفظ',
    ]);

    return BaraScaffold(
      title: localizeUiPhrase(ref, 'الغرف الأونلاين'),
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeUiPhrase(ref, 'طور متعدد الأجهزة'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  localizeUiPhrase(
                    ref,
                    'كل لاعب يدخل من هاتفه، والخادم يكون هو المرجع النهائي لكل حالة وتصويت وتخمين.',
                  ),
                ),
                const SizedBox(height: 18),
                BaraButton.primary(
                  label: localizeUiPhrase(ref, 'إنشاء غرفة'),
                  icon: Icons.add_home_work_rounded,
                  onPressed: () => context.push(MultiplayerCreateRoomScreen.routePath),
                ),
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: localizeUiPhrase(ref, 'الانضمام برمز'),
                  icon: Icons.meeting_room_rounded,
                  onPressed: () => context.push(MultiplayerJoinRoomScreen.routePath),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeUiPhrase(ref, 'اتصال الخادم'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: config.useLiveServer,
                  onChanged: (value) => ref
                      .read(multiplayerClientConfigProvider.notifier)
                      .setUseLiveServer(value),
                  title: Text(localizeUiPhrase(ref, 'استخدام الخادم الحقيقي')),
                  subtitle: Text(
                    config.useLiveServer
                        ? localizeUiPhrase(ref, 'سيتصل التطبيق بخادم حي يعمل عبر الإنترنت')
                        : localizeUiPhrase(ref, 'سيبقى التطبيق على الوضع التجريبي المحلي'),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${localizeUiPhrase(ref, 'الرابط الحالي')}: ${config.serverUrl}'),
                const SizedBox(height: 12),
                BaraButton.secondary(
                  label: localizeUiPhrase(ref, 'تعديل رابط الخادم'),
                  icon: Icons.edit_rounded,
                  onPressed: () => _showServerUrlDialog(context, ref, config.serverUrl),
                ),
              ],
            ),
          ),
          if (activeRoom != null) ...[
            const SizedBox(height: 18),
            GlowCard(
              isSelected: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeUiPhrase(ref, 'غرفة حالية نشطة'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('${localizeUiPhrase(ref, 'الكود')}: ${activeRoom.roomCode}'),
                  const SizedBox(height: 6),
                  Text('${localizeUiPhrase(ref, 'المرحلة')}: ${_phaseLabel(ref, activeRoom.round.phase)}'),
                  const SizedBox(height: 16),
                  BaraButton.secondary(
                    label: activeRoom.status == MultiplayerRoomStatus.lobby
                        ? localizeUiPhrase(ref, 'العودة إلى الردهة')
                        : localizeUiPhrase(ref, 'متابعة الجولة'),
                    icon: Icons.play_circle_outline_rounded,
                    onPressed: () => context.push(
                      activeRoom.status == MultiplayerRoomStatus.lobby
                          ? MultiplayerLobbyScreen.routePath
                          : MultiplayerRoomScreen.routePath,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (roomState.hasError) ...[
            const SizedBox(height: 18),
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeUiPhrase(ref, 'تعذر تحميل الغرفة'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(localizeUiPhrase(ref, '${roomState.error}')),
                  const SizedBox(height: 12),
                  BaraButton.secondary(
                    label: localizeUiPhrase(ref, 'مسح الخطأ'),
                    icon: Icons.refresh_rounded,
                    onPressed: () => ref.read(multiplayerRoomProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizeUiPhrase(ref, 'ما تم تجهيزه الآن')),
                const SizedBox(height: 10),
                Text(localizeUiPhrase(
                  ref,
                  'نماذج غرف، لاعبين، مراحل، وعقود أحداث جاهزة للربط مع Socket.IO',
                )),
                const SizedBox(height: 6),
                Text(localizeUiPhrase(
                  ref,
                  'ردهة حية مع حالة الجاهزية، المضيف، والمزامنة الشكلية',
                )),
                const SizedBox(height: 6),
                Text(localizeUiPhrase(
                  ref,
                  'شاشة جولة أولية تُظهر كيف ستبقى المعلومة الخاصة على الهاتف نفسه',
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showServerUrlDialog(
    BuildContext context,
    WidgetRef ref,
    String currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizeUiPhrase(ref, 'رابط الخادم')),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'https://your-public-server.example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(multiplayerClientConfigProvider.notifier)
                    .setServerUrl(controller.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(localizeUiPhrase(ref, 'حفظ')),
            ),
          ],
        );
      },
    );
  }

  String _phaseLabel(WidgetRef ref, MultiplayerRoomPhase phase) {
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
}
