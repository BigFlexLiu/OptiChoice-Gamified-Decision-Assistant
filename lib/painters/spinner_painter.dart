import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpinnerPainter extends CustomPainter {
  final List<String> options;
  final double rotation;
  final String? selectedOption;
  final List<Color> colors;
  final double? wheelSize;

  SpinnerPainter({
    required this.options,
    required this.rotation,
    required this.colors,
    this.selectedOption,
    this.wheelSize,
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
    final color = _getSolidColorForIndex(index);
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  Color _getSolidColorForIndex(int index) {
    return colors[index % colors.length];
  }

  double _calculateFontSize() {
    if (wheelSize == null) return 14.0; // Default size

    // Scale font size based on wheel size
    // Assuming default wheel size of 300 corresponds to 14pt font
    final scaleFactor = wheelSize! / 200.0;
    final scaledSize = 14.0 * scaleFactor;

    // Clamp between 12 and 16
    return scaledSize.clamp(12.0, 20.0);
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
      fontSize: _calculateFontSize(),
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
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final truncatedText = _truncateToFit(text, textPainter, textStyle, radius);

    // Layout final text
    textPainter.text = TextSpan(text: truncatedText, style: textStyle);
    textPainter.layout();

    // Calculate starting position (just inside border)
    final textStartRadius = radius - 5;
    final textStartX = center.dx + textStartRadius * math.cos(angle);
    final textStartY = center.dy + textStartRadius * math.sin(angle);

    canvas.save();
    canvas.translate(textStartX, textStartY);
    canvas.rotate(angle + math.pi);

    textPainter.paint(canvas, Offset(0, -textPainter.height / 2));

    canvas.restore();
  }

  // Binary search for the longest substring that fits maxTextWidth
  String _truncateToFit(
    String fullText,
    TextPainter textPainter,
    TextStyle textStyle,
    double maxTextWidth,
  ) {
    int low = 0;
    int high = fullText.length;
    String result = '';

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final candidate = fullText.substring(0, mid);

      textPainter.text = TextSpan(text: candidate, style: textStyle);
      textPainter.layout();

      if (textPainter.width <= maxTextWidth) {
        result = candidate;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant SpinnerPainter oldDelegate) {
    return oldDelegate.options != options ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedOption != selectedOption ||
        oldDelegate.colors != colors ||
        oldDelegate.wheelSize != wheelSize;
  }
}
