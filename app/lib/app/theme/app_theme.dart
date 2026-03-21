import 'package:flutter/material.dart';

class AppTheme {
  static const _lightBackground = Color(0xFFF5EFE6);
  static const _lightSurface = Color(0xFFFFFCF7);
  static const _darkBackground = Color(0xFF101614);
  static const _darkSurface = Color(0xFF18201D);
  static const _emerald = Color(0xFF0F8F78);
  static const _jade = Color(0xFF43C0A4);
  static const _coral = Color(0xFFF06A5F);
  static const _gold = Color(0xFFD6B36E);
  static const _obsidian = Color(0xFF1B1B1F);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _emerald,
      brightness: Brightness.light,
      surface: _lightSurface,
      primary: _emerald,
      secondary: _coral,
    ).copyWith(
      tertiary: _gold,
      onSurface: _obsidian,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: _lightBackground,
      surfaceTint: Colors.white.withValues(alpha: 0.32),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _jade,
      brightness: Brightness.dark,
      surface: _darkSurface,
      primary: _jade,
      secondary: _coral,
    ).copyWith(
      tertiary: _gold,
      onPrimary: _darkBackground,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF25312C),
    );

    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: _darkBackground,
      surfaceTint: Colors.white.withValues(alpha: 0.08),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color surfaceTint,
  }) {
    final baseTextTheme = Typography.material2021().black.apply(
          fontFamily: 'IBMPlexSansArabic',
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.45),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface.withValues(alpha: 0.9),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        selectedColor: scheme.primary.withValues(alpha: 0.18),
        labelStyle: textTheme.labelLarge!,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.12),
      ),
      splashFactory: InkSparkle.splashFactory,
      extensions: [
        BaraSurfaceTheme(surfaceTint: surfaceTint),
      ],
    );
  }
}

@immutable
class BaraSurfaceTheme extends ThemeExtension<BaraSurfaceTheme> {
  const BaraSurfaceTheme({required this.surfaceTint});

  final Color surfaceTint;

  @override
  BaraSurfaceTheme copyWith({Color? surfaceTint}) {
    return BaraSurfaceTheme(surfaceTint: surfaceTint ?? this.surfaceTint);
  }

  @override
  BaraSurfaceTheme lerp(ThemeExtension<BaraSurfaceTheme>? other, double t) {
    if (other is! BaraSurfaceTheme) {
      return this;
    }

    return BaraSurfaceTheme(
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t) ?? surfaceTint,
    );
  }
}
