import 'package:flutter/material.dart';
import 'base_storage_service.dart';
import 'storage_constants.dart';

class ColorStorageService extends BaseStorageService {
  // Default gradient colors for option items
  static const List<List<Color>> _defaultGradientColors = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)], // Red to Orange
    [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Teal to Green
    [Color(0xFF667eea), Color(0xFF764ba2)], // Blue to Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink to Red
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue to Cyan
    [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green to Cyan
    [Color(0xFFfa709a), Color(0xFFfee140)], // Pink to Yellow
    [Color(0xFF30cfd0), Color(0xFF91a7ff)], // Cyan to Purple
    [Color(0xFFa8edea), Color(0xFFfed6e3)], // Light Blue to Pink
    [Color(0xFFffecd2), Color(0xFFfcb69f)], // Cream to Peach
  ];

  // Default solid colors for roulette slices
  static const List<Color> _defaultSolidColors = [
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
  ];

  static Future<List<List<Color>>> get gradientColors => loadGradientColors();
  static Future<List<Color>> get solidColors => loadSolidColors();

  /// Save gradient color theme
  static Future<bool> saveGradientColors(
    List<List<Color>> gradientColors,
  ) async {
    final colorsData = gradientColors
        .map((gradient) => gradient.map((color) => color.value).toList())
        .toList();

    return await BaseStorageService.saveJson(
      StorageConstants.savedGradientColorsKey,
      colorsData,
    );
  }

  /// Load saved gradient colors or return defaults
  static Future<List<List<Color>>> loadGradientColors() async {
    try {
      final colorsData = await BaseStorageService.getJson(
        StorageConstants.savedGradientColorsKey,
      );

      if (colorsData == null) {
        return _defaultGradientColors;
      }

      return (colorsData as List<dynamic>)
          .map(
            (gradient) => (gradient as List<dynamic>)
                .map((colorValue) => Color(colorValue as int))
                .toList(),
          )
          .toList();
    } catch (e) {
      return _defaultGradientColors;
    }
  }

  /// Save solid color theme
  static Future<bool> saveSolidColors(List<Color> solidColors) async {
    final colorsData = solidColors.map((color) => color.value).toList();
    return await BaseStorageService.saveJson(
      StorageConstants.savedSolidColorsKey,
      colorsData,
    );
  }

  /// Load saved solid colors or return defaults
  static Future<List<Color>> loadSolidColors() async {
    try {
      final colorsData = await BaseStorageService.getJson(
        StorageConstants.savedSolidColorsKey,
      );

      if (colorsData == null) {
        return _defaultSolidColors;
      }

      return (colorsData as List<dynamic>)
          .map((colorValue) => Color(colorValue as int))
          .toList();
    } catch (e) {
      return _defaultSolidColors;
    }
  }

  /// Save both color themes at once
  static Future<bool> saveColorThemes({
    required List<List<Color>> gradientColors,
    required List<Color> solidColors,
  }) async {
    final futures = await Future.wait([
      saveGradientColors(gradientColors),
      saveSolidColors(solidColors),
    ]);

    return futures.every((success) => success);
  }

  /// Save whether to use gradient colors
  static Future<bool> saveUseGradient(bool useGradient) async {
    return await BaseStorageService.saveBool(
      StorageConstants.useGradientKey,
      useGradient,
    );
  }

  /// Get whether to use gradient colors (defaults to false)
  static Future<bool> getUseGradient() async {
    return await BaseStorageService.getBool(StorageConstants.useGradientKey) ??
        false;
  }

  /// Save the selected color theme index
  static Future<bool> saveColorTheme(int themeIndex) async {
    return await BaseStorageService.saveInt(
      StorageConstants.colorThemeKey,
      themeIndex,
    );
  }

  /// Get the selected color theme index (defaults to 0)
  static Future<int> getColorTheme() async {
    return await BaseStorageService.getInt(StorageConstants.colorThemeKey) ?? 0;
  }

  /// Save color preferences (colors and gradient setting)
  static Future<bool> saveColorPreferences({
    required List<List<Color>> gradientColors,
    required List<Color> solidColors,
    required bool useGradient,
  }) async {
    final futures = await Future.wait([
      saveGradientColors(gradientColors),
      saveSolidColors(solidColors),
      saveUseGradient(useGradient),
    ]);

    return futures.every((success) => success);
  }

  /// Get all color preferences
  static Future<Map<String, dynamic>> getColorPreferences() async {
    try {
      final futures = await Future.wait([
        loadGradientColors(),
        loadSolidColors(),
        getUseGradient(),
      ]);

      return {
        'gradientColors': futures[0] as List<List<Color>>,
        'solidColors': futures[1] as List<Color>,
        'useGradient': futures[2] as bool,
      };
    } catch (e) {
      return {
        'gradientColors': _defaultGradientColors,
        'solidColors': _defaultSolidColors,
        'useGradient': false,
      };
    }
  }

  /// Get gradient colors for a specific index
  static List<Color> getGradientColorsForIndexSync(
    int index, [
    List<List<Color>>? customColors,
  ]) {
    final colors = customColors ?? _defaultGradientColors;
    return colors[index % colors.length];
  }

  /// Get solid color for a specific index
  static Color getSolidColorForIndexSync(
    int index, [
    List<Color>? customColors,
  ]) {
    final colors = customColors ?? _defaultSolidColors;
    return colors[index % colors.length];
  }

  /// Clear all color preferences
  static Future<bool> clearColorPreferences() async {
    final futures = await Future.wait([
      BaseStorageService.remove(StorageConstants.savedGradientColorsKey),
      BaseStorageService.remove(StorageConstants.savedSolidColorsKey),
      BaseStorageService.remove(StorageConstants.useGradientKey),
      BaseStorageService.remove(StorageConstants.colorThemeKey),
    ]);

    return futures.every((success) => success);
  }
}
