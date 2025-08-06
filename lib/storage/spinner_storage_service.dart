import 'package:decision_spinner/consts/color_themes.dart';

import 'base_storage_service.dart';
import '../consts/storage_constants.dart';
import 'spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerStorageService extends BaseStorageService {
  static Map<String, SpinnerModel>? _cachedSpinners;
  static String? _cachedActiveSpinnerId;
  // Cache for the active spinner model
  static SpinnerModel? _cachedActiveSpinner;

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
      slices: StorageConstants.defaultSlices
          .map((text) => Slice(text: text, weight: 1.0))
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

  /// Batch save operations - save multiple spinners and set active ID in one transaction
  static Future<bool> batchSaveWithActiveId(
    Map<String, SpinnerModel> spinners,
    String activeSpinnerId,
  ) async {
    // Save spinners first
    final spinnersSuccess = await saveAllSpinners(spinners);
    if (!spinnersSuccess) return false;

    // Then set active spinner ID
    final activeSuccess = await setActiveSpinnerId(activeSpinnerId);
    return activeSuccess;
  }

  /// Optimized method to get multiple spinners by IDs
  static Future<Map<String, SpinnerModel?>> getSpinnersByIds(
    List<String> ids,
  ) async {
    final result = <String, SpinnerModel?>{};

    // Check cache first for each ID
    for (final id in ids) {
      final cached = getCachedSpinnerById(id);
      if (cached != null) result[id] = cached;
    }

    // If we found all in cache, return early
    if (result.length == ids.length) return result;

    // Load all spinners for remaining IDs
    final allSpinners = await loadAllSpinners();
    for (final id in ids) {
      result[id] ??= allSpinners[id];
    }

    return result;
  }

  /// Load the active spinner model
  static Future<SpinnerModel?> loadActiveSpinner() async {
    if (_cachedActiveSpinner != null && _cachedActiveSpinnerId != null) {
      return _cachedActiveSpinner;
    }

    final activeId = await getActiveSpinnerId();
    final activeSpinner = await loadSpinnerById(activeId);
    _cachedActiveSpinner = activeSpinner;
    return activeSpinner;
  }

  /// Get the cached active spinner without disk reads if possible
  /// Returns null if not cached or cache is invalid
  static SpinnerModel? getCachedActiveSpinner() {
    if (_cachedActiveSpinner != null &&
        _cachedActiveSpinnerId != null &&
        _cachedActiveSpinner!.id == _cachedActiveSpinnerId) {
      return _cachedActiveSpinner;
    }
    return null;
  }

  /// Get cached spinner by ID without triggering a load
  /// Returns null if not cached
  static SpinnerModel? getCachedSpinnerById(String id) {
    return _cachedActiveSpinner?.id == id
        ? _cachedActiveSpinner
        : _cachedSpinners?[id];
  }

  /// Cache status utilities
  static bool hasSpinnerCache() => _cachedSpinners != null;
  static bool hasActiveSpinnerIdCache() => _cachedActiveSpinnerId != null;

  /// Get spinner names and IDs only (lightweight for UI lists)
  /// Returns a map of {id: name} for all spinners
  static Future<Map<String, String>> getSpinnerNamesMap() async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.map((key, value) => MapEntry(key, value.name));
  }

  /// Get lightweight spinner info (id, name, updated timestamp) for UI lists
  static Future<List<Map<String, dynamic>>> getSpinnerListInfo() async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.values
        .map(
          (spinner) => {
            'id': spinner.id,
            'name': spinner.name,
            'updatedAt': spinner.updatedAt.toIso8601String(),
            'optionCount': spinner.slices.length,
          },
        )
        .toList();
  }

  /// Load a specific spinner model by ID or active spinner
  static Future<SpinnerModel?> loadSpinnerById(String id) async {
    return getCachedSpinnerById(id) ?? (await loadAllSpinners())[id];
  }

  /// Find a spinner by name
  static Future<SpinnerModel?> findSpinnerByName(String name) async {
    if (_cachedActiveSpinner?.name == name) return _cachedActiveSpinner;

    final allSpinners = await loadAllSpinners();
    for (final spinner in allSpinners.values) {
      if (spinner.name == name) return spinner;
    }
    return null;
  }

  /// Save a spinner model and update caches
  static Future<bool> saveSpinner(SpinnerModel spinner) async {
    return await _updateSpinner(spinner, updateTimestamp: true);
  }

  /// Internal helper to update spinner with optional timestamp update
  static Future<bool> _updateSpinner(
    SpinnerModel spinner, {
    bool updateTimestamp = false,
  }) async {
    final allSpinners = await loadAllSpinners();

    if (updateTimestamp) spinner.updatedAt = DateTime.now();
    allSpinners[spinner.id] = spinner;

    final success = await saveAllSpinners(allSpinners);
    if (success && _cachedActiveSpinner?.id == spinner.id) {
      _cachedActiveSpinner = spinner;
    }
    return success;
  }

  /// Batch update multiple spinners efficiently
  static Future<bool> batchUpdateSpinners(List<SpinnerModel> spinners) async {
    if (spinners.isEmpty) return true;

    final allSpinners = await loadAllSpinners();
    for (final spinner in spinners) {
      spinner.updatedAt = DateTime.now();
      allSpinners[spinner.id] = spinner;
      if (_cachedActiveSpinner?.id == spinner.id) {
        _cachedActiveSpinner = spinner;
      }
    }
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
    // Compare slices
    if (spinner1.slices.length != spinner2.slices.length) return false;
    for (int i = 0; i < spinner1.slices.length; i++) {
      final option1 = spinner1.slices[i];
      final option2 = spinner2.slices[i];
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
    List<Slice> slices, {
    int colorThemeIndex = 0,
  }) async {
    if (colorThemeIndex > DefaultColorThemes.count) return null;

    final allSpinners = await loadAllSpinners();
    final finalName = await generateUniqueName(name, spinners: allSpinners);

    final newSpinner = SpinnerModel(
      name: finalName,
      slices: slices,
      colorThemeIndex: colorThemeIndex,
      backgroundColors: DefaultColorThemes.getByIndex(colorThemeIndex)!.colors,
    );

    allSpinners[newSpinner.id] = newSpinner;
    return await batchSaveWithActiveId(allSpinners, newSpinner.id)
        ? newSpinner
        : null;
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

  /// Delete a spinner
  static Future<bool> deleteSpinner(String id) async {
    final allSpinners = await loadAllSpinners();
    if (allSpinners.length <= 1 || !allSpinners.containsKey(id)) return false;

    final wasActive =
        (_cachedActiveSpinnerId ?? await getActiveSpinnerId()) == id;
    allSpinners.remove(id);

    final success = await saveAllSpinners(allSpinners);
    if (success) {
      if (_cachedActiveSpinner?.id == id) _cachedActiveSpinner = null;
      if (wasActive) await setActiveSpinnerId(allSpinners.keys.first);
    }
    return success;
  }

  /// Rename a spinner
  static Future<bool> renameSpinner(String id, String newName) async {
    final allSpinners = await loadAllSpinners();
    final spinner = allSpinners[id];
    if (spinner == null) return false;

    // Check if new name already exists (excluding current spinner)
    if (await spinnerNameExists(newName, id: id)) return false;

    spinner.name = newName;
    return await _updateSpinner(spinner, updateTimestamp: true);
  }

  /// Check if a spinner name exists
  static Future<bool> spinnerNameExists(String name, {String? id}) async {
    // Quick check against cached active spinner if applicable
    if (_cachedActiveSpinner?.name == name && _cachedActiveSpinner?.id != id) {
      return true;
    }

    final allSpinners = await loadAllSpinners();
    return allSpinners.values.any((s) => s.name == name && s.id != id);
  }

  /// Get the active spinner ID with caching
  static Future<String> getActiveSpinnerId() async {
    if (_cachedActiveSpinnerId == null) {
      _cachedActiveSpinnerId = await _getActiveSpinnerId();

      // If no active spinner is set, set the first available one
      if (_cachedActiveSpinnerId == null) {
        // Use cached spinners if available to avoid disk read
        Map<String, SpinnerModel> allSpinners;
        if (_cachedSpinners != null) {
          allSpinners = _cachedSpinners!;
        } else {
          allSpinners = await loadAllSpinners();
        }

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
      // Update cached active spinner if we have the spinner data available
      if (_cachedSpinners?.containsKey(spinnerId) == true) {
        _cachedActiveSpinner = _cachedSpinners![spinnerId];
      } else {
        // Clear cached active spinner as it's no longer valid
        _cachedActiveSpinner = null;
      }
    }
    return success;
  }

  /// Get list of all spinner models
  static Future<List<SpinnerModel>> getAllSpinners() async {
    final allSpinners = await loadAllSpinners();
    return allSpinners.values.toList();
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

  /// Cache management utilities
  static void clearCache() {
    _cachedSpinners = null;
    _cachedActiveSpinnerId = null;
    _cachedActiveSpinner = null;
  }

  /// Force reload specific spinner from storage and update cache
  static Future<SpinnerModel?> reloadSpinnerById(String id) async {
    _cachedSpinners?.remove(id);
    if (_cachedActiveSpinner?.id == id) _cachedActiveSpinner = null;

    final allSpinners = await loadAllSpinners();
    final spinner = allSpinners[id];

    if (spinner != null && _cachedActiveSpinnerId == id) {
      _cachedActiveSpinner = spinner;
    }
    return spinner;
  }

  /// Get cache statistics for debugging/monitoring
  static Map<String, dynamic> getCacheStats() => {
    'hasCachedSpinners': _cachedSpinners != null,
    'cachedSpinnerCount': _cachedSpinners?.length ?? 0,
    'hasActiveSpinnerId': _cachedActiveSpinnerId != null,
    'activeSpinnerId': _cachedActiveSpinnerId,
    'hasCachedActiveSpinner': _cachedActiveSpinner != null,
    'cachedActiveSpinnerName': _cachedActiveSpinner?.name,
  };
}
