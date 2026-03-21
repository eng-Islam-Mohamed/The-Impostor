import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    required this.index,
    required this.label,
    this.radius = 24,
    super.key,
  });

  final int index;
  final String label;
  final double radius;

  static const _colors = [
    Color(0xFF0F8F78),
    Color(0xFFF06A5F),
    Color(0xFF6D7CF5),
    Color(0xFFD6B36E),
    Color(0xFF5D6A7D),
    Color(0xFF43C0A4),
    Color(0xFFB768E6),
    Color(0xFFEE925B),
  ];

  @override
  Widget build(BuildContext context) {
    final background = _colors[index % _colors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
