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
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.languageSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
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
      BuildContext context, Uri uri, AppLocalizations l10n) async {
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.openLinkError),
      ),
    );
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
      leading: CircleAvatar(
        radius: 22,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        textDirection: TextDirection.ltr,
      ),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: onTap,
    );
  }
}
