import 'dart:math' as math;
import 'package:flutter/material.dart';

class SolidRoulettePainter extends CustomPainter {
  final List<String> options;
  final double rotation;
  final String? selectedOption;

  SolidRoulettePainter({
    required this.options,
    required this.rotation,
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
      final startAngle = i * anglePerOption + rotation;
      final sweepAngle = anglePerOption;

      // Get solid color for this slice
      final color = [
        Color(0xFFFF6B6B), // Red
        Color(0xFF4ECDC4), // Teal
        Color(0xFF667eea), // Blue
        Color(0xFFf093fb), // Pink
        Color(0xFF4facfe), // Light Blue
        Color(0xFF43e97b), // Green
        Color(0xFFfa709a), // Rose
        Color(0xFF30cfd0), // Cyan
        Color(0xFFa8edea), // Light Teal
        Color(0xFFffecd2), // Cream
        Color(0xFFFF8E53), // Orange
        Color(0xFF44A08D), // Dark Green
        Color(0xFF764ba2), // Purple
        Color(0xFFf5576c), // Dark Pink
        Color(0xFF00f2fe), // Bright Cyan
        Color(0xFF38f9d7), // Mint
        Color(0xFFfee140), // Yellow
        Color(0xFF91a7ff), // Lavender
        Color(0xFFfed6e3), // Light Pink
        Color(0xFFfcb69f), // Peach
      ][i];

      // Highlight selected option
      final isSelected = selectedOption != null && options[i] == selectedOption;
      final sliceColor = isSelected ? color.withValues(alpha: 0.8) : color;

      // Draw slice
      final slicePaint = Paint()
        ..color = sliceColor
        ..style = PaintingStyle.fill;

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

      // Draw text
      _drawText(
        canvas,
        options[i],
        center,
        radius,
        startAngle + sweepAngle / 2,
        isSelected,
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

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double angle,
    bool isSelected,
  ) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: isSelected ? 16 : 14,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

    // Calculate text position
    final textRadius = radius * 0.7;
    final textX = center.dx + textRadius * math.cos(angle - math.pi / 2);
    final textY = center.dy + textRadius * math.sin(angle - math.pi / 2);

    // Rotate text to be readable
    canvas.save();
    canvas.translate(textX, textY);

    double textAngle = angle;
    if (textAngle > math.pi / 2 && textAngle < 3 * math.pi / 2) {
      textAngle += math.pi;
    }

    canvas.rotate(textAngle - math.pi / 2);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SolidRoulettePainter oldDelegate) {
    return oldDelegate.options != options ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedOption != selectedOption;
  }
}
