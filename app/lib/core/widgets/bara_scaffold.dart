import 'dart:math' as math;

import 'package:bara_alsalfa/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BaraScaffold extends StatelessWidget {
  const BaraScaffold({
    required this.child,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.showBackButton = false,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceTheme = Theme.of(context).extension<BaraSurfaceTheme>();

    return Scaffold(
      extendBody: true,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: showBackButton ? const BackButton() : null,
              actions: actions,
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              Theme.of(context).scaffoldBackgroundColor,
              colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BackdropPatternPainter(
                    style:
                        surfaceTheme?.backdropStyle ?? BaraBackdropStyle.lounge,
                    primary: colorScheme.primary,
                    secondary: colorScheme.secondary,
                    tertiary: colorScheme.tertiary,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -20,
              child: _GlowOrb(
                color: colorScheme.primary.withValues(alpha: 0.18),
                size: 240,
              ),
            ),
            Positioned(
              bottom: -80,
              left: -40,
              child: _GlowOrb(
                color: (surfaceTheme?.surfaceTint ?? colorScheme.tertiary)
                    .withValues(alpha: 0.18),
                size: 260,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _BackdropPatternPainter extends CustomPainter {
  const _BackdropPatternPainter({
    required this.style,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final BaraBackdropStyle style;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    switch (style) {
      case BaraBackdropStyle.neon:
        _paintNeon(canvas, size, paint);
      case BaraBackdropStyle.candy:
        _paintConfetti(canvas, size, paint, density: 34);
      case BaraBackdropStyle.arcade:
        _paintArcade(canvas, size, paint);
      case BaraBackdropStyle.waves:
        _paintWaves(canvas, size, paint);
      case BaraBackdropStyle.regal:
        _paintDiamonds(canvas, size, paint);
      case BaraBackdropStyle.sparks:
        _paintConfetti(canvas, size, paint, density: 22);
      case BaraBackdropStyle.pearl:
        _paintWaves(canvas, size, paint, soft: true);
      case BaraBackdropStyle.lounge:
        _paintDiamonds(canvas, size, paint, subtle: true);
    }
  }

  void _paintNeon(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 7; i++) {
      paint.color = (i.isEven ? primary : secondary).withValues(alpha: 0.08);
      final y = size.height * (0.12 + i * 0.13);
      canvas.drawArc(
        Rect.fromLTWH(-size.width * 0.18, y, size.width * 1.36, 120),
        math.pi * 1.06,
        math.pi * 0.74,
        false,
        paint..strokeWidth = 2.2,
      );
    }
    _paintConfetti(canvas, size, paint, density: 18);
  }

  void _paintConfetti(
    Canvas canvas,
    Size size,
    Paint paint, {
    required int density,
  }) {
    for (var i = 0; i < density; i++) {
      final x = ((i * 73) % 100) / 100 * size.width;
      final y = ((i * 41) % 100) / 100 * size.height;
      final color = switch (i % 3) {
        0 => primary,
        1 => secondary,
        _ => tertiary,
      };
      paint.color = color.withValues(alpha: 0.11);
      paint.strokeWidth = 2;
      final length = 8 + (i % 4) * 3;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((i % 8) * math.pi / 8);
      canvas.drawLine(Offset.zero, Offset(length.toDouble(), 0), paint);
      canvas.restore();
    }
  }

  void _paintArcade(Canvas canvas, Size size, Paint paint) {
    final step = size.width / 7;
    paint.strokeWidth = 1.2;
    for (var i = -2; i < 12; i++) {
      paint.color = (i.isEven ? primary : tertiary).withValues(alpha: 0.075);
      final path = Path()
        ..moveTo(i * step, 0)
        ..lineTo((i + 2) * step, size.height);
      canvas.drawPath(path, paint);
    }
    _paintConfetti(canvas, size, paint, density: 20);
  }

  void _paintWaves(Canvas canvas, Size size, Paint paint, {bool soft = false}) {
    paint.strokeWidth = soft ? 1.2 : 1.8;
    for (var row = 0; row < 9; row++) {
      paint.color = (row.isEven ? primary : secondary).withValues(
        alpha: soft ? 0.055 : 0.08,
      );
      final path = Path();
      final y = size.height * (0.08 + row * 0.12);
      path.moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 32) {
        path.lineTo(x, y + math.sin((x / 48) + row) * 10);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _paintDiamonds(
    Canvas canvas,
    Size size,
    Paint paint, {
    bool subtle = false,
  }) {
    paint.strokeWidth = 1.1;
    final alpha = subtle ? 0.045 : 0.07;
    for (var row = 0; row < 7; row++) {
      for (var col = 0; col < 5; col++) {
        final x = size.width * (0.1 + col * 0.23) + (row.isEven ? 18 : -10);
        final y = size.height * (0.08 + row * 0.15);
        final radius = 9.0 + ((row + col) % 3) * 5;
        paint.color = (col.isEven ? tertiary : primary).withValues(
          alpha: alpha,
        );
        final path = Path()
          ..moveTo(x, y - radius)
          ..lineTo(x + radius, y)
          ..lineTo(x, y + radius)
          ..lineTo(x - radius, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPatternPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.tertiary != tertiary;
  }
}
