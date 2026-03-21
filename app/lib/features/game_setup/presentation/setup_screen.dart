import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/game_mode.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/players_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key, this.initialModeSlug});

  static const routePath = '/setup';

  final String? initialModeSlug;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool _didApplyInitialMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyInitialMode) {
      return;
    }
    _didApplyInitialMode = true;
    ref
        .read(gameSessionProvider.notifier)
        .selectMode(GameMode.fromSlug(widget.initialModeSlug));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);

    return BaraScaffold(
      title: 'إنشاء لعبة',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            'اختر الجو العام للجولة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...GameMode.values.map(
            (mode) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                isSelected: session.selectedMode == mode,
                onTap: () {
                  if (!mode.isMvpAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${mode.title} قريبًا في التحديث القادم.')),
                    );
                    return;
                  }
                  ref.read(gameSessionProvider.notifier).selectMode(mode);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mode.title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(mode.subtitle),
                        ],
                      ),
                    ),
                    Chip(label: Text(mode.isMvpAvailable ? mode.playerRange : 'قريبًا')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('زمن النقاش', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: session.discussionSeconds.toDouble(),
                  min: 25,
                  max: 90,
                  divisions: 13,
                  label: '${session.discussionSeconds} ثانية',
                  onChanged: (value) => ref
                      .read(gameSessionProvider.notifier)
                      .setDiscussionSeconds(value.round()),
                ),
                Row(
                  children: [
                    Text('${session.discussionSeconds} ثانية'),
                    const Spacer(),
                    Text('${session.players.length} لاعبين'),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: session.scoringEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تفعيل احتساب النقاط'),
                  subtitle: const Text('احتفظ بنتيجة اللاعبين بين الجولات'),
                  onChanged: (value) =>
                      ref.read(gameSessionProvider.notifier).toggleScoring(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BaraButton.primary(
            label: 'التالي: إعداد اللاعبين',
            icon: Icons.arrow_back_rounded,
            onPressed: session.selectedMode.isMvpAvailable
                ? () => context.push(PlayersScreen.routePath)
                : null,
          ),
        ],
      ),
    );
  }
}
