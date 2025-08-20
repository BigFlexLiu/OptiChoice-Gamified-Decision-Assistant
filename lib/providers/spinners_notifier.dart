import 'package:flutter/material.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';

/// A ChangeNotifier that manages the cached spinners and active spinner state.
/// This replaces the singleton caching logic in SpinnerStorageService.
class SpinnersNotifier extends ChangeNotifier {
  Map<String, SpinnerModel>? _spinners;
  SpinnerModel? _activeSpinner;
  bool _isInitialized = false;

  // Getters
  Map<String, SpinnerModel>? get spinners => _spinners;
  SpinnerModel? get activeSpinner => _activeSpinner;
  bool get isInitialized => _isInitialized;

  /// Initialize the notifier by loading all spinners and setting the active one
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load all spinners from storage
      _spinners = await SpinnerStorageService.loadAllSpinners();

      // Load active spinner ID
      final activeSpinnerId = await SpinnerStorageService.getActiveSpinnerId();

      // Set active spinner based on ID
      if (_spinners!.containsKey(activeSpinnerId)) {
        _activeSpinner = _spinners![activeSpinnerId];
      } else if (_spinners!.isNotEmpty) {
        // Fallback to first spinner if active ID not found
        _activeSpinner = _spinners!.values.first;
        await SpinnerStorageService.setActiveSpinnerId(activeSpinnerId!);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize SpinnersNotifier: $e');
      _isInitialized = false;
    }
  }

  /// Get a spinner by ID from cache, or null if not found
  SpinnerModel? getSpinnerById(String id) {
    return _spinners?[id];
  }

  /// Find a spinner by name
  SpinnerModel? findSpinnerByName(String name) {
    if (_spinners == null) return null;

    for (final spinner in _spinners!.values) {
      if (spinner.name == name) return spinner;
    }
    return null;
  }

  /// Check if a spinner name exists (excluding a specific ID)
  bool spinnerNameExists(String name, {String? excludeId}) {
    if (_spinners == null) return false;

    return _spinners!.values.any(
      (spinner) => spinner.name == name && spinner.id != excludeId,
    );
  }

  /// Find a spinner with identical content (slices and colors)
  SpinnerModel? findSpinnerWithIdenticalContent(SpinnerModel targetSpinner) {
    if (_spinners == null) return null;

    for (final existingSpinner in _spinners!.values) {
      if (existingSpinner.id == targetSpinner.id) continue;
      if (targetSpinner.isContentIdenticalTo(existingSpinner)) {
        return existingSpinner;
      }
    }
    return null;
  }

  /// Generate a unique name for a spinner
  String generateUniqueName(String baseName, {String? excludeId}) {
    if (_spinners == null) return baseName;

    final nameExists = _spinners!.values.any(
      (spinner) => spinner.name == baseName && spinner.id != excludeId,
    );
    if (!nameExists) return baseName;

    for (int counter = 1; ; counter++) {
      final candidateName = '$baseName ($counter)';
      final candidateExists = _spinners!.values.any(
        (spinner) => spinner.name == candidateName && spinner.id != excludeId,
      );
      if (!candidateExists) return candidateName;
    }
  }

  /// Save a single spinner and update cache
  Future<bool> saveSpinner(SpinnerModel spinner) async {
    if (_spinners == null) return false;

    try {
      // Save to storage first
      final storageSuccess = await SpinnerStorageService.saveSpinner(spinner);
      if (!storageSuccess) return false;

      // Update cache
      _spinners![spinner.id] = spinner;

      // Update active spinner if it's the same ID
      if (_activeSpinner?.id == spinner.id) {
        _activeSpinner = spinner;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to save spinner: $e');
      return false;
    }
  }

  /// Save all spinners to storage
  Future<bool> saveAllSpinners(Map<String, SpinnerModel> spinners) async {
    try {
      final success = await SpinnerStorageService.saveAllSpinners(spinners);
      if (success) {
        _spinners = spinners;

        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save all spinners: $e');
      return false;
    }
  }

  /// Set the active spinner by ID
  Future<bool> setActiveSpinnerId(String spinnerId) async {
    if (_spinners == null || !_spinners!.containsKey(spinnerId)) {
      return false;
    }

    try {
      final success = await SpinnerStorageService.setActiveSpinnerId(spinnerId);

      if (success) {
        _activeSpinner = _spinners![spinnerId];
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Failed to set active spinner: $e');
      return false;
    }
  }

  Future<void> refreshCache() async {
    try {
      final results = await Future.wait([
        SpinnerStorageService.loadAllSpinners(),
        SpinnerStorageService.loadActiveSpinner(),
      ]);

      _spinners = results[0] as Map<String, SpinnerModel>?;
      _activeSpinner = results[1] as SpinnerModel?;

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh cache: $e');
    }
  }
}
