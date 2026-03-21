import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
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
    final selectedPackId = _selectedPackId ?? packs.first.id;
    final selectedPack = packs.firstWhere((pack) => pack.id == selectedPackId);

    return BaraScaffold(
      title: 'إدارة السوالف',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            'من هنا تقدر تضيف أو تحذف السوالف التي يمكن أن تظهر داخل الجولة.',
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
                label: Text(pack.title),
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
                  selectedPack.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(selectedPack.subtitle),
                const SizedBox(height: 18),
                TextField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: selectedPack.id == 'countries'
                        ? 'أضف دولة'
                        : 'أضف شخصية تاريخية',
                    suffixIcon: IconButton(
                      onPressed: () => _addTopic(selectedPack.id),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                  onSubmitted: (_) => _addTopic(selectedPack.id),
                ),
                const SizedBox(height: 14),
                BaraButton.primary(
                  label: selectedPack.id == 'countries'
                      ? 'إضافة دولة'
                      : 'إضافة شخصية',
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
                  'السوالف الحالية (${selectedPack.topics.length})',
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
                          Expanded(child: Text(topic)),
                          IconButton(
                            onPressed: () async {
                              await ref
                                  .read(categoryLibraryProvider.notifier)
                                  .removeTopic(selectedPack.id, topic);
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم حذف "$topic"')),
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
                  'آخر سالفة في كل مجموعة تبقى محمية حتى لا تصبح المجموعة فارغة.',
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
    await ref.read(categoryLibraryProvider.notifier).addTopic(packId, text);
    _topicController.clear();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة "$text"')),
    );
  }
}
