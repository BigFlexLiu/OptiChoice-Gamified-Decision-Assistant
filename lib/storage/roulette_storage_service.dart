import 'package:flutter/foundation.dart';
import 'base_storage_service.dart';
import 'storage_constants.dart';

class RouletteStorageService extends BaseStorageService {
  /// Load all roulettes
  static Future<Map<String, List<String>>> loadAllRoulettes() async {
    try {
      final roulettesData = await BaseStorageService.getJson(
        StorageConstants.roulettesKey,
      );

      if (roulettesData == null) {
        // Create default roulette if none exist
        final defaultRoulettes = {
          StorageConstants.defaultRouletteName: StorageConstants.defaultOptions,
        };
        await saveAllRoulettes(defaultRoulettes);
        await setActiveRoulette(StorageConstants.defaultRouletteName);
        return Map.from(defaultRoulettes);
      }

      final roulettesMap = Map<String, dynamic>.from(roulettesData);
      return roulettesMap.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
    } catch (e) {
      // Return default roulette if there's an error
      final defaultRoulettes = {
        StorageConstants.defaultRouletteName: StorageConstants.defaultOptions,
      };
      await saveAllRoulettes(defaultRoulettes);
      await setActiveRoulette(StorageConstants.defaultRouletteName);
      return defaultRoulettes;
    }
  }

  /// Save all roulettes
  static Future<bool> saveAllRoulettes(
    Map<String, List<String>> roulettes,
  ) async {
    return await BaseStorageService.saveJson(
      StorageConstants.roulettesKey,
      roulettes,
    );
  }

  /// Load options for the active roulette
  static Future<List<String>> loadOptions() async {
    final activeRoulette = await getActiveRoulette();
    return await loadRouletteOptions(activeRoulette);
  }

  /// Load options for a specific roulette
  static Future<List<String>> loadRouletteOptions(String rouletteName) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes[rouletteName] ?? StorageConstants.defaultOptions;
  }

  /// Save options for the active roulette
  static Future<bool> saveOptions(List<String> options) async {
    final activeRoulette = await getActiveRoulette();
    return await saveRouletteOptions(activeRoulette, options);
  }

  /// Save options for a specific roulette
  static Future<bool> saveRouletteOptions(
    String rouletteName,
    List<String> options,
  ) async {
    final allRoulettes = await loadAllRoulettes();
    allRoulettes[rouletteName] = options;
    return await saveAllRoulettes(allRoulettes);
  }

  /// Create a new roulette
  static Future<bool> createRoulette(String name, List<String> options) async {
    final allRoulettes = await loadAllRoulettes();

    if (allRoulettes.containsKey(name)) {
      return false; // Roulette with this name already exists
    }

    allRoulettes[name] = options;
    final success = await saveAllRoulettes(allRoulettes);

    if (success) {
      await setActiveRoulette(name);
    }

    return success;
  }

  /// Delete a roulette
  static Future<bool> deleteRoulette(String name) async {
    final allRoulettes = await loadAllRoulettes();

    if (allRoulettes.length <= 1) {
      return false; // Cannot delete the last roulette
    }

    if (!allRoulettes.containsKey(name)) {
      return false; // Roulette doesn't exist
    }

    allRoulettes.remove(name);
    final success = await saveAllRoulettes(allRoulettes);

    // If the deleted roulette was active, set the first available as active
    final activeRoulette = await getActiveRoulette();
    if (activeRoulette == name) {
      final firstRoulette = allRoulettes.keys.first;
      await setActiveRoulette(firstRoulette);
    }

    return success;
  }

  /// Rename a roulette
  static Future<bool> renameRoulette(String oldName, String newName) async {
    if (oldName == newName) return true;

    final allRoulettes = await loadAllRoulettes();

    if (!allRoulettes.containsKey(oldName)) {
      return false; // Old roulette doesn't exist
    }

    if (allRoulettes.containsKey(newName)) {
      return false; // New name already exists
    }

    final options = allRoulettes[oldName]!;
    allRoulettes.remove(oldName);
    allRoulettes[newName] = options;

    final success = await saveAllRoulettes(allRoulettes);

    // Update active roulette if it was the renamed one
    final activeRoulette = await getActiveRoulette();
    if (activeRoulette == oldName) {
      await setActiveRoulette(newName);
    }

    return success;
  }

  /// Get the active roulette name
  static Future<String> getActiveRoulette() async {
    return await BaseStorageService.getString(
          StorageConstants.activeRouletteKey,
        ) ??
        StorageConstants.defaultRouletteName;
  }

  /// Set the active roulette
  static Future<bool> setActiveRoulette(String rouletteName) async {
    return await BaseStorageService.saveString(
      StorageConstants.activeRouletteKey,
      rouletteName,
    );
  }

  /// Get list of all roulette names
  static Future<List<String>> getRouletteNames() async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.keys.toList();
  }

  /// Check if a roulette name exists
  static Future<bool> rouletteExists(String name) async {
    final allRoulettes = await loadAllRoulettes();
    return allRoulettes.containsKey(name);
  }

  /// Duplicate a roulette
  static Future<bool> duplicateRoulette(
    String originalName,
    String newName,
  ) async {
    final allRoulettes = await loadAllRoulettes();

    if (!allRoulettes.containsKey(originalName)) {
      return false; // Original roulette doesn't exist
    }

    if (allRoulettes.containsKey(newName)) {
      return false; // New name already exists
    }

    final originalOptions = List<String>.from(allRoulettes[originalName]!);
    allRoulettes[newName] = originalOptions;

    return await saveAllRoulettes(allRoulettes);
  }

  /// Clear all roulettes and reset to default
  static Future<bool> clearAllRoulettes() async {
    try {
      await BaseStorageService.remove(StorageConstants.roulettesKey);
      await BaseStorageService.remove(StorageConstants.activeRouletteKey);

      // Recreate default roulette
      final defaultRoulettes = {
        StorageConstants.defaultRouletteName: StorageConstants.defaultOptions,
      };
      await saveAllRoulettes(defaultRoulettes);
      await setActiveRoulette(StorageConstants.defaultRouletteName);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset active roulette to defaults
  static Future<bool> resetToDefaults() async {
    final activeRoulette = await getActiveRoulette();
    return await saveRouletteOptions(
      activeRoulette,
      StorageConstants.defaultOptions,
    );
  }

  /// Reset a specific roulette to defaults
  static Future<bool> resetRouletteToDefaults(String rouletteName) async {
    return await saveRouletteOptions(
      rouletteName,
      StorageConstants.defaultOptions,
    );
  }

  /// Save roulette order
  static Future<void> saveRouletteOrder(List<String> orderedNames) async {
    try {
      // Load current roulettes
      final currentRoulettes = await loadAllRoulettes();

      // Create a new ordered map
      final orderedRoulettes = <String, List<String>>{};

      // Add roulettes in the specified order
      for (final name in orderedNames) {
        if (currentRoulettes.containsKey(name)) {
          orderedRoulettes[name] = currentRoulettes[name]!;
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
}
