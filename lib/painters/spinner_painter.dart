import 'dart:math' as math;
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerPainter extends CustomPainter {
  final SpinnerModel spinnerModel;
  final double rotation;
  final SpinnerOption? selectedOption;
  final double? wheelSize;

  SpinnerPainter({
    required this.spinnerModel,
    required this.rotation,
    this.selectedOption,
    this.wheelSize,
  });

  List<String> get options => spinnerModel.options.map((e) => e.text).toList();

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final anglePerOption = 2 * math.pi / options.length;
    for (int i = 0; i < options.length; i++) {
      // Start from the top (-π/2) and add rotation
      final startAngle = (i * anglePerOption) - (math.pi / 2) + rotation;
      final sweepAngle = anglePerOption;

      final slicePaint = _createSlicePaint(i, center, radius);
      final foregroundColor = spinnerModel.getCircularForegroundColor(i);

      // Draw slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        slicePaint,
      );

      // Draw slice borders
      final sliceBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        sliceBorderPaint,
      );

      // Draw text - use the middle of the slice
      _drawText(
        canvas,
        options[i],
        foregroundColor,
        center,
        radius,
        startAngle + sweepAngle / 2,
      );
    }
  }

  Paint _createSlicePaint(int index, Offset center, double radius) {
    final color = spinnerModel.getCircularBackgroundColor(index);
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
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
    Color textColor,
    Offset center,
    double radius,
    double angle,
  ) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: _calculateFontSize(),
      fontWeight: FontWeight.w900,
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
        oldDelegate.wheelSize != wheelSize;
  }
}
