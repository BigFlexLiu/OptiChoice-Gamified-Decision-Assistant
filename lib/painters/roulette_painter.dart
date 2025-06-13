import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../enums/roulette_paint_mode.dart';

class RoulettePainter extends CustomPainter {
  final List<String> options;
  final double rotation;
  final String? selectedOption;
  final RoulettePaintMode paintMode;
  final List<List<Color>> gradientColors;
  final List<Color> solidColors;

  RoulettePainter({
    required this.options,
    required this.rotation,
    required this.paintMode,
    required this.gradientColors,
    required this.solidColors,
    this.selectedOption,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw outer border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, borderPaint);

    final anglePerOption = 2 * math.pi / options.length;
    for (int i = 0; i < options.length; i++) {
      // Start from the top (-π/2) and add rotation
      final startAngle = (i * anglePerOption) - (math.pi / 2) + rotation;
      final sweepAngle = anglePerOption;

      // Create slice paint based on mode
      final slicePaint = _createSlicePaint(i, center, radius);

      // Draw slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Draw slice borders
      final sliceBorderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        startAngle,
        sweepAngle,
        true,
        sliceBorderPaint,
      );

      // Draw text - use the middle of the slice
      _drawText(
        canvas,
        options[i],
        center,
        radius,
        startAngle + sweepAngle / 2,
      );
    }
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, centerPaint);

    final centerBorderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 20, centerBorderPaint);
  }

  Paint _createSlicePaint(int index, Offset center, double radius) {
    switch (paintMode) {
      case RoulettePaintMode.gradient:
        final colors = _getGradientColorsForIndex(index);
        return Paint()
          ..shader = RadialGradient(
            colors: colors,
          ).createShader(Rect.fromCircle(center: center, radius: radius));

      case RoulettePaintMode.solid:
        final color = _getSolidColorForIndex(index);
        return Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    }
  }

  List<Color> _getGradientColorsForIndex(int index) {
    return gradientColors[index % gradientColors.length];
  }

  Color _getSolidColorForIndex(int index) {
    return solidColors[index % solidColors.length];
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double angle,
  ) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withValues(alpha: 0.7),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    // Calculate text position - place it at 65% of the radius from center
    final textRadius = radius * 0.65;

    // Calculate position using the angle directly
    final textX = center.dx + textRadius * math.cos(angle);
    final textY = center.dy + textRadius * math.sin(angle);

    canvas.save();
    canvas.translate(textX, textY);

    // Calculate rotation angle for vertical text
    // Use the angle pointing outward from center and add π/2 for vertical orientation
    double textRotation = angle + math.pi;

    canvas.rotate(textRotation);

    // Draw text centered at the calculated position
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RoulettePainter oldDelegate) {
    return oldDelegate.options != options ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedOption != selectedOption ||
        oldDelegate.paintMode != paintMode ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.solidColors != solidColors;
  }
}
