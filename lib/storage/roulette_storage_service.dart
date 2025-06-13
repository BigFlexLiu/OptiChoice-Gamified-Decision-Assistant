import 'package:uuid/uuid.dart';
import 'base_storage_service.dart';
import 'storage_constants.dart';
import 'roulette_wheel_model.dart';
import '../views/roulette_manager.dart';
import '../enums/roulette_paint_mode.dart';
import 'package:flutter/material.dart';

class RouletteStorageService extends BaseStorageService {
  // Cache for all roulettes data
  static Map<String, RouletteWheelModel>? _cachedRoulettes;
  static String? _cachedActiveRouletteId;
  static const _uuid = Uuid();

  /// Internal method to load all roulettes from storage
  static Future<Map<String, RouletteWheelModel>>
  _loadAllRoulettesFromStorage() async {
    try {
      final roulettesData = await BaseStorageService.getJson(
        StorageConstants.roulettesKey,
      );

      if (roulettesData == null) {
        // Create default roulette if none exist
        final defaultRoulette = _createDefaultRouletteModel();
        final defaultRoulettes = {defaultRoulette.id: defaultRoulette};
        await _saveAllRoulettesToStorage(defaultRoulettes);
        await _setActiveRouletteInStorage(defaultRoulette.id);
        return Map.from(defaultRoulettes);
      }

      final roulettesMap = Map<String, dynamic>.from(roulettesData);
      return roulettesMap.map(
        (key, value) => MapEntry(key, RouletteWheelModel.fromJson(value)),
      );
    } catch (e) {
      // Return default roulette if there's an error
      final defaultRoulette = _createDefaultRouletteModel();
      final defaultRoulettes = {defaultRoulette.id: defaultRoulette};
      await _saveAllRoulettesToStorage(defaultRoulettes);
      await _setActiveRouletteInStorage(defaultRoulette.id);
      return defaultRoulettes;
    }
  }

