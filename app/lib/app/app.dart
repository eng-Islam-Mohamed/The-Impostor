import 'package:bara_alsalfa/app/router/app_router.dart';
import 'package:bara_alsalfa/app/theme/app_theme.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bara_alsalfa/l10n/generated/app_localizations.dart';

class BaraApp extends ConsumerWidget {
  const BaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: router,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: settings.locale.locale,
      supportedLocales: SupportedLocale.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.locale.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
