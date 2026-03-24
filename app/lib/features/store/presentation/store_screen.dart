import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  static const routePath = '/store';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    warmUiPhrases(ref, const [
      'جلسة آخر الليل',
      'باك بريميوم للكلمات الأصعب والجو الأقوى.',
      'ثيم بصري ذهبي + باك خاص + شارة مشاركة.',
      'لمة العائلة',
      'تجربة ألطف ومناسبة للجلسات المختلطة.',
    ]);
    return BaraScaffold(
      title: MaterialLocalizations.of(context).viewLicensesButtonLabel == ''
          ? localizeUiPhrase(ref, 'المتجر')
          : localizeUiPhrase(ref, 'المتجر'),
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          _StoreCard(
            title: localizeUiPhrase(ref, 'جلسة آخر الليل'),
            subtitle: localizeUiPhrase(ref, 'باك بريميوم للكلمات الأصعب والجو الأقوى.'),
            badge: 'Premium Pack',
          ),
          const SizedBox(height: 12),
          _StoreCard(
            title: 'Party Bundle',
            subtitle: localizeUiPhrase(ref, 'ثيم بصري ذهبي + باك خاص + شارة مشاركة.'),
            badge: 'Bundle',
          ),
          const SizedBox(height: 12),
          _StoreCard(
            title: localizeUiPhrase(ref, 'لمة العائلة'),
            subtitle: localizeUiPhrase(ref, 'تجربة ألطف ومناسبة للجلسات المختلطة.'),
            badge: 'Family',
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(label: Text(badge)),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle),
        ],
      ),
    );
  }
}
