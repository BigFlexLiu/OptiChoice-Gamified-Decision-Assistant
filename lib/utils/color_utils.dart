import 'dart:math';
import 'package:flutter/material.dart';

// Extension for List<Color> to provide value-based comparison methods
extension ColorListUtils on List<Color> {
  /// Checks if the list contains a color with the same ARGB value
  bool containsColorValue(Color color) {
    return any((c) => c.toARGB32() == color.toARGB32());
  }

  /// Finds the index of a color with the same ARGB value
  int indexOfColorValue(Color color) {
    for (int i = 0; i < length; i++) {
      if (this[i].toARGB32() == color.toARGB32()) {
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
      if (this[i].toARGB32() != other[i].toARGB32()) {
        return false;
      }
    }
    return true;
  }
}

class ColorUtils {
  /// Convenience method to get just the Color.
  static Color bestFgColorForBg(Color bgColor) {
    return bgColor.getContrastingTextColor();
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
    return toARGB32() == other.toARGB32();
  }

  /// Convert color to a serializable map
  Map<String, dynamic> toMap() {
    return {'value': toARGB32()};
  }

  /// Create color from serializable map
  static Color fromMap(Map<String, dynamic> map) {
    return Color(map['value']);
  }

  /// Convert color to hex string
  String toHex() {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Create color from hex string
  static Color fromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse(hexCode, radix: 16));
  }

  /// Returns either black or white depending on which provides better contrast
  /// against this color. Useful for text overlays on colored backgrounds.
  Color getContrastingTextColor() {
    // Calculate luminance using the same formula as in ColorUtils.wcagContrast
    double linear(double c) {
      c = c / 255;
      return (c <= 0.03928)
          ? (c / 12.92)
          : pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    double r = linear(this.r * 255);
    double g = linear(this.g * 255);
    double b = linear(this.b * 255);
    double luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;

    // If luminance is greater than 0.5, use black text, otherwise use white
    // This threshold can be adjusted for different visual preferences
    return luminance > 0.5 ? Colors.black : Colors.white;
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
