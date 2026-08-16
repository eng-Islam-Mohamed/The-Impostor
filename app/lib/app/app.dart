import 'package:bara_alsalfa/app/router/app_router.dart';
import 'package:bara_alsalfa/app/theme/app_theme.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaraApp extends ConsumerStatefulWidget {
  const BaraApp({super.key});

  @override
  ConsumerState<BaraApp> createState() => _BaraAppState();
}

class _BaraAppState extends ConsumerState<BaraApp> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final uri = Uri.base;
        final themeParam = uri.queryParameters['theme'];
        if (themeParam != null) {
          final theme = AppVisualTheme.fromName(themeParam);
          ref.read(appSettingsProvider.notifier).setVisualTheme(theme);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'برّا السالفة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(settings.visualTheme),
      darkTheme: AppTheme.darkTheme(settings.visualTheme),
      themeMode: settings.themeMode,
      locale: settings.locale.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
