import 'dart:math' as math;

import 'package:flutter/material.dart';

class RoulettePainter extends CustomPainter {
  final List<String> options;
  final List<Color> Function(int) getGradientColors;

  RoulettePainter(this.options, this.getGradientColors);

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = (2 * math.pi) / options.length;

    final paint = Paint()..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3;

    final innerStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;

    // Draw sections
    for (int i = 0; i < options.length; i++) {
      final gradientColors = getGradientColors(i);

      // Create gradient for this section
      final gradient = SweepGradient(
        colors: [gradientColors[0], gradientColors[1], gradientColors[0]],
        stops: [0.0, 0.5, 1.0],
        startAngle: i * sectionAngle - math.pi / 2,
        endAngle: (i + 1) * sectionAngle - math.pi / 2,
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

      final startAngle = i * sectionAngle - math.pi / 2;

      // Draw main section
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw outer border
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        strokePaint,
      );

      // Draw inner highlight
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.9),
        startAngle,
        sectionAngle,
        true,
        innerStrokePaint,
      );

      // Draw text with better styling
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.65;
      final textCenter = Offset(
        center.dx + textRadius * math.cos(textAngle),
        center.dy + textRadius * math.sin(textAngle),
      );

      // Calculate optimal font size based on text length and section size
      double fontSize = 16;
      if (options[i].length > 8) fontSize = 12;
      if (options[i].length > 12) fontSize = 10;

      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                color: Colors.black.withOpacity(0.8),
                blurRadius: 4,
              ),
              Shadow(
                offset: Offset(0, 0),
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(textCenter.dx, textCenter.dy);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Add a subtle inner rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.2, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
