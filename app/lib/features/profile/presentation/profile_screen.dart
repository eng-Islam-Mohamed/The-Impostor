import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';

  static final Uri _facebookUri = Uri.parse(
    'https://www.facebook.com/islam.mohamed.966245?locale=fr_FR',
  );
  static final Uri _instagramUri = Uri.parse(
    'https://www.instagram.com/isla4a4m____/',
  );
  static final Uri _githubUri = Uri.parse(
    'https://github.com/eng-Islam-Mohamed',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return BaraScaffold(
      title: l10n.settings,
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
                  title: Text(l10n.darkMode),
                  subtitle: Text(l10n.darkModeSubtitle),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.hapticsEnabled,
                  onChanged: controller.setHaptics,
                  title: Text(l10n.haptics),
                  subtitle: Text(l10n.hapticsSubtitle),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.soundEnabled,
                  onChanged: controller.setSound,
                  title: Text(l10n.sound),
                  subtitle: Text(l10n.soundSubtitle),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: settings.reducedMotion,
                  onChanged: controller.setReducedMotion,
                  title: Text(l10n.reducedMotion),
                  subtitle: Text(l10n.reducedMotionSubtitle),
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
                  'ثيم اللعبة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر هوية بصرية مختلفة لكل جلسة لعب.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                _ThemeSelector(
                  currentTheme: settings.visualTheme,
                  onThemeChanged: controller.setVisualTheme,
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
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.languageSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                _LanguageSelector(
                  currentLocale: settings.locale,
                  onLocaleChanged: controller.setLocale,
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
                  l10n.followMe,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _SocialTile(
                  icon: Icons.facebook_rounded,
                  title: 'Facebook',
                  subtitle: 'islam.mohamed.966245',
                  onTap: () => _launchLink(context, _facebookUri, l10n),
                ),
                const Divider(height: 18),
                _SocialTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Instagram',
                  subtitle: '@isla4a4m____',
                  onTap: () => _launchLink(context, _instagramUri, l10n),
                ),
                const Divider(height: 18),
                _SocialTile(
                  icon: Icons.code_rounded,
                  title: 'GitHub',
                  subtitle: 'eng-Islam-Mohamed',
                  onTap: () => _launchLink(context, _githubUri, l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlowCard(
            child: Column(
              children: [
                Text(
                  l10n.builtBy,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.copyright,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchLink(
    BuildContext context,
    Uri uri,
    AppLocalizations l10n,
  ) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.openLinkError)));
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  final AppVisualTheme currentTheme;
  final void Function(AppVisualTheme) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppVisualTheme.values.map((theme) {
        final isSelected = theme == currentTheme;
        final colors = _themeSwatches(theme);
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in colors)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsetsDirectional.only(end: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(theme.localizedTitle),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onThemeChanged(theme),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  List<Color> _themeSwatches(AppVisualTheme theme) {
    return switch (theme) {
      AppVisualTheme.emeraldLounge => const [
        Color(0xFF0F8F78),
        Color(0xFFF06A5F),
        Color(0xFFD6B36E),
      ],
      AppVisualTheme.royalNoir => const [
        Color(0xFF7552A8),
        Color(0xFFE15F68),
        Color(0xFFE8C77A),
      ],
      AppVisualTheme.midnightCoral => const [
        Color(0xFF1C7FA0),
        Color(0xFFFF6F61),
        Color(0xFFFFC857),
      ],
      AppVisualTheme.pearlMajlis => const [
        Color(0xFFB06A2D),
        Color(0xFF2F8F83),
        Color(0xFFC94E5A),
      ],
      AppVisualTheme.neonSouk => const [
        Color(0xFFFF5FB7),
        Color(0xFF00D6C8),
        Color(0xFFFFC857),
      ],
      AppVisualTheme.candyChaos => const [
        Color(0xFFFF6B9A),
        Color(0xFF7AE582),
        Color(0xFFFFBE3D),
      ],
      AppVisualTheme.desertArcade => const [
        Color(0xFFF28C28),
        Color(0xFF2DD4BF),
        Color(0xFFEE4266),
      ],
      AppVisualTheme.oceanMajlis => const [
        Color(0xFF0891B2),
        Color(0xFFFF7A59),
        Color(0xFFA7F3D0),
      ],
    };
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final SupportedLocale currentLocale;
  final void Function(SupportedLocale) onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SupportedLocale.values.map((locale) {
        final isSelected = locale == currentLocale;
        return ChoiceChip(
          label: Text(locale.nativeName),
          selected: isSelected,
          onSelected: (_) => onLocaleChanged(locale),
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 22, child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle, textDirection: TextDirection.ltr),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: onTap,
    );
  }
}
