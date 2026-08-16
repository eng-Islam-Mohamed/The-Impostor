import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const cream = Color(0xFFFFF8F0);
  static const blush = Color(0xFFF8E3E0);
  static const rose = Color(0xFFB85C6B);
  static const roseDark = Color(0xFF713B46);
  static const ink = Color(0xFF332B2C);
  static const muted = Color(0xFF776C6D);
  static const night = Color(0xFF211C1D);
  static const nightSurface = Color(0xFF30292A);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const control = 14.0;
  static const card = 20.0;
}

class _VisualThemeSpec {
  const _VisualThemeSpec({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.darkBackground,
    required this.darkSurface,
    required this.lightBackground,
    required this.lightSurface,
    required this.backdropStyle,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color darkBackground;
  final Color darkSurface;
  final Color lightBackground;
  final Color lightSurface;
  final BaraBackdropStyle backdropStyle;
}

class AppTheme {
  const AppTheme._();

  static const Map<AppVisualTheme, _VisualThemeSpec> _specs = {
    AppVisualTheme.emeraldLounge: _VisualThemeSpec(
      primary: Color(0xFF0F8F78),
      secondary: Color(0xFFF06A5F),
      tertiary: Color(0xFFD6B36E),
      darkBackground: Color(0xFF091714),
      darkSurface: Color(0xFF132822),
      lightBackground: Color(0xFFF0FDF4),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.lounge,
    ),
    AppVisualTheme.royalNoir: _VisualThemeSpec(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFE15F68),
      tertiary: Color(0xFFE8C77A),
      darkBackground: Color(0xFF0E0B17),
      darkSurface: Color(0xFF1B152B),
      lightBackground: Color(0xFFFAF5FF),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.regal,
    ),
    AppVisualTheme.midnightCoral: _VisualThemeSpec(
      primary: Color(0xFFFF6F61),
      secondary: Color(0xFF1C7FA0),
      tertiary: Color(0xFFFFC857),
      darkBackground: Color(0xFF0A121E),
      darkSurface: Color(0xFF142236),
      lightBackground: Color(0xFFFFF1F2),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.sparks,
    ),
    AppVisualTheme.pearlMajlis: _VisualThemeSpec(
      primary: Color(0xFFB06A2D),
      secondary: Color(0xFF2F8F83),
      tertiary: Color(0xFFC94E5A),
      darkBackground: Color(0xFF171311),
      darkSurface: Color(0xFF28201C),
      lightBackground: Color(0xFFFAF8F5),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.pearl,
    ),
    AppVisualTheme.neonSouk: _VisualThemeSpec(
      primary: Color(0xFFFF007F),
      secondary: Color(0xFF00F0FF),
      tertiary: Color(0xFFFFC857),
      darkBackground: Color(0xFF080614),
      darkSurface: Color(0xFF15102A),
      lightBackground: Color(0xFFFDF2F8),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.neon,
    ),
    AppVisualTheme.candyChaos: _VisualThemeSpec(
      primary: Color(0xFFFF5286),
      secondary: Color(0xFF7AE582),
      tertiary: Color(0xFFFFBE3D),
      darkBackground: Color(0xFF1A0D1C),
      darkSurface: Color(0xFF2B1630),
      lightBackground: Color(0xFFFFF0F5),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.candy,
    ),
    AppVisualTheme.desertArcade: _VisualThemeSpec(
      primary: Color(0xFFF28C28),
      secondary: Color(0xFF2DD4BF),
      tertiary: Color(0xFFEE4266),
      darkBackground: Color(0xFF181009),
      darkSurface: Color(0xFF291B10),
      lightBackground: Color(0xFFFFFBEB),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.arcade,
    ),
    AppVisualTheme.oceanMajlis: _VisualThemeSpec(
      primary: Color(0xFF0284C7),
      secondary: Color(0xFFFF7A59),
      tertiary: Color(0xFFA7F3D0),
      darkBackground: Color(0xFF061222),
      darkSurface: Color(0xFF0E223E),
      lightBackground: Color(0xFFF0F9FF),
      lightSurface: Colors.white,
      backdropStyle: BaraBackdropStyle.waves,
    ),
  };

  static ThemeData lightTheme([
    AppVisualTheme visualTheme = AppVisualTheme.emeraldLounge,
  ]) {
    final spec = _specs[visualTheme] ?? _specs[AppVisualTheme.emeraldLounge]!;
    return _build(
      brightness: Brightness.light,
      background: spec.lightBackground,
      surface: spec.lightSurface,
      onSurface: AppColors.ink,
      primary: spec.primary,
      secondary: spec.secondary,
      tertiary: spec.tertiary,
      backdropStyle: spec.backdropStyle,
    );
  }

  static ThemeData darkTheme([
    AppVisualTheme visualTheme = AppVisualTheme.emeraldLounge,
  ]) {
    final spec = _specs[visualTheme] ?? _specs[AppVisualTheme.emeraldLounge]!;
    return _build(
      brightness: Brightness.dark,
      background: spec.darkBackground,
      surface: spec.darkSurface,
      onSurface: const Color(0xFFF9EEEE),
      primary: spec.primary,
      secondary: spec.secondary,
      tertiary: spec.tertiary,
      backdropStyle: spec.backdropStyle,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required BaraBackdropStyle backdropStyle,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          onSurface: onSurface,
          surfaceContainerHighest: Color.alphaBlend(
            primary.withValues(alpha: .12),
            surface,
          ),
        );
    final textTheme = Typography.material2021(platform: TargetPlatform.android)
        .englishLike
        .apply(
          fontFamily: 'IBMPlexSansArabic',
          bodyColor: onSurface,
          displayColor: onSurface,
        );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: primary.withValues(alpha: .12),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.white : AppColors.ink,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.white : AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.2),
          foregroundColor: isDark ? Colors.white : onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      extensions: [
        BaraSurfaceTheme(backdropStyle: backdropStyle, surfaceTint: tertiary),
      ],
    );
  }
}

enum BaraBackdropStyle {
  neon,
  candy,
  arcade,
  waves,
  regal,
  sparks,
  pearl,
  lounge,
}

class BaraSurfaceTheme extends ThemeExtension<BaraSurfaceTheme> {
  const BaraSurfaceTheme({
    this.backdropStyle = BaraBackdropStyle.lounge,
    this.surfaceTint,
  });

  final BaraBackdropStyle backdropStyle;
  final Color? surfaceTint;

  @override
  ThemeExtension<BaraSurfaceTheme> copyWith({
    BaraBackdropStyle? backdropStyle,
    Color? surfaceTint,
  }) {
    return BaraSurfaceTheme(
      backdropStyle: backdropStyle ?? this.backdropStyle,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }

  @override
  ThemeExtension<BaraSurfaceTheme> lerp(
    covariant ThemeExtension<BaraSurfaceTheme>? other,
    double t,
  ) {
    if (other is! BaraSurfaceTheme) return this;
    return BaraSurfaceTheme(
      backdropStyle: t < 0.5 ? backdropStyle : other.backdropStyle,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t),
    );
  }
}