  /// Create default roulette model
  static RouletteWheelModel _createDefaultRouletteModel() {
    return RouletteWheelModel(
      id: _uuid.v4(),
      name: StorageConstants.defaultRouletteName,
      options: StorageConstants.defaultOptions
          .map((text) => RouletteOption(text: text, weight: 1.0))
          .toList(),
      colorThemeIndex: 0,
      gradientColors: [
        [Colors.red, Colors.orange],
        [Colors.blue, Colors.cyan],
        [Colors.green, Colors.lime],
        [Colors.purple, Colors.pink],
        [Colors.orange, Colors.yellow],
        [Colors.teal, Colors.blue],
      ],
      solidColors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ],
      paintMode: RoulettePaintMode.gradient,
    );
  }

  /// Internal method to save all roulettes to storage
  static Future<bool> _saveAllRoulettesToStorage(
    Map<String, RouletteWheelModel> roulettes,
  ) async {
    final jsonData = roulettes.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    return await BaseStorageService.saveJson(
      StorageConstants.roulettesKey,
      jsonData,
    );
  }

  /// Internal method to get active roulette ID from storage
  static Future<String?> _getActiveRouletteFromStorage() async {
    return await BaseStorageService.getString(
      StorageConstants.activeRouletteKey,
    );
  }

  /// Internal method to set active roulette ID in storage
  static Future<bool> _setActiveRouletteInStorage(String rouletteId) async {
    return await BaseStorageService.saveString(
      StorageConstants.activeRouletteKey,
      rouletteId,
    );
  }

  /// Load all roulettes with caching
  static Future<Map<String, RouletteWheelModel>> loadAllRoulettes() async {
    _cachedRoulettes ??= await _loadAllRoulettesFromStorage();
    // Return a copy to prevent external modifications
    return Map<String, RouletteWheelModel>.from(_cachedRoulettes!);
  }

  /// Save all roulettes and update cache
  static Future<bool> saveAllRoulettes(
    Map<String, RouletteWheelModel> roulettes,
  ) async {
    // Update timestamps
    final updatedRoulettes = roulettes.map((key, roulette) {
      roulette.updatedAt = DateTime.now();
      return MapEntry(key, roulette);
    });

    final success = await _saveAllRoulettesToStorage(updatedRoulettes);
    if (success) {
      // Update cache with a copy
      _cachedRoulettes = Map<String, RouletteWheelModel>.from(updatedRoulettes);
    }
    return success;
  }

  /// Load the active roulette model
  static Future<RouletteWheelModel?> loadActiveRoulette() async {
    final activeId = await getActiveRouletteId();
    if (activeId == null) return null;

    final allRoulettes = await loadAllRoulettes();
    return allRoulettes[activeId];
  }

  /// Load a specific roulette model by ID
  static Future<RouletteWheelModel?> loadRouletteById(String id) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes[id];
  }

  /// Save a roulette model
  static Future<bool> saveRoulette(RouletteWheelModel roulette) async {
    // Use cached data if available
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    roulette.updatedAt = DateTime.now();
    allRoulettes[roulette.id] = roulette;
    return await saveAllRoulettes(allRoulettes);
  }

  /// Create a new roulette
  static Future<RouletteWheelModel?> createRoulette(
    String name,
    List<RouletteOption> options, {
    int colorThemeIndex = 0,
    RoulettePaintMode paintMode = RoulettePaintMode.gradient,
  }) async {
    // Use cached data if available
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    // Check if name already exists
    final existingNames = allRoulettes.values.map((r) => r.name).toSet();
    if (existingNames.contains(name)) {
      return null; // Roulette with this name already exists
    }

    final newRoulette = RouletteWheelModel(
      id: _uuid.v4(),
      name: name,
      options: options,
      colorThemeIndex: colorThemeIndex,
      gradientColors: [
        [Colors.red, Colors.orange],
        [Colors.blue, Colors.cyan],
        [Colors.green, Colors.lime],
        [Colors.purple, Colors.pink],
        [Colors.orange, Colors.yellow],
        [Colors.teal, Colors.blue],
      ],
      solidColors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ],
      paintMode: paintMode,
    );

    allRoulettes[newRoulette.id] = newRoulette;
    final success = await saveAllRoulettes(allRoulettes);

    if (success) {
      await setActiveRouletteId(newRoulette.id);
      return newRoulette;
    }

    return null;
  }

  /// Delete a roulette
  static Future<bool> deleteRoulette(String id) async {
    // Use cached data if available
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    if (allRoulettes.length <= 1) {
      return false; // Cannot delete the last roulette
    }

    if (!allRoulettes.containsKey(id)) {
      return false; // Roulette doesn't exist
    }

    allRoulettes.remove(id);
    final success = await saveAllRoulettes(allRoulettes);

    // If the deleted roulette was active, set the first available as active
    final activeId = await getActiveRouletteId();
    if (activeId == id) {
      final firstRouletteId = allRoulettes.keys.first;
      await setActiveRouletteId(firstRouletteId);
    }

    return success;
  }

  /// Rename a roulette
  static Future<bool> renameRoulette(String id, String newName) async {
    // Use cached data if available
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    if (!allRoulettes.containsKey(id)) {
      return false; // Roulette doesn't exist
    }

    // Check if new name already exists
    final existingNames = allRoulettes.values
        .where((r) => r.id != id)
        .map((r) => r.name)
        .toSet();
    if (existingNames.contains(newName)) {
      return false; // New name already exists
    }

    final roulette = allRoulettes[id]!;
    roulette.name = newName;
    roulette.updatedAt = DateTime.now();

    return await saveAllRoulettes(allRoulettes);
  }

  /// Get the active roulette ID with caching
  static Future<String?> getActiveRouletteId() async {
    if (_cachedActiveRouletteId == null) {
      _cachedActiveRouletteId = await _getActiveRouletteFromStorage();

      // If no active roulette is set, set the first available one
      if (_cachedActiveRouletteId == null) {
        final allRoulettes = await loadAllRoulettes();
        if (allRoulettes.isNotEmpty) {
          _cachedActiveRouletteId = allRoulettes.keys.first;
          await _setActiveRouletteInStorage(_cachedActiveRouletteId!);
        }
      }
    }
    return _cachedActiveRouletteId;
  }

  /// Set the active roulette and update cache
  static Future<bool> setActiveRouletteId(String rouletteId) async {
    final success = await _setActiveRouletteInStorage(rouletteId);
    if (success) {
      _cachedActiveRouletteId = rouletteId;
    }
    return success;
  }

  /// Get list of all roulette models
  static Future<List<RouletteWheelModel>> getAllRoulettes() async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.values.toList();
  }

  /// Get list of all roulette names with their IDs
  static Future<Map<String, String>> getRouletteNamesWithIds() async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.map((id, roulette) => MapEntry(roulette.name, id));
  }

  /// Check if a roulette name exists
  static Future<bool> rouletteNameExists(String name) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.values.any((roulette) => roulette.name == name);
  }

  /// Check if a roulette ID exists
  static Future<bool> rouletteIdExists(String id) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.containsKey(id);
  }

  /// Duplicate a roulette
  static Future<RouletteWheelModel?> duplicateRoulette(
    String originalId,
    String newName,
  ) async {
    // Use cached data if available
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    if (!allRoulettes.containsKey(originalId)) {
      return null; // Original roulette doesn't exist
    }

    // Check if new name already exists
    final existingNames = allRoulettes.values.map((r) => r.name).toSet();
    if (existingNames.contains(newName)) {
      return null; // New name already exists
    }

    final originalRoulette = allRoulettes[originalId]!;
    final duplicatedRoulette = RouletteWheelModel(
      id: _uuid.v4(),
      name: newName,
      options: originalRoulette.options
          .map(
            (option) =>
                RouletteOption(text: option.text, weight: option.weight),
          )
          .toList(),
      colorThemeIndex: originalRoulette.colorThemeIndex,
      gradientColors: originalRoulette.gradientColors
          .map((colorList) => List<Color>.from(colorList))
          .toList(),
      solidColors: List<Color>.from(originalRoulette.solidColors),
      paintMode: originalRoulette.paintMode,
    );

    allRoulettes[duplicatedRoulette.id] = duplicatedRoulette;
    final success = await saveAllRoulettes(allRoulettes);

    return success ? duplicatedRoulette : null;
  }

  /// Clear all roulettes and reset to default
  static Future<bool> clearAllRoulettes() async {
    try {
      await BaseStorageService.remove(StorageConstants.roulettesKey);
      await BaseStorageService.remove(StorageConstants.activeRouletteKey);

      // Recreate default roulette
      final defaultRoulette = _createDefaultRouletteModel();
      final defaultRoulettes = {defaultRoulette.id: defaultRoulette};
      await saveAllRoulettes(defaultRoulettes);
      await setActiveRouletteId(defaultRoulette.id);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset active roulette to defaults
  static Future<bool> resetActiveRouletteToDefaults() async {
    final activeId = await getActiveRouletteId();
    if (activeId == null) return false;

    return await resetRouletteToDefaults(activeId);
  }

  /// Reset a specific roulette to defaults
  static Future<bool> resetRouletteToDefaults(String id) async {
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteWheelModel>.from(_cachedRoulettes!)
        : await loadAllRoulettes();

    if (!allRoulettes.containsKey(id)) {
      return false; // Roulette doesn't exist
    }

    final roulette = allRoulettes[id]!;
    roulette.options = StorageConstants.defaultOptions
        .map((text) => RouletteOption(text: text, weight: 1.0))
        .toList();
    roulette.updatedAt = DateTime.now();

    return await saveAllRoulettes(allRoulettes);
  }

  /// Save roulette order
  static Future<void> saveRouletteOrder(List<String> orderedIds) async {
    try {
      // Load current roulettes (uses cache if available)
      final currentRoulettes = await loadAllRoulettes();

      // Create a new ordered map
      final orderedRoulettes = <String, RouletteWheelModel>{};

      // Add roulettes in the specified order
      for (final id in orderedIds) {
        if (currentRoulettes.containsKey(id)) {
          orderedRoulettes[id] = currentRoulettes[id]!;
        }
      }

      // Add any missing roulettes at the end (safety check)
      for (final entry in currentRoulettes.entries) {
        if (!orderedRoulettes.containsKey(entry.key)) {
          orderedRoulettes[entry.key] = entry.value;
        }
      }

      // Save the reordered roulettes
      await saveAllRoulettes(orderedRoulettes);
    } catch (e) {
      // If reordering fails, silently continue - the original order will be preserved
      debugPrint('Failed to save roulette order: $e');
    }
  }

  /// Clear cache - useful for testing or when you need to force reload from storage
  static void clearCache() {
    _cachedRoulettes = null;
    _cachedActiveRouletteId = null;
  }

  /// Check if cache is loaded
  static bool get isCacheLoaded =>
      _cachedRoulettes != null && _cachedActiveRouletteId != null;

  /// Preload cache - useful for app initialization
  static Future<void> preloadCache() async {
    await loadAllRoulettes();
    await getActiveRouletteId();
  }
}
