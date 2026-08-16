import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/saved_game_group.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/players_screen.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/setup_screen.dart';
import 'package:bara_alsalfa/features/groups/application/saved_groups_controller.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedGroupsScreen extends ConsumerWidget {
  const SavedGroupsScreen({super.key});

  static const routePath = '/groups';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedGroupsProvider);
    return BaraScaffold(
      title: 'المجموعات المحفوظة',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شِلّتك جاهزة دائمًا',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'احفظ الأسماء والصور والنقاط. كل مجموعة مستقلة وتبقى محفوظة بعد إغلاق اللعبة.',
                ),
                const SizedBox(height: 16),
                BaraButton.primary(
                  label: 'حفظ اللاعبين الحاليين كمجموعة',
                  icon: Icons.group_add_rounded,
                  onPressed: () => _createGroup(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (state.groups.isEmpty)
            const GlowCard(
              child: Center(child: Text('لا توجد مجموعات محفوظة بعد.')),
            )
          else
            ...state.groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GroupCard(
                  group: group,
                  isActive: state.activeGroupId == group.id,
                  onOpen: () => _openGroup(context, ref, group),
                  onEdit: () => _editGroup(context, ref, group),
                  onDuplicate: () => _duplicateGroup(context, ref, group),
                  onDelete: () => _deleteGroup(context, ref, group),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await _nameDialog(context, title: 'اسم المجموعة');
    if (name == null) return;
    await ref
        .read(savedGroupsProvider.notifier)
        .create(
          name: name,
          session: ref.read(gameSessionProvider.notifier).exportSnapshot(),
        );
  }

  Future<void> _openGroup(
    BuildContext context,
    WidgetRef ref,
    SavedGameGroup group,
  ) async {
    final action = await showModalBottomSheet<_GroupOpenAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                group.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              BaraButton.primary(
                label: 'متابعة بالنتائج الحالية',
                icon: Icons.history_rounded,
                onPressed: () =>
                    Navigator.pop(context, _GroupOpenAction.continueScores),
              ),
              const SizedBox(height: 10),
              BaraButton.secondary(
                label: localizeUiPhrase(ref, 'تعديل جميع الإعدادات'),
                icon: Icons.tune_rounded,
                onPressed: () =>
                    Navigator.pop(context, _GroupOpenAction.editSettings),
              ),
              const SizedBox(height: 10),
              BaraButton.secondary(
                label: 'بدء نتائج جديدة',
                icon: Icons.restart_alt_rounded,
                onPressed: () =>
                    Navigator.pop(context, _GroupOpenAction.resetScores),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null) return;
    await ref.read(savedGroupsProvider.notifier).activate(group.id);
    await ref
        .read(gameSessionProvider.notifier)
        .loadSavedSession(
          group.session,
          resetScores: action == _GroupOpenAction.resetScores,
        );
    if (!context.mounted) return;
    context.push(
      action == _GroupOpenAction.editSettings
          ? '${SetupScreen.routePath}?edit=true'
          : PlayersScreen.routePath,
    );
  }

  Future<void> _editGroup(
    BuildContext context,
    WidgetRef ref,
    SavedGameGroup group,
  ) async {
    await ref.read(savedGroupsProvider.notifier).activate(group.id);
    await ref
        .read(gameSessionProvider.notifier)
        .loadSavedSession(group.session);
    if (context.mounted) {
      context.push('${SetupScreen.routePath}?edit=true');
    }
  }

  Future<void> _duplicateGroup(
    BuildContext context,
    WidgetRef ref,
    SavedGameGroup group,
  ) async {
    final name = await _nameDialog(
      context,
      title: 'اسم النسخة الجديدة',
      initialValue: '${group.name} - نسخة',
    );
    if (name == null || !context.mounted) return;
    final copyScores = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نقاط المجموعة الجديدة'),
        content: const Text('هل تريد نسخ النقاط الحالية أم البدء من الصفر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('البدء من الصفر'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نسخ النقاط'),
          ),
        ],
      ),
    );
    if (copyScores == null) return;
    await ref
        .read(savedGroupsProvider.notifier)
        .duplicate(groupId: group.id, name: name, copyScores: copyScores);
  }

  Future<void> _deleteGroup(
    BuildContext context,
    WidgetRef ref,
    SavedGameGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف ${group.name}؟'),
        content: const Text(
          'سيتم حذف اللاعبين والنقاط المحفوظة لهذه المجموعة فقط.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(savedGroupsProvider.notifier).delete(group.id);
    }
  }

  Future<String?> _nameDialog(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'مثال: شلة الحومة'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = result?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.isActive,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final SavedGameGroup group;
  final bool isActive;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      isSelected: isActive,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (isActive) const Chip(label: Text('الحالية')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final player in group.session.players)
                Chip(label: Text('${player.name}  ${player.score}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('كل الإعدادات'),
              ),
              TextButton.icon(
                onPressed: onDuplicate,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('نسخ'),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _GroupOpenAction { continueScores, editSettings, resetScores }
