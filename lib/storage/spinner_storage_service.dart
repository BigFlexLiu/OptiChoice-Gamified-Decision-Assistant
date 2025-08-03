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
      backgroundColors: [
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

  /// Find a spinner by name (more efficient than getAllSpinners + filter)
  static Future<SpinnerModel?> findSpinnerByName(String name) async {
    final allSpinners = await loadAllSpinners();
    for (final spinner in allSpinners.values) {
      if (spinner.name == name) {
        return spinner;
      }
    }
    return null;
  }

  /// Save a spinner model
  static Future<bool> saveSpinner(SpinnerModel spinner) async {
    final allSpinners = await loadAllSpinners();

    spinner.updatedAt = DateTime.now();
    allSpinners[spinner.id] = spinner;
    return await saveAllSpinners(allSpinners);
  }

  /// Generate a unique name for a spinner by appending a number if needed
  static Future<String> generateUniqueName(
    String baseName, {
    String? excludeId,
    Map<String, SpinnerModel>? spinners,
  }) async {
    // Use provided spinners map or load from cache/storage
    final allSpinners = spinners ?? await loadAllSpinners();

    // Check if base name is unique
    final nameExists = allSpinners.values.any(
      (spinner) => spinner.name == baseName && spinner.id != excludeId,
    );

    if (!nameExists) return baseName;

    // Find unique name with counter
    for (int counter = 1; ; counter++) {
      final candidateName = '$baseName ($counter)';
      final candidateExists = allSpinners.values.any(
        (spinner) => spinner.name == candidateName && spinner.id != excludeId,
      );
      if (!candidateExists) return candidateName;
    }
  }

  /// Check if a spinner with identical content already exists
  static Future<SpinnerModel?> findSpinnerWithIdenticalContent(
    SpinnerModel targetSpinner, {
    Map<String, SpinnerModel>? spinners,
  }) async {
    final allSpinners = spinners ?? await loadAllSpinners();

    for (final existingSpinner in allSpinners.values) {
      if (existingSpinner.id == targetSpinner.id) continue;

      if (_areSpinnersContentIdentical(targetSpinner, existingSpinner)) {
        return existingSpinner;
      }
    }
    return null;
  }

  /// Compare two spinners to see if their content is identical (excluding name and metadata)
  static bool _areSpinnersContentIdentical(
    SpinnerModel spinner1,
    SpinnerModel spinner2,
  ) {
    // Compare options
    if (spinner1.options.length != spinner2.options.length) return false;
    for (int i = 0; i < spinner1.options.length; i++) {
      final option1 = spinner1.options[i];
      final option2 = spinner2.options[i];
      if (option1.text != option2.text ||
          option1.weight != option2.weight ||
          option1.isActive != option2.isActive) {
        return false;
      }
    }

    // Compare color theme and background colors
    if (spinner1.colorThemeIndex != spinner2.colorThemeIndex ||
        spinner1.backgroundColors.length != spinner2.backgroundColors.length) {
      return false;
    }

    for (int i = 0; i < spinner1.backgroundColors.length; i++) {
      if (spinner1.backgroundColors[i] != spinner2.backgroundColors[i]) {
        return false;
      }
    }

    return true;
  }

  /// Create a new spinner
  static Future<SpinnerModel?> createSpinner(
    String name,
    List<SpinnerOption> options, {
    int colorThemeIndex = 0,
  }) async {
    if (colorThemeIndex > DefaultColorThemes.count) return null;

    final allSpinners = await loadAllSpinners();
    final finalName = await generateUniqueName(name, spinners: allSpinners);

    final newSpinner = SpinnerModel(
      name: finalName,
      options: options,
      colorThemeIndex: colorThemeIndex,
      backgroundColors: DefaultColorThemes.getByIndex(colorThemeIndex)!.colors,
    );

    allSpinners[newSpinner.id] = newSpinner;
    final success = await saveAllSpinners(allSpinners);

    if (success) {
      await setActiveSpinnerId(newSpinner.id);
      return newSpinner;
    }
    return null;
  }

  /// Delete a spinner
  static Future<bool> deleteSpinner(String id) async {
    final allSpinners = await loadAllSpinners();

    if (allSpinners.length <= 1 || !allSpinners.containsKey(id)) return false;

    allSpinners.remove(id);
    final success = await saveAllSpinners(allSpinners);

    // Set new active spinner if the deleted one was active
    if (success && await getActiveSpinnerId() == id) {
      await setActiveSpinnerId(allSpinners.keys.first);
    }
    return success;
  }

  /// Rename a spinner
  static Future<bool> renameSpinner(String id, String newName) async {
    final allSpinners = await loadAllSpinners();
    final spinner = allSpinners[id];
    if (spinner == null) return false;

    // Check if new name already exists (excluding current spinner)
    final nameExists = allSpinners.values.any(
      (s) => s.name == newName && s.id != id,
    );
    if (nameExists) return false;

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

  /// Check if a spinner name exists
  static Future<bool> spinnerNameExists(String name, {String? id}) async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.values.any(
      (spinner) => spinner.name == name && spinner.id != id,
    );
  }

  /// Duplicate a spinner with automatic unique name generation
  static Future<SpinnerModel?> duplicateSpinner(
    String originalId,
    String newName,
  ) async {
    final allSpinners = await loadAllSpinners();
    final originalSpinner = allSpinners[originalId];
    if (originalSpinner == null) return null;

    final finalName = await generateUniqueName(newName, spinners: allSpinners);
    final duplicatedSpinner = SpinnerModel.duplicate(
      originalSpinner,
      newName: finalName,
    );

    allSpinners[duplicatedSpinner.id] = duplicatedSpinner;
    return await saveAllSpinners(allSpinners) ? duplicatedSpinner : null;
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
}
