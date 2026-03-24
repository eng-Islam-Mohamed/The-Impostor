import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:flutter/material.dart';

class GlowCard extends StatelessWidget {
  const GlowCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.isSelected = false,
    this.playSound = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool isSelected;
  final bool playSound;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colorScheme.surface.withValues(alpha: 0.88),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
          ],
        ),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.55)
              : colorScheme.outline.withValues(alpha: 0.16),
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isSelected ? 0.18 : 0.06),
            blurRadius: isSelected ? 30 : 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap == null
              ? null
              : () {
                  if (playSound) {
                    AppAudio.instance.playSoftTap();
                  }
                  onTap?.call();
                },
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
