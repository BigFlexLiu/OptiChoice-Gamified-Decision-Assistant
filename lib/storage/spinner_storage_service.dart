import 'package:decision_spinner/consts/color_themes.dart';

import 'base_storage_service.dart';
import '../consts/storage_constants.dart';
import 'spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerStorageService extends BaseStorageService {
  // Note: Caching is now handled by SpinnersNotifier
  // This service only handles storage operations

  static Future<Map<String, SpinnerModel>> loadAllSpinners() async {
    try {
      final spinnersData = await BaseStorageService.getJson(
        StorageConstants.spinnersKey,
      );
      if (spinnersData == null) throw Exception("NO spinner");

      final spinnersMap = Map<String, dynamic>.from(spinnersData);
      final loadedSpinners = spinnersMap.map(
        (key, value) => MapEntry(key, SpinnerModel.fromJson(value)),
      );

      return loadedSpinners;
    } catch (e) {
      return {};
    }
  }

  static Future<String?> _getActiveSpinnerId() async {
    return await BaseStorageService.getString(
      StorageConstants.activeSpinnerKey,
    );
  }

  static Future<bool> saveAllSpinners(
    Map<String, SpinnerModel> spinners,
  ) async {
    final jsonData = spinners.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    return await BaseStorageService.saveJson(
      StorageConstants.spinnersKey,
      jsonData,
    );
  }

  static Future<bool> batchSaveWithActiveId(
    Map<String, SpinnerModel> spinners,
    String activeSpinnerId,
  ) async {
    final spinnersSuccess = await saveAllSpinners(spinners);
    if (!spinnersSuccess) return false;
    return await setActiveSpinnerId(activeSpinnerId);
  }

  static Future<SpinnerModel?> loadActiveSpinner() async {
    final allSpinners = await loadAllSpinners();
    final activeId = await getActiveSpinnerId();

    // Get spinner by ID, fallback to first if not found
    return allSpinners[activeId] ?? allSpinners.values.first;
  }

  static Future<bool> saveSpinner(SpinnerModel spinner) async {
    return await _updateSpinner(spinner, updateTimestamp: true);
  }

  static Future<bool> _updateSpinner(
    SpinnerModel spinner, {
    bool updateTimestamp = false,
  }) async {
    final allSpinners = await loadAllSpinners();
    if (updateTimestamp) spinner.updatedAt = DateTime.now();
    allSpinners[spinner.id] = spinner;
    return await saveAllSpinners(allSpinners);
  }

  static Future<SpinnerModel?> createSpinner(
    String name,
    List<Slice> slices, {
    int colorThemeIndex = 0,
  }) async {
    if (colorThemeIndex > DefaultColorThemes.count) return null;
    final allSpinners = await loadAllSpinners();
    final newSpinner = SpinnerModel(
      name: name,
      slices: slices,
      colorThemeIndex: colorThemeIndex,
      backgroundColors: DefaultColorThemes.getByIndex(colorThemeIndex)!.colors,
    );
    allSpinners[newSpinner.id] = newSpinner;
    return await batchSaveWithActiveId(allSpinners, newSpinner.id)
        ? newSpinner
        : null;
  }

  static Future<SpinnerModel?> duplicateSpinner(
    String originalId,
    String newName,
  ) async {
    final allSpinners = await loadAllSpinners();
    final originalSpinner = allSpinners[originalId];
    if (originalSpinner == null) return null;
    final duplicatedSpinner = SpinnerModel.duplicate(
      originalSpinner,
      newName: newName,
    );
    allSpinners[duplicatedSpinner.id] = duplicatedSpinner;
    return await saveAllSpinners(allSpinners) ? duplicatedSpinner : null;
  }

  static Future<SpinnerModel?> findSpinnerWithIdenticalContent(
    SpinnerModel targetSpinner, {
    Map<String, SpinnerModel>? spinners,
  }) async {
    final allSpinners = spinners ?? await loadAllSpinners();
    for (final existingSpinner in allSpinners.values) {
      if (existingSpinner.id == targetSpinner.id) continue;
      if (targetSpinner.isContentIdenticalTo(existingSpinner)) {
        return existingSpinner;
      }
    }
    return null;
  }

  static Future<void> saveSpinnerOrder(List<String> orderedIds) async {
    try {
      final currentSpinners = await loadAllSpinners();
      final orderedSpinners = <String, SpinnerModel>{};
      for (final id in orderedIds) {
        if (currentSpinners.containsKey(id))
          orderedSpinners[id] = currentSpinners[id]!;
      }
      for (final entry in currentSpinners.entries) {
        if (!orderedSpinners.containsKey(entry.key))
          orderedSpinners[entry.key] = entry.value;
      }
      await saveAllSpinners(orderedSpinners);
    } catch (e) {
      debugPrint('Failed to save spinner order: $e');
    }
  }

  static Future<bool> deleteSpinner(String id) async {
    final allSpinners = await loadAllSpinners();
    if (allSpinners.length <= 1 || !allSpinners.containsKey(id)) return false;

    final wasActive = (await getActiveSpinnerId()) == id;
    allSpinners.remove(id);
    final success = await saveAllSpinners(allSpinners);

    if (success && wasActive) {
      await setActiveSpinnerId(allSpinners.keys.first);
    }

    return success;
  }

  static Future<String> getActiveSpinnerId() async {
    String? activeSpinnerId = await _getActiveSpinnerId();

    if (activeSpinnerId == null) {
      final allSpinners = await loadAllSpinners();
      if (allSpinners.isNotEmpty) {
        activeSpinnerId = allSpinners.keys.first;
        await setActiveSpinnerId(activeSpinnerId);
      }
    }

    return activeSpinnerId ?? '';
  }

  static Future<bool> setActiveSpinnerId(String spinnerId) async {
    return await BaseStorageService.saveString(
      StorageConstants.activeSpinnerKey,
      spinnerId,
    );
  }
}
