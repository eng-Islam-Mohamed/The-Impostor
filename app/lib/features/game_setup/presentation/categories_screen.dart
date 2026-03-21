import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/data/repositories/local_category_repository.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/manage_subjects_screen.dart';
import 'package:bara_alsalfa/features/round/application/game_session_controller.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const routePath = '/setup/categories';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final packs = ref.watch(categoryLibraryProvider);

    return BaraScaffold(
      title: 'اختيار السالفة',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          Text(
            'اختر نوع السوالف الذي ستُسحب منه كلمة الجولة.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          BaraButton.secondary(
            label: 'إدارة السوالف',
            icon: Icons.edit_note_rounded,
            onPressed: () => context.push(ManageSubjectsScreen.routePath),
          ),
          const SizedBox(height: 16),
          ...packs.map(
            (pack) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                isSelected: session.selectedPackId == pack.id,
                onTap: () => ref.read(gameSessionProvider.notifier).selectPack(pack.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(label: Text(pack.difficultyLabel)),
                        const Spacer(),
                        Text('${pack.topics.length} سالفة'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(pack.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(pack.subtitle),
                    const SizedBox(height: 12),
                    Text(
                      'أمثلة: ${pack.topics.take(4).join(' • ')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          BaraButton.primary(
            label: 'ابدأ الجولة',
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              ref.read(gameSessionProvider.notifier).startRound();
              context.go(RoundScreen.routePath);
            },
          ),
        ],
      ),
    );
  }
}
