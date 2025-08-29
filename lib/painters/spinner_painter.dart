import 'dart:math' as math;
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';
import 'package:characters/characters.dart';

class SpinnerPainter extends CustomPainter {
  final SpinnerModel spinnerModel;
  final double rotation;
  final Slice? selectedOption;
  final double? wheelSize;

  static const double spinnerBorderWidth = 5;

  SpinnerPainter({
    required this.spinnerModel,
    required this.rotation,
    this.selectedOption,
    this.wheelSize,
  });

  @override
  bool shouldRepaint(covariant SpinnerPainter oldDelegate) {
    return oldDelegate._slices != _slices ||
        oldDelegate.rotation != rotation ||
        oldDelegate.selectedOption != selectedOption ||
        oldDelegate.wheelSize != wheelSize;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final anglePerOption = 2 * math.pi / _slices.length;
    for (int i = 0; i < _slices.length; i++) {
      // Start from the top (-π/2) and add rotation
      final startAngle = (i * anglePerOption) - (math.pi / 2) + rotation;
      final sweepAngle = anglePerOption;

      _paintSlice(canvas, center, radius, startAngle, sweepAngle, i);
    }

    // Draw all slice borders after slices are painted
    _drawSliceBorders(canvas, center, radius, anglePerOption);

    // Draw outer circle border
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = spinnerBorderWidth;

    canvas.drawCircle(center, radius, outerBorderPaint);
  }

  void _paintSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    int sliceIndex,
  ) {
    final slicePaint = _createSlicePaint(sliceIndex, center, radius);
    final foregroundColor = spinnerModel.getCircularForegroundColor(sliceIndex);

    // Draw slice
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      slicePaint,
    );

    // Draw text - use the middle of the slice
    _drawText(
      canvas,
      _slices[sliceIndex],
      foregroundColor,
      center,
      radius,
      startAngle + sweepAngle / 2,
    );
  }

  void _drawSliceBorders(
    Canvas canvas,
    Offset center,
    double radius,
    double anglePerOption,
  ) {
    final sliceBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _calculateSliceBorderWidth();

    // Draw a border line for each slice
    for (int i = 0; i < _slices.length; i++) {
      final startAngle = (i * anglePerOption) - (math.pi / 2) + rotation;

      // Draw line from center to edge at the start angle
      final lineStartX = center.dx;
      final lineStartY = center.dy;
      final lineEndX = center.dx + radius * math.cos(startAngle);
      final lineEndY = center.dy + radius * math.sin(startAngle);

      canvas.drawLine(
        Offset(lineStartX, lineStartY),
        Offset(lineEndX, lineEndY),
        sliceBorderPaint,
      );
    }
  }

  double _calculateSliceBorderWidth() {
    final numSlices = _slices.length;
    if (numSlices <= 0) return 2.0; // Default fallback

    // Base width for 8 slices, scale inversely with number of slices
    // More slices = thinner borders, fewer slices = thicker borders
    final baseWidth = 3.0;
    final baseSlices = 8;
    final scaledWidth = baseWidth * (baseSlices / numSlices);

    // Clamp between 1.0 and 5.0 to keep borders reasonable
    return scaledWidth.clamp(1.0, 5.0);
  }

  Paint _createSlicePaint(int index, Offset center, double radius) {
    final color = spinnerModel.getCircularBackgroundColor(index);
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Color textColor,
    Offset center,
    double radius,
    double angle,
  ) {
    final textSpan = TextSpan(
      text: _truncateToFit(text, radius),
      style: TextStyle(
        color: textColor,
        fontSize: _calculateFontSize(),
        fontWeight: FontWeight.w900,
        fontFamily: 'Roboto', // Ensure a font that supports emojis is used
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout();

    // Calculate starting position (just inside border)
    final textStartRadius = radius - spinnerBorderWidth;
    final textStartX = center.dx + textStartRadius * math.cos(angle);
    final textStartY = center.dy + textStartRadius * math.sin(angle);

    canvas.save();
    canvas.translate(textStartX, textStartY);
    canvas.rotate(angle + math.pi);

    textPainter.paint(canvas, Offset(0, -textPainter.height / 2));

    canvas.restore();
  }

  String _truncateToFit(String fullText, double maxTextWidth) {
    if (fullText.isEmpty) return fullText;

    final textStyle = TextStyle(
      fontSize: _calculateFontSize(),
      fontWeight: FontWeight.w900,
      fontFamily: 'Roboto',
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Helper function to test if text fits
    bool textFits(String text) {
      try {
        textPainter.text = TextSpan(text: text, style: textStyle);
        textPainter.layout();
        return textPainter.width <= maxTextWidth;
      } catch (e) {
        return false;
      }
    }

    // Return full text if it fits
    if (textFits(fullText)) return fullText;

    // Binary search for the longest fitting substring
    final characters = fullText.characters.toList();
    int low = 0, high = characters.length;
    String result = '';

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (mid <= 0) {
        high = mid - 1;
        continue;
      }

      final candidate = characters.take(mid).join();
      if (textFits(candidate)) {
        result = candidate;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  double _calculateFontSize() {
    final numSlices = _slices.length;
    final textScale = (wheelSize ?? 300) / 300;

    // Keep size 20 for up to 12 slices
    if (numSlices <= 12) {
      return 20.0 * textScale;
    }

    // For every 4 more slices, reduce font size by 2
    final extraSlices = numSlices - 12;
    final reductions = (extraSlices / 6).floor();
    final fontSize = 20.0 - (reductions * 2.0);

    return fontSize.clamp(12.0, 20.0) * textScale;
  }

  List<String> get _slices =>
      spinnerModel.activeSlices.map((e) => e.text).toList();
}
