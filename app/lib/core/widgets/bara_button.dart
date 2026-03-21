import 'package:flutter/material.dart';

class BaraButton extends StatelessWidget {
  const BaraButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  }) : isPrimary = true;

  const BaraButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  }) : isPrimary = false;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;

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

    return isPrimary
        ? ElevatedButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}
