import 'package:flutter/material.dart';
import '../painters/solid_roulette_painter.dart';

class SolidRouletteWheel extends StatelessWidget {
  final List<String> options;
  final double rotation;
  final String? selectedOption;
  final double size;

  const SolidRouletteWheel({
    super.key,
    required this.options,
    this.rotation = 0.0,
    this.selectedOption,
    this.size = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: SolidRoulettePainter(
          options: options,
          rotation: rotation,
          selectedOption: selectedOption,
        ),
        size: Size(size, size),
      ),
    );
  }
}
