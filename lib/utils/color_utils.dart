import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// Extension for List<Color> to provide value-based comparison methods
extension ColorListUtils on List<Color> {
  /// Checks if the list contains a color with the same ARGB value
  bool containsColorValue(Color color) {
    return any((c) => c.value == color.value);
  }

  /// Finds the index of a color with the same ARGB value
  int indexOfColorValue(Color color) {
    for (int i = 0; i < length; i++) {
      if (this[i].value == color.value) {
        return i;
      }
    }
    return -1;
  }

  /// Removes a color with the same ARGB value
  bool removeColorValue(Color color) {
    final index = indexOfColorValue(color);
    if (index != -1) {
      removeAt(index);
      return true;
    }
    return false;
  }

  /// Checks if two color lists have the same colors in the same order (by value)
  bool hasSameColorsInOrder(List<Color> other) {
    if (length != other.length) return false;

    for (int i = 0; i < length; i++) {
      if (this[i].value != other[i].value) {
        return false;
      }
    }
    return true;
  }
}

class ColorUtils {
  static List<int> colorToRgb(Color color) {
    return [color.red, color.green, color.blue];
  }

  static Color rgbToColor(List<int> rgb) {
    assert(rgb.length == 3);
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  static List<int> randomColor() {
    final rand = Random();
    return [rand.nextInt(256), rand.nextInt(256), rand.nextInt(256)];
  }

  static List<double> rgbToLab(List<int> rgb) {
    List<double> srgb = rgb.map((c) => c / 255.0).toList();
    srgb = srgb.map((c) {
      return (c <= 0.04045)
          ? (c / 12.92)
          : pow((c + 0.055) / 1.055, 2.4).toDouble();
    }).toList();

    double r = srgb[0], g = srgb[1], b = srgb[2];
    double x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    double y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    double z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    x /= 0.95047;
    y /= 1.00000;
    z /= 1.08883;

    List<double> xyz = [x, y, z].map((v) {
      return (v > 0.008856) ? pow(v, 1 / 3).toDouble() : (7.787 * v + 16 / 116);
    }).toList();

    double l = 116 * xyz[1] - 16;
    double a = 500 * (xyz[0] - xyz[1]);
    double bVal = 200 * (xyz[1] - xyz[2]);

    return [l, a, bVal];
  }

  static double wcagContrast(List<int> bg, List<int> fg) {
    double luminance(List<int> rgb) {
      double linear(double c) {
        c = c / 255;
        return (c <= 0.03928)
            ? (c / 12.92)
            : pow((c + 0.055) / 1.055, 2.4).toDouble();
      }

      double r = linear(rgb[0].toDouble());
      double g = linear(rgb[1].toDouble());
      double b = linear(rgb[2].toDouble());
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    double l1 = luminance(bg);
    double l2 = luminance(fg);
    double lighter = max(l1, l2);
    double darker = min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double luminanceDiff(List<int> rgb1, List<int> rgb2) {
    double y1 = 0.2126 * rgb1[0] + 0.7152 * rgb1[1] + 0.0722 * rgb1[2];
    double y2 = 0.2126 * rgb2[0] + 0.7152 * rgb2[1] + 0.0722 * rgb2[2];
    return (y1 - y2).abs();
  }

  static double deltaECIE2000(List<double> lab1, List<double> lab2) {
    double deltaL = lab1[0] - lab2[0];
    double deltaA = lab1[1] - lab2[1];
    double deltaB = lab1[2] - lab2[2];
    return sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB);
  }

  /// Returns: FgColorResult(color, deltaE, contrast)
  static FgColorResult findFgNearContrast7(Color bgColor) {
    final bgRgb = colorToRgb(bgColor);
    final bgLab = rgbToLab(bgRgb);
    final targetMin = 6.8;
    final targetMax = 7.2;
    final palette = [
      [0, 0, 0],
      [255, 255, 255],
      ...List.generate(200, (_) => randomColor()),
    ];

    List<Map<String, dynamic>> candidates = [];

    for (var fg in palette) {
      final fgLab = rgbToLab(fg);
      final delta = deltaECIE2000(bgLab, fgLab);
      final contrast = wcagContrast(bgRgb, fg);
      final lumDiff = luminanceDiff(bgRgb, fg);

      if (contrast >= targetMin &&
          contrast <= targetMax &&
          delta >= 40 &&
          delta <= 65 &&
          lumDiff >= 20) {
        candidates.add({'color': fg, 'delta': delta, 'contrast': contrast});
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort(
        (a, b) =>
            (a['contrast'] - 7.0).abs().compareTo((b['contrast'] - 7.0).abs()),
      );
      var c = candidates.first;
      return FgColorResult(
        color: rgbToColor(c['color']),
        deltaE: c['delta'],
        contrast: c['contrast'],
      );
    }

    // Fallback
    List<Map<String, dynamic>> softCandidates = [];
    for (var fg in palette) {
      final fgLab = rgbToLab(fg);
      final delta = deltaECIE2000(bgLab, fgLab);
      final contrast = wcagContrast(bgRgb, fg);
      final lumDiff = luminanceDiff(bgRgb, fg);

      if (contrast >= 4.5 && delta >= 30 && lumDiff >= 20) {
        softCandidates.add({'color': fg, 'delta': delta, 'contrast': contrast});
      }
    }

    if (softCandidates.isNotEmpty) {
      softCandidates.sort(
        (a, b) =>
            (a['contrast'] - 7.0).abs().compareTo((b['contrast'] - 7.0).abs()),
      );
      var c = softCandidates.first;
      return FgColorResult(
        color: rgbToColor(c['color']),
        deltaE: c['delta'],
        contrast: c['contrast'],
      );
    }

    // Final fallback
    List<int> bestColor = palette.reduce(
      (a, b) => wcagContrast(bgRgb, a) > wcagContrast(bgRgb, b) ? a : b,
    );
    return FgColorResult(
      color: rgbToColor(bestColor),
      deltaE: deltaECIE2000(bgLab, rgbToLab(bestColor)),
      contrast: wcagContrast(bgRgb, bestColor),
    );
  }

  /// Convenience method to get just the Color.
  static Color bestFgColorForBg(Color bgColor) {
    return findFgNearContrast7(bgColor).color;
  }
}

class FgColorResult {
  final Color color;
  final double deltaE;
  final double contrast;

  FgColorResult({
    required this.color,
    required this.deltaE,
    required this.contrast,
  });

  @override
  String toString() {
    return 'FgColorResult(color: $color, ΔE: ${deltaE.toStringAsFixed(2)}, contrast: ${contrast.toStringAsFixed(2)})';
  }
}

// Extension for individual Color comparison and serialization
extension ColorExtensions on Color {
  /// Check if two colors have the same ARGB value
  bool hasSameValueAs(Color other) {
    return value == other.value;
  }

  /// Convert color to a serializable map
  Map<String, dynamic> toMap() {
    return {'value': value};
  }

  /// Create color from serializable map
  static Color fromMap(Map<String, dynamic> map) {
    return Color(map['value']);
  }

  /// Convert color to hex string
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Create color from hex string
  static Color fromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse(hexCode, radix: 16));
  }
}

// Helper class for color list serialization
class ColorListSerializer {
  /// Convert color list to serializable list
  static List<Map<String, dynamic>> toMapList(List<Color> colors) {
    return colors.map((color) => color.toMap()).toList();
  }

  /// Create color list from serializable list
  static List<Color> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => ColorExtensions.fromMap(map)).toList();
  }

  /// Convert color list to hex strings
  static List<String> toHexList(List<Color> colors) {
    return colors.map((color) => color.toHex()).toList();
  }

  /// Create color list from hex strings
  static List<Color> fromHexList(List<String> hexList) {
    return hexList.map((hex) => ColorExtensions.fromHex(hex)).toList();
  }
}
