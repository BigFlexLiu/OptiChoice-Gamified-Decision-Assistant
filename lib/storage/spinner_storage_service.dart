import 'package:decision_spinner/consts/color_themes.dart';

import 'base_storage_service.dart';
import '../consts/storage_constants.dart';
import 'spinner_model.dart';
import 'package:flutter/material.dart';

class SpinnerStorageService extends BaseStorageService {
  static Map<String, SpinnerModel>? _cachedSpinners;
  static String? _cachedActiveSpinnerId;
  static SpinnerModel? _cachedActiveSpinner;

  static Future<Map<String, SpinnerModel>> loadAllSpinners() async {
    if (_cachedSpinners != null) return _cachedSpinners!;

    try {
      final spinnersData = await BaseStorageService.getJson(
        StorageConstants.spinnersKey,
      );
      if (spinnersData == null) throw Exception("NO spinner");

      final spinnersMap = Map<String, dynamic>.from(spinnersData);
      final loadedSpinners = spinnersMap.map(
        (key, value) => MapEntry(key, SpinnerModel.fromJson(value)),
      );

      _cachedSpinners = loadedSpinners;
      return loadedSpinners;
    } catch (e) {
      final defaultSpinner = _createDefaultSpinnerModel();
      final defaultSpinners = {defaultSpinner.id: defaultSpinner};
      await saveAllSpinners(defaultSpinners);
      await setActiveSpinnerId(defaultSpinner.id);
      return defaultSpinners;
    }
  }

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
    final success = await BaseStorageService.saveJson(
      StorageConstants.spinnersKey,
      jsonData,
    );
    if (success) _cachedSpinners = spinners;
    return success;
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
    if (_cachedActiveSpinner != null && _cachedActiveSpinnerId != null) {
      return _cachedActiveSpinner;
    }
    final activeId = await getActiveSpinnerId();
    final activeSpinner = await loadSpinnerById(activeId);
    _cachedActiveSpinner = activeSpinner;
    return activeSpinner;
  }

  static SpinnerModel? getCachedSpinnerById(String id) {
    return _cachedActiveSpinner?.id == id
        ? _cachedActiveSpinner
        : _cachedSpinners?[id];
  }

  static Future<SpinnerModel?> loadSpinnerById(String id) async {
    return getCachedSpinnerById(id) ?? (await loadAllSpinners())[id];
  }

  static Future<SpinnerModel?> findSpinnerByName(String name) async {
    if (_cachedActiveSpinner?.name == name) return _cachedActiveSpinner;
    final allSpinners = await loadAllSpinners();
    for (final spinner in allSpinners.values) {
      if (spinner.name == name) return spinner;
    }
    return null;
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
    final success = await saveAllSpinners(allSpinners);
    if (success && _cachedActiveSpinner?.id == spinner.id) {
      _cachedActiveSpinner = spinner;
    }
    return success;
  }

  static Future<String> generateUniqueName(
    String baseName, {
    String? excludeId,
    Map<String, SpinnerModel>? spinners,
  }) async {
    final allSpinners = spinners ?? await loadAllSpinners();
    final nameExists = allSpinners.values.any(
      (spinner) => spinner.name == baseName && spinner.id != excludeId,
    );
    if (!nameExists) return baseName;

    for (int counter = 1; ; counter++) {
      final candidateName = '$baseName ($counter)';
      final candidateExists = allSpinners.values.any(
        (spinner) => spinner.name == candidateName && spinner.id != excludeId,
      );
      if (!candidateExists) return candidateName;
    }
  }

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

  static Future<SpinnerModel?> findSpinnerWithIdenticalContent(
    SpinnerModel targetSpinner, {
    Map<String, SpinnerModel>? spinners,
  }) async {
    final allSpinners = spinners ?? await loadAllSpinners();
    for (final existingSpinner in allSpinners.values) {
      if (existingSpinner.id == targetSpinner.id) continue;
      if (_areSpinnersContentIdentical(targetSpinner, existingSpinner))
        return existingSpinner;
    }
    return null;
  }

  static bool _areSpinnersContentIdentical(
    SpinnerModel spinner1,
    SpinnerModel spinner2,
  ) {
    if (spinner1.slices.length != spinner2.slices.length) return false;
    for (int i = 0; i < spinner1.slices.length; i++) {
      final option1 = spinner1.slices[i];
      final option2 = spinner2.slices[i];
      if (option1.text != option2.text ||
          option1.weight != option2.weight ||
          option1.isActive != option2.isActive)
        return false;
    }
    if (spinner1.colorThemeIndex != spinner2.colorThemeIndex ||
        spinner1.backgroundColors.length != spinner2.backgroundColors.length)
      return false;
    for (int i = 0; i < spinner1.backgroundColors.length; i++) {
      if (spinner1.backgroundColors[i] != spinner2.backgroundColors[i])
        return false;
    }
    return true;
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

  static Future<bool> spinnerNameExists(String name, {String? id}) async {
    if (_cachedActiveSpinner?.name == name && _cachedActiveSpinner?.id != id)
      return true;
    final allSpinners = await loadAllSpinners();
    return allSpinners.values.any((s) => s.name == name && s.id != id);
  }

  static Future<String> getActiveSpinnerId() async {
    if (_cachedActiveSpinnerId == null) {
      _cachedActiveSpinnerId = await _getActiveSpinnerId();
      if (_cachedActiveSpinnerId == null) {
        final allSpinners = _cachedSpinners ?? await loadAllSpinners();
        if (allSpinners.isNotEmpty) {
          _cachedActiveSpinnerId = allSpinners.keys.first;
          await setActiveSpinnerId(_cachedActiveSpinnerId!);
        }
      }
    }
    return _cachedActiveSpinnerId!;
  }

  static Future<bool> setActiveSpinnerId(String spinnerId) async {
    final success = await BaseStorageService.saveString(
      StorageConstants.activeSpinnerKey,
      spinnerId,
    );
    if (success) {
      _cachedActiveSpinnerId = spinnerId;
      if (_cachedSpinners?.containsKey(spinnerId) == true) {
        _cachedActiveSpinner = _cachedSpinners![spinnerId];
      } else {
        _cachedActiveSpinner = null;
      }
    }
    return success;
  }

  static void clearCache() {
    _cachedSpinners = null;
    _cachedActiveSpinnerId = null;
    _cachedActiveSpinner = null;
  }
}
