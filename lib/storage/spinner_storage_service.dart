import 'package:decision_spinner/consts/color_themes.dart';

import 'base_storage_service.dart';
import '../consts/storage_constants.dart';
import 'spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerStorageService extends BaseStorageService {
  // Cache for all spinners data
  static Map<String, SpinnerModel>? _cachedSpinners;
  static String? _cachedActiveSpinnerId;

  /// Internal method to load all spinners from storage
  static Future<Map<String, SpinnerModel>> loadAllSpinners() async {
    // Return cached data if available
    if (_cachedSpinners != null) {
      return _cachedSpinners!;
    }

    try {
      final spinnersData = await BaseStorageService.getJson(
        StorageConstants.spinnersKey,
      );

      if (spinnersData == null) {
        throw Exception("NO spinner");
      }

      final spinnersMap = Map<String, dynamic>.from(spinnersData);
      final loadedSpinners = spinnersMap.map(
        (key, value) => MapEntry(key, SpinnerModel.fromJson(value)),
      );

      // Cache the loaded data
      _cachedSpinners = loadedSpinners;
      return loadedSpinners;
    } catch (e) {
      // Return default spinner if there's an error
      final defaultSpinner = _createDefaultSpinnerModel();
      final defaultSpinners = {defaultSpinner.id: defaultSpinner};
      await saveAllSpinners(defaultSpinners);
      await setActiveSpinnerId(defaultSpinner.id);
      return defaultSpinners;
    }
  }

  /// Create default spinner model
  static SpinnerModel _createDefaultSpinnerModel() {
    return SpinnerModel(
      name: StorageConstants.defaultSpinnerName,
      options: StorageConstants.defaultOptions
          .map((text) => SpinnerOption(text: text, weight: 1.0))
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

  /// Internal method to get active spinner ID from storage
  static Future<String?> _getActiveSpinnerId() async {
    return await BaseStorageService.getString(
      StorageConstants.activeSpinnerKey,
    );
  }

  /// Save all spinners and update cache
  static Future<bool> saveAllSpinners(
    Map<String, SpinnerModel> spinners,
  ) async {
    final jsonData = spinners.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    final success = await BaseStorageService.saveJson(
      StorageConstants.spinnersKey,
      jsonData,
    );
    if (success) {
      // Update cache with a copy
      _cachedSpinners = spinners;
    }
    return success;
  }

  /// Load the active spinner model
  static Future<SpinnerModel?> loadActiveSpinner() async {
    final activeId = await getActiveSpinnerId();

    final allSpinners = await loadAllSpinners();
    return allSpinners[activeId];
  }

  /// Load a specific spinner model by ID
  static Future<SpinnerModel?> loadSpinnerById(String id) async {
    final allSpinners = await loadAllSpinners();
    return allSpinners[id];
  }

  /// Save a spinner model
  static Future<bool> saveSpinner(SpinnerModel spinner) async {
    final allSpinners = await loadAllSpinners();

    spinner.updatedAt = DateTime.now();
    allSpinners[spinner.id] = spinner;
    return await saveAllSpinners(allSpinners);
  }

  /// Create a new spinner
  static Future<SpinnerModel?> createSpinner(
    String name,
    List<SpinnerOption> options, {
    int colorThemeIndex = 0,
  }) async {
    // Use cached data if available
    final allSpinners = await loadAllSpinners();

    // Check if name already exists
    final existingNames = allSpinners.values.map((r) => r.name).toSet();
    if (existingNames.contains(name)) {
      return null; // Spinner with this name already exists
    }

    // Sanity check
    if (colorThemeIndex > DefaultColorThemes.count) {
      return null;
    }

    final newSpinner = SpinnerModel(
      name: name,
      options: options,
      colorThemeIndex: colorThemeIndex,
      colors: DefaultColorThemes.getByIndex(colorThemeIndex)!.colors,
    );

    saveSpinner(newSpinner);
    final success = await saveAllSpinners(allSpinners);

    if (success) {
      await setActiveSpinnerId(newSpinner.id);
      return newSpinner;
    }

    return null;
  }

  /// Delete a spinner
  static Future<bool> deleteSpinner(String id) async {
    // Use cached data if available
    final allSpinners = await loadAllSpinners();

    if (allSpinners.length <= 1) {
      return false; // Cannot delete the last spinner
    }

    if (!allSpinners.containsKey(id)) {
      return false; // Spinner doesn't exist
    }

    allSpinners.remove(id);
    final success = await saveAllSpinners(allSpinners);

    // If the deleted spinner was active, set the first available as active
    final activeId = await getActiveSpinnerId();
    if (activeId == id) {
      final firstSpinnerId = allSpinners.keys.first;
      await setActiveSpinnerId(firstSpinnerId);
    }

    return success;
  }

  /// Rename a spinner
  static Future<bool> renameSpinner(String id, String newName) async {
    // Use cached data if available
    final allSpinners = await loadAllSpinners();

    if (!allSpinners.containsKey(id)) {
      return false; // Spinner doesn't exist
    }

    // Check if new name already exists
    final existingNames = allSpinners.values
        .where((r) => r.id != id)
        .map((r) => r.name)
        .toSet();
    if (existingNames.contains(newName)) {
      return false; // New name already exists
    }

    final spinner = allSpinners[id]!;
    spinner.name = newName;
    spinner.updatedAt = DateTime.now();

    return await saveAllSpinners(allSpinners);
  }

  /// Get the active spinner ID with caching
  static Future<String> getActiveSpinnerId() async {
    if (_cachedActiveSpinnerId == null) {
      _cachedActiveSpinnerId = await _getActiveSpinnerId();

      // If no active spinner is set, set the first available one
      if (_cachedActiveSpinnerId == null) {
        final allSpinners = await loadAllSpinners();
        if (allSpinners.isNotEmpty) {
          _cachedActiveSpinnerId = allSpinners.keys.first;
          await setActiveSpinnerId(_cachedActiveSpinnerId!);
        }
      }
    }
    return _cachedActiveSpinnerId!;
  }

  /// Set the active spinner and update cache
  static Future<bool> setActiveSpinnerId(String spinnerId) async {
    final success = await BaseStorageService.saveString(
      StorageConstants.activeSpinnerKey,
      spinnerId,
    );
    // Update cache immediately if save was successful
    if (success) {
      _cachedActiveSpinnerId = spinnerId;
    }
    return success;
  }

  /// Get list of all spinner models
  static Future<List<SpinnerModel>> getAllSpinners() async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.values.toList();
  }

  /// Get list of all spinner names with their IDs
  static Future<Map<String, String>> getSpinnerNamesWithIds() async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.map((id, spinner) => MapEntry(spinner.name, id));
  }

  /// Check if a spinner name exists
  static Future<bool> spinnerNameExists(String name, {String? id}) async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.values.any(
      (spinner) => spinner.name == name && spinner.id != id,
    );
  }

  /// Check if a spinner ID exists
  static Future<bool> spinnerIdExists(String id) async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.containsKey(id);
  }

  /// Duplicate a spinner
  static Future<SpinnerModel?> duplicateSpinner(
    String originalId,
    String newName,
  ) async {
    // Use cached data if available
    final allSpinners = await loadAllSpinners();

    if (!allSpinners.containsKey(originalId)) {
      return null; // Original spinner doesn't exist
    }

    // Check if new name already exists
    final existingNames = allSpinners.values.map((r) => r.name).toSet();
    if (existingNames.contains(newName)) {
      return null; // New name already exists
    }

    final originalSpinner = allSpinners[originalId]!;
    final duplicatedSpinner = SpinnerModel.duplicate(
      originalSpinner,
      newName: newName,
    );

    allSpinners[duplicatedSpinner.id] = duplicatedSpinner;
    final success = await saveAllSpinners(allSpinners);

    return success ? duplicatedSpinner : null;
  }

  /// Clear all spinners and reset to default
  static Future<bool> clearAllSpinners() async {
    try {
      await BaseStorageService.remove(StorageConstants.spinnersKey);
      await BaseStorageService.remove(StorageConstants.activeSpinnerKey);

      // Recreate default spinner
      final defaultSpinner = _createDefaultSpinnerModel();
      final defaultSpinners = {defaultSpinner.id: defaultSpinner};
      await saveAllSpinners(defaultSpinners);
      await setActiveSpinnerId(defaultSpinner.id);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset a specific spinner to defaults
  static Future<bool> resetSpinnerToDefaults(String id) async {
    final allSpinners = _cachedSpinners != null
        ? Map<String, SpinnerModel>.from(_cachedSpinners!)
        : await loadAllSpinners();

    if (!allSpinners.containsKey(id)) {
      return false; // Spinner doesn't exist
    }

    final spinner = allSpinners[id]!;
    spinner.options = StorageConstants.defaultOptions
        .map((text) => SpinnerOption(text: text, weight: 1.0))
        .toList();
    spinner.updatedAt = DateTime.now();

    return await saveAllSpinners(allSpinners);
  }

  /// Save spinner order
  static Future<void> saveSpinnerOrder(List<String> orderedIds) async {
    try {
      // Load current spinners (uses cache if available)
      final currentSpinners = await loadAllSpinners();

      // Create a new ordered map
      final orderedSpinners = <String, SpinnerModel>{};

      // Add spinners in the specified order
      for (final id in orderedIds) {
        if (currentSpinners.containsKey(id)) {
          orderedSpinners[id] = currentSpinners[id]!;
        }
      }

      // Add any missing spinners at the end (safety check)
      for (final entry in currentSpinners.entries) {
        if (!orderedSpinners.containsKey(entry.key)) {
          orderedSpinners[entry.key] = entry.value;
        }
      }

      // Save the reordered spinners
      await saveAllSpinners(orderedSpinners);
    } catch (e) {
      // If reordering fails, silently continue - the original order will be preserved
      debugPrint('Failed to save spinner order: $e');
    }
  }

  /// Clear cache - useful for testing or when you need to force reload from storage
  static void clearCache() {
    _cachedSpinners = null;
    _cachedActiveSpinnerId = null;
  }

  /// Check if cache is loaded
  static bool get isCacheLoaded =>
      _cachedSpinners != null && _cachedActiveSpinnerId != null;

  /// Preload cache - useful for app initialization
  static Future<void> preloadCache() async {
    await loadAllSpinners();
    await getActiveSpinnerId();
  }
}
