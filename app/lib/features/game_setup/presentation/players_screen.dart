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

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  static const routePath = '/setup/players';

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider);
    final mode = session.selectedMode;
    final l10n = AppLocalizations.of(context);
    final playerCountIsValid =
        session.players.length >= mode.minPlayers &&
        session.players.length <= mode.maxPlayers;
    final maxOutsiders = maxOutsidersForPlayerCount(session.players.length);

    warmUiPhrases(ref, const [
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
      'رمز الإدارة',
      'أدخل الرمز الرباعي',
      'دخول',
      'الرمز غير صحيح',
      'إدارة أصحاب السر',
      'اختر اللاعبين الذين يمكنهم رؤية السالفة وأسماء برا السالفة بالحركة المخفية.',
      'الرصيد:',
      'مدة تشغيل المقلب',
      'حتى أوقفه يدوياً',
      'جولة واحدة',
      'جولتان',
      '3 جولات',
      '5 جولات',
      '10 جولات',
      'رمز جديد اختياري',
      'اتركه فارغاً للاحتفاظ بالرمز الحالي',
      'حفظ وتشغيل المقلب',
      'إيقاف المقلب ومسح أصحاب السر',
    ]);

    return BaraScaffold(
      titleWidget: _SecretPlayersTitle(
        title: l10n.players,
        onUnlocked: _openSecretPrankPanel,
      ),
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
                  onPressed: () =>
                      ref.read(gameSessionProvider.notifier).shufflePlayers(),
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
                      onTap: () => ref
                          .read(gameSessionProvider.notifier)
                          .cycleAvatar(player.id),
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
                          Text(
                            player.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizeUiPhrase(
                              ref,
                              'اضغط على الصورة لتبديل الهوية البصرية.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showRenameDialog(
                        context,
                        ref,
                        player.id,
                        player.name,
                      ),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(gameSessionProvider.notifier)
                          .removePlayer(player.id),
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
                Text(
                  localizeUiPhrase(ref, 'عدد برا السالفة'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  maxOutsiders == 1
                      ? localizeUiPhrase(
                          ref,
                          'يزيد تلقائيًا عندما يصبح عدد اللاعبين أكبر.',
                        )
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
                      onSelected: (_) => ref
                          .read(gameSessionProvider.notifier)
                          .setOutsiderCount(value),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: SwitchListTile.adaptive(
              value: session.sequentialEliminationEnabled,
              contentPadding: EdgeInsets.zero,
              title: const Text('التصويت بالإقصاء المتتابع'),
              subtitle: const Text(
                'متاح مع واحد أو أكثر من برا السالفة: صوت واحد لكل لاعب، ثم جولة جديدة حتى الحسم.',
              ),
              secondary: const Icon(Icons.how_to_vote_rounded),
              onChanged: (value) => ref
                  .read(gameSessionProvider.notifier)
                  .toggleSequentialElimination(value),
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
            onPressed: playerCountIsValid
                ? () => context.push(CategoriesScreen.routePath)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _openSecretPrankPanel() async {
    final pinController = TextEditingController();
    final authenticated =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(localizeUiPhrase(ref, 'رمز الإدارة')),
            content: TextField(
              controller: pinController,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: localizeUiPhrase(ref, 'أدخل الرمز الرباعي'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(
                  ref
                      .read(gameSessionProvider.notifier)
                      .verifySecretPrankPin(pinController.text),
                ),
                child: Text(localizeUiPhrase(ref, 'دخول')),
              ),
            ],
          ),
        ) ??
        false;
    pinController.dispose();
    if (!mounted) return;
    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeUiPhrase(ref, 'الرمز غير صحيح'))),
      );
      return;
    }
    await _showSecretPrankSettings();
  }

  Future<void> _showSecretPrankSettings() async {
    final session = ref.read(gameSessionProvider);
    final selectedIds = {...session.secretPrankConfig.insiderPlayerIds};
    var roundChoice = session.secretPrankConfig.roundsRemaining ?? 0;
    final newPinController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              4,
              22,
              22 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizeUiPhrase(ref, 'إدارة أصحاب السر'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizeUiPhrase(
                      ref,
                      'اختر اللاعبين الذين يمكنهم رؤية السالفة وأسماء برا السالفة بالحركة المخفية.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final player in session.players)
                    CheckboxListTile(
                      value: selectedIds.contains(player.id),
                      contentPadding: EdgeInsets.zero,
                      secondary: PlayerAvatar(
                        index: player.avatarIndex,
                        label: '${player.avatarIndex + 1}',
                        radius: 22,
                      ),
                      title: Text(player.name),
                      subtitle: Text(
                        '${localizeUiPhrase(ref, 'الرصيد:')} ${player.score}',
                      ),
                      onChanged: (selected) => setSheetState(() {
                        if (selected ?? false) {
                          selectedIds.add(player.id);
                        } else {
                          selectedIds.remove(player.id);
                        }
                      }),
                    ),
                  const Divider(height: 28),
                  DropdownButtonFormField<int>(
                    initialValue: roundChoice,
                    decoration: InputDecoration(
                      labelText: localizeUiPhrase(ref, 'مدة تشغيل المقلب'),
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text(localizeUiPhrase(ref, 'حتى أوقفه يدوياً')),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(localizeUiPhrase(ref, 'جولة واحدة')),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(localizeUiPhrase(ref, 'جولتان')),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text(localizeUiPhrase(ref, '3 جولات')),
                      ),
                      DropdownMenuItem<int>(
                        value: 5,
                        child: Text(localizeUiPhrase(ref, '5 جولات')),
                      ),
                      DropdownMenuItem<int>(
                        value: 10,
                        child: Text(localizeUiPhrase(ref, '10 جولات')),
                      ),
                    ],
                    onChanged: (value) =>
                        setSheetState(() => roundChoice = value ?? 0),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: newPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: localizeUiPhrase(ref, 'رمز جديد اختياري'),
                      hintText: localizeUiPhrase(
                        ref,
                        'اتركه فارغاً للاحتفاظ بالرمز الحالي',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BaraButton.primary(
                    label: localizeUiPhrase(ref, 'حفظ وتشغيل المقلب'),
                    icon: Icons.visibility_off_rounded,
                    onPressed: selectedIds.isEmpty
                        ? null
                        : () {
                            ref
                                .read(gameSessionProvider.notifier)
                                .configureSecretPrank(
                                  insiderPlayerIds: selectedIds,
                                  roundsRemaining: roundChoice == 0
                                      ? null
                                      : roundChoice,
                                  newPin: newPinController.text,
                                );
                            Navigator.of(sheetContext).pop();
                          },
                  ),
                  if (session.secretPrankConfig.enabled ||
                      session
                          .secretPrankConfig
                          .insiderPlayerIds
                          .isNotEmpty) ...[
                    const SizedBox(height: 10),
                    BaraButton.secondary(
                      label: localizeUiPhrase(
                        ref,
                        'إيقاف المقلب ومسح أصحاب السر',
                      ),
                      icon: Icons.delete_forever_rounded,
                      onPressed: () {
                        ref
                            .read(gameSessionProvider.notifier)
                            .disableSecretPrank();
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    newPinController.dispose();
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
                ref
                    .read(gameSessionProvider.notifier)
                    .updatePlayerName(playerId, controller.text);
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

class _SecretPlayersTitle extends StatefulWidget {
  const _SecretPlayersTitle({required this.title, required this.onUnlocked});

  final String title;
  final VoidCallback onUnlocked;

  @override
  State<_SecretPlayersTitle> createState() => _SecretPlayersTitleState();
}

class _SecretPlayersTitleState extends State<_SecretPlayersTitle> {
  DateTime? _firstTapAt;
  int _tapCount = 0;

  void _registerTap() {
    final now = DateTime.now();
    final firstTapAt = _firstTapAt;
    if (firstTapAt == null ||
        now.difference(firstTapAt) > const Duration(seconds: 4)) {
      _firstTapAt = now;
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    if (_tapCount < 5) return;
    _tapCount = 0;
    _firstTapAt = null;
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _registerTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(widget.title),
      ),
    );
  }
}
