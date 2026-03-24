import 'package:bara_alsalfa/core/audio/app_audio.dart';
import 'package:flutter/material.dart';

class BaraButton extends StatelessWidget {
  const BaraButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.playSound = true,
    super.key,
  }) : isPrimary = true;

  const BaraButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.playSound = true,
    super.key,
  }) : isPrimary = false;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool playSound;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (icon != null) ...[
          const SizedBox(width: 10),
          Icon(icon, size: 20),
        ],
      ],
    );

    final callback = onPressed == null
        ? null
        : () {
            if (playSound) {
              AppAudio.instance.playSoftTap();
            }
            onPressed?.call();
          };

    return isPrimary
        ? ElevatedButton(onPressed: callback, child: child)
        : OutlinedButton(onPressed: callback, child: child);
  }
}
