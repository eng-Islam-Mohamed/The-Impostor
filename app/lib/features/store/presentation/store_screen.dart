import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  static const routePath = '/store';

  @override
  Widget build(BuildContext context) {
    return BaraScaffold(
      title: 'المتجر',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: const [
          _StoreCard(
            title: 'جلسة آخر الليل',
            subtitle: 'باك بريميوم للكلمات الأصعب والجو الأقوى.',
            badge: 'Premium Pack',
          ),
          SizedBox(height: 12),
          _StoreCard(
            title: 'Party Bundle',
            subtitle: 'ثيم بصري ذهبي + باك خاص + شارة مشاركة.',
            badge: 'Bundle',
          ),
          SizedBox(height: 12),
          _StoreCard(
            title: 'لمة العائلة',
            subtitle: 'تجربة ألطف ومناسبة للجلسات المختلطة.',
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
