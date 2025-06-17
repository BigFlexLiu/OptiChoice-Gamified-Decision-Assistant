import 'base_storage_service.dart';
import '../consts/storage_constants.dart';
import 'roulette_wheel_model.dart';
import '../views/roulette_options_view.dart';
import 'package:flutter/material.dart';

class RouletteStorageService extends BaseStorageService {
  // Cache for all roulettes data
  static Map<String, RouletteModel>? _cachedRoulettes;
  static String? _cachedActiveRouletteId;

  /// Internal method to load all roulettes from storage
  static Future<Map<String, RouletteModel>> loadAllRoulettes() async {
    // Return cached data if available
    if (_cachedRoulettes != null) {
      return _cachedRoulettes!;
    }

    try {
      final roulettesData = await BaseStorageService.getJson(
        StorageConstants.roulettesKey,
      );

      if (roulettesData == null) {
        throw Exception("NO ROULETTE");
      }

      final roulettesMap = Map<String, dynamic>.from(roulettesData);
      final loadedRoulettes = roulettesMap.map(
        (key, value) => MapEntry(key, RouletteModel.fromJson(value)),
      );

      // Cache the loaded data
      _cachedRoulettes = loadedRoulettes;
      return loadedRoulettes;
    } catch (e) {
      // Return default roulette if there's an error
      final defaultRoulette = _createDefaultRouletteModel();
      final defaultRoulettes = {defaultRoulette.id: defaultRoulette};
      await saveAllRoulettes(defaultRoulettes);
      await setActiveRouletteId(defaultRoulette.id);
      return defaultRoulettes;
    }
  }

  /// Create default roulette model
  static RouletteModel _createDefaultRouletteModel() {
    return RouletteModel(
      name: StorageConstants.defaultRouletteName,
      options: StorageConstants.defaultOptions
          .map((text) => RouletteOption(text: text, weight: 1.0))
          .toList(),
      colorThemeIndex: -1,
      colors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ],
    );
  }

  /// Internal method to get active roulette ID from storage
  static Future<String?> _getActiveRouletteId() async {
    return await BaseStorageService.getString(
      StorageConstants.activeRouletteKey,
    );
  }

  /// Save all roulettes and update cache
  static Future<bool> saveAllRoulettes(
    Map<String, RouletteModel> roulettes,
  ) async {
    final jsonData = roulettes.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    final success = await BaseStorageService.saveJson(
      StorageConstants.roulettesKey,
      jsonData,
    );
    if (success) {
      // Update cache with a copy
      _cachedRoulettes = roulettes;
    }
    return success;
  }

  /// Load the active roulette model
  static Future<RouletteModel?> loadActiveRoulette() async {
    final activeId = await getActiveRouletteId();

    final allRoulettes = await loadAllRoulettes();
    return allRoulettes[activeId];
  }

  /// Load a specific roulette model by ID
  static Future<RouletteModel?> loadRouletteById(String id) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes[id];
  }

  /// Save a roulette model
  static Future<bool> saveRoulette(RouletteModel roulette) async {
    // Use cached data if available
    final allRoulettes = await loadAllRoulettes();

    roulette.updatedAt = DateTime.now();
    allRoulettes[roulette.id] = roulette;
    return await saveAllRoulettes(allRoulettes);
  }

  /// Create a new roulette
  static Future<RouletteModel?> createRoulette(
    String name,
    List<RouletteOption> options, {
    int colorThemeIndex = 0,
  }) async {
    // Use cached data if available
    final allRoulettes = await loadAllRoulettes();

    // Check if name already exists
    final existingNames = allRoulettes.values.map((r) => r.name).toSet();
    if (existingNames.contains(name)) {
      return null; // Roulette with this name already exists
    }

    final newRoulette = RouletteModel(
      name: name,
      options: options,
      colorThemeIndex: colorThemeIndex,
      colors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ],
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
    final allRoulettes = await loadAllRoulettes();

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
    final allRoulettes = await loadAllRoulettes();

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
  static Future<String> getActiveRouletteId() async {
    if (_cachedActiveRouletteId == null) {
      _cachedActiveRouletteId = await _getActiveRouletteId();

      // If no active roulette is set, set the first available one
      if (_cachedActiveRouletteId == null) {
        final allRoulettes = await loadAllRoulettes();
        if (allRoulettes.isNotEmpty) {
          _cachedActiveRouletteId = allRoulettes.keys.first;
          await setActiveRouletteId(_cachedActiveRouletteId!);
        }
      }
    }
    return _cachedActiveRouletteId!;
  }

  /// Set the active roulette and update cache
  static Future<bool> setActiveRouletteId(String rouletteId) async {
    return await BaseStorageService.saveString(
      StorageConstants.activeRouletteKey,
      rouletteId,
    );
  }

  /// Get list of all roulette models
  static Future<List<RouletteModel>> getAllRoulettes() async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.values.toList();
  }

  /// Get list of all roulette names with their IDs
  static Future<Map<String, String>> getRouletteNamesWithIds() async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.map((id, roulette) => MapEntry(roulette.name, id));
  }

  /// Check if a roulette name exists
  static Future<bool> rouletteNameExists(String name, {String? id}) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.values.any(
      (roulette) => roulette.name == name && roulette.id != id,
    );
  }

  /// Check if a roulette ID exists
  static Future<bool> rouletteIdExists(String id) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.containsKey(id);
  }

  /// Duplicate a roulette
  static Future<RouletteModel?> duplicateRoulette(
    String originalId,
    String newName,
  ) async {
    // Use cached data if available
    final allRoulettes = await loadAllRoulettes();

    if (!allRoulettes.containsKey(originalId)) {
      return null; // Original roulette doesn't exist
    }

    // Check if new name already exists
    final existingNames = allRoulettes.values.map((r) => r.name).toSet();
    if (existingNames.contains(newName)) {
      return null; // New name already exists
    }

    final originalRoulette = allRoulettes[originalId]!;
    final duplicatedRoulette = RouletteModel(
      name: newName,
      options: originalRoulette.options
          .map(
            (option) =>
                RouletteOption(text: option.text, weight: option.weight),
          )
          .toList(),
      colorThemeIndex: originalRoulette.colorThemeIndex,
      colors: List<Color>.from(originalRoulette.colors),
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

  /// Reset a specific roulette to defaults
  static Future<bool> resetRouletteToDefaults(String id) async {
    final allRoulettes = _cachedRoulettes != null
        ? Map<String, RouletteModel>.from(_cachedRoulettes!)
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
      final orderedRoulettes = <String, RouletteModel>{};

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
