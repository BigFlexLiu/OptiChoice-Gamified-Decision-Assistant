import 'package:decision_spin/storage/color_storage_service.dart';
import 'package:decision_spin/storage/migration_service.dart';
import 'package:decision_spin/storage/roulette_storage_service.dart';
import 'package:flutter/material.dart';

/// Main storage service that provides a unified interface
/// Delegates to specialized storage services
class OptionsStorageService {
  /// Initialize the storage service and perform any necessary migrations
  static Future<void> initialize() async {
    await MigrationService.performMigrations();
  }

  // Roulette management methods - delegate to RouletteStorageService
  static Future<Map<String, List<String>>> loadAllRoulettes() =>
      RouletteStorageService.loadAllRoulettes();

  static Future<bool> saveAllRoulettes(Map<String, List<String>> roulettes) =>
      RouletteStorageService.saveAllRoulettes(roulettes);

  static Future<List<String>> loadOptions() =>
      RouletteStorageService.loadOptions();

  static Future<List<String>> loadRouletteOptions(String rouletteName) =>
      RouletteStorageService.loadRouletteOptions(rouletteName);

  static Future<bool> saveOptions(List<String> options) =>
      RouletteStorageService.saveOptions(options);

  static Future<bool> saveRouletteOptions(
    String rouletteName,
    List<String> options,
  ) => RouletteStorageService.saveRouletteOptions(rouletteName, options);

  static Future<bool> createRoulette(String name, List<String> options) =>
      RouletteStorageService.createRoulette(name, options);

  static Future<bool> deleteRoulette(String name) =>
      RouletteStorageService.deleteRoulette(name);

  static Future<bool> renameRoulette(String oldName, String newName) =>
      RouletteStorageService.renameRoulette(oldName, newName);

  static Future<String> getActiveRoulette() =>
      RouletteStorageService.getActiveRoulette();

  static Future<bool> setActiveRoulette(String rouletteName) =>
      RouletteStorageService.setActiveRoulette(rouletteName);

  static Future<List<String>> getRouletteNames() =>
      RouletteStorageService.getRouletteNames();

  static Future<bool> rouletteExists(String name) =>
      RouletteStorageService.rouletteExists(name);

  static Future<bool> duplicateRoulette(String originalName, String newName) =>
      RouletteStorageService.duplicateRoulette(originalName, newName);

  static Future<bool> clearAllRoulettes() =>
      RouletteStorageService.clearAllRoulettes();

  static Future<bool> resetToDefaults() =>
      RouletteStorageService.resetToDefaults();

  static Future<bool> resetRouletteToDefaults(String rouletteName) =>
      RouletteStorageService.resetRouletteToDefaults(rouletteName);

  static Future<void> saveRouletteOrder(List<String> orderedNames) =>
      RouletteStorageService.saveRouletteOrder(orderedNames);

  // Color management methods - delegate to ColorStorageService
  static Future<bool> saveGradientColors(List<List<Color>> gradientColors) =>
      ColorStorageService.saveGradientColors(gradientColors);

  static Future<List<List<Color>>> loadGradientColors() =>
      ColorStorageService.loadGradientColors();

  static Future<bool> saveSolidColors(List<Color> solidColors) =>
      ColorStorageService.saveSolidColors(solidColors);

  static Future<List<Color>> loadSolidColors() =>
      ColorStorageService.loadSolidColors();

  static Future<bool> saveColorThemes({
    required List<List<Color>> gradientColors,
    required List<Color> solidColors,
  }) => ColorStorageService.saveColorThemes(
    gradientColors: gradientColors,
    solidColors: solidColors,
  );

  static Future<bool> saveUseGradient(bool useGradient) =>
      ColorStorageService.saveUseGradient(useGradient);

  static Future<bool> getUseGradient() => ColorStorageService.getUseGradient();

  static Future<bool> saveColorTheme(int themeIndex) =>
      ColorStorageService.saveColorTheme(themeIndex);

  static Future<int> getColorTheme() => ColorStorageService.getColorTheme();

  static Future<bool> saveColorPreferences({
    required List<List<Color>> gradientColors,
    required List<Color> solidColors,
    required bool useGradient,
  }) => ColorStorageService.saveColorPreferences(
    gradientColors: gradientColors,
    solidColors: solidColors,
    useGradient: useGradient,
  );

  static Future<Map<String, dynamic>> getColorPreferences() =>
      ColorStorageService.getColorPreferences();

  static List<Color> getGradientColorsForIndexSync(
    int index, [
    List<List<Color>>? customColors,
  ]) => ColorStorageService.getGradientColorsForIndexSync(index, customColors);

  static Color getSolidColorForIndexSync(
    int index, [
    List<Color>? customColors,
  ]) => ColorStorageService.getSolidColorForIndexSync(index, customColors);

  // Utility methods that use saved colors
  static Future<dynamic> getColorsForIndex(int index) async {
    final useGradient = await getUseGradient();

    if (useGradient) {
      final gradientColors = await loadGradientColors();
      return gradientColors[index % gradientColors.length];
    } else {
      final solidColors = await loadSolidColors();
      return solidColors[index % solidColors.length];
    }
  }

  static Future<List<Color>> getGradientColorsForIndex(int index) async {
    final gradientColors = await loadGradientColors();
    return gradientColors[index % gradientColors.length];
  }

  static Future<Color> getSolidColorForIndex(int index) async {
    final solidColors = await loadSolidColors();
    return solidColors[index % solidColors.length];
  }

  /// Clear all data including color preferences
  static Future<bool> clearAllData() async {
    final futures = await Future.wait([
      RouletteStorageService.clearAllRoulettes(),
      ColorStorageService.clearColorPreferences(),
    ]);

    return futures.every((success) => success);
  }

  /// Reset color preferences to defaults
  static Future<bool> resetColorPreferences() =>
      ColorStorageService.clearColorPreferences();

  /// Migrate old data
  static Future<bool> migrateOldData() => MigrationService.migrateOldData();
}
