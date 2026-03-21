import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);

    return BaraScaffold(
      title: 'الإعدادات',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          GlowCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => controller.toggleThemeMode(),
                  title: const Text('الوضع الداكن'),
                  subtitle: const Text('تجربة أكثر هدوءًا للسهرة الليلية'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.hapticsEnabled,
                  onChanged: controller.setHaptics,
                  title: const Text('الاهتزازات'),
                  subtitle: const Text('لمسات تكتيكية أثناء كشف الدور'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.soundEnabled,
                  onChanged: controller.setSound,
                  title: const Text('الصوت'),
                  subtitle: const Text('جاهز لوصل المؤثرات والموسيقى لاحقًا'),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.reducedMotion,
                  onChanged: controller.setReducedMotion,
                  title: const Text('تقليل الحركة'),
                  subtitle: const Text('انتقالات أخف للأجهزة الأبطأ أو لمن يفضّل الهدوء'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
