import 'package:bara_alsalfa/core/i18n/game_text.dart';
import 'package:bara_alsalfa/core/i18n/topic_translation_controller.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageSubjectsScreen extends ConsumerStatefulWidget {
  const ManageSubjectsScreen({super.key});

  static const routePath = '/setup/manage-subjects';

  @override
  ConsumerState<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends ConsumerState<ManageSubjectsScreen> {
  final _topicController = TextEditingController();
  String? _selectedPackId;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packs = ref.watch(categoryLibraryProvider);
    final settings = ref.watch(appSettingsProvider);
    ref.watch(topicTranslationsProvider);
    final topicLocalizer = ref.read(topicTranslationsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final selectedPackId = _selectedPackId ?? packs.first.id;
    final selectedPack = packs.firstWhere((pack) => pack.id == selectedPackId);
    warmUiPhrases(ref, const [
      'من هنا تقدر تضيف أو تحذف السوالف التي يمكن أن تظهر داخل الجولة.',
      'تم حذف',
      'آخر سالفة في كل مجموعة تبقى محمية حتى لا تصبح المجموعة فارغة.',
      'تمت إضافة',
    ]);

    return BaraScaffold(
      title: l10n.manageStories,
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            localizeUiPhrase(ref, 'من هنا تقدر تضيف أو تحذف السوالف التي يمكن أن تظهر داخل الجولة.'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: packs.map((pack) {
              final isSelected = selectedPack.id == pack.id;
              return ChoiceChip(
                selected: isSelected,
                label: Text(localizedPackTitle(pack, settings.locale)),
                onSelected: (_) => setState(() => _selectedPackId = pack.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedPackTitle(selectedPack, settings.locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(localizedPackSubtitle(selectedPack, settings.locale)),
                const SizedBox(height: 18),
                TextField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: l10n.enterStory,
                    suffixIcon: IconButton(
                      onPressed: () => _addTopic(selectedPack.id),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                  onSubmitted: (_) => _addTopic(selectedPack.id),
                ),
                const SizedBox(height: 14),
                BaraButton.primary(
                  label: l10n.addStory,
                  icon: Icons.add_circle_rounded,
                  onPressed: () => _addTopic(selectedPack.id),
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
                  l10n.storyCount(selectedPack.topics.length),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...selectedPack.topics.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              topicLocalizer.localizedTopic(
                                packId: selectedPack.id,
                                topic: topic,
                                locale: settings.locale,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await ref
                                  .read(categoryLibraryProvider.notifier)
                                  .removeTopic(selectedPack.id, topic);
                              await ref
                                  .read(topicTranslationsProvider.notifier)
                                  .removeTranslations(packId: selectedPack.id, topic: topic);
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${localizeUiPhrase(ref, 'تم حذف')} "$topic"'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizeUiPhrase(
                    ref,
                    'آخر سالفة في كل مجموعة تبقى محمية حتى لا تصبح المجموعة فارغة.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTopic(String packId) async {
    final text = _topicController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final locale = ref.read(appSettingsProvider).locale;
    await ref.read(categoryLibraryProvider.notifier).addTopic(packId, text);
    await ref
        .read(topicTranslationsProvider.notifier)
        .ensureTranslations(
          packId: packId,
          topic: text,
          sourceLocaleCode: locale.code,
        );
    _topicController.clear();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${localizeUiPhrase(ref, 'تمت إضافة')} "$text"')),
    );
  }
}
