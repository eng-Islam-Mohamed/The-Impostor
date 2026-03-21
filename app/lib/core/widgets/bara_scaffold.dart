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
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
