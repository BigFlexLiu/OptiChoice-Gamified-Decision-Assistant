import 'package:flutter/material.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';

/// A ChangeNotifier that manages the cached spinners and active spinner state.
/// This replaces the singleton caching logic in SpinnerStorageService.
class SpinnersNotifier extends ChangeNotifier {
  Map<String, SpinnerModel>? _cachedSpinners;
  String? _activeSpinnerId;
  SpinnerModel? _activeSpinner;
  bool _isInitialized = false;

  // Getters
  Map<String, SpinnerModel>? get cachedSpinners => _cachedSpinners;
  String? get activeSpinnerId => _activeSpinnerId;
  SpinnerModel? get activeSpinner => _activeSpinner;
  bool get isInitialized => _isInitialized;

  /// Initialize the notifier by loading all spinners and setting the active one
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load all spinners from storage
      _cachedSpinners = await SpinnerStorageService.loadAllSpinners();

      // Load active spinner ID
      _activeSpinnerId = await SpinnerStorageService.getActiveSpinnerId();

      // Set active spinner based on ID
      if (_activeSpinnerId != null &&
          _cachedSpinners!.containsKey(_activeSpinnerId)) {
        _activeSpinner = _cachedSpinners![_activeSpinnerId];
      } else if (_cachedSpinners!.isNotEmpty) {
        // Fallback to first spinner if active ID not found
        _activeSpinner = _cachedSpinners!.values.first;
        _activeSpinnerId = _activeSpinner!.id;
        await SpinnerStorageService.setActiveSpinnerId(_activeSpinnerId!);
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
    return _cachedSpinners?[id];
  }

  /// Find a spinner by name
  SpinnerModel? findSpinnerByName(String name) {
    if (_cachedSpinners == null) return null;

    for (final spinner in _cachedSpinners!.values) {
      if (spinner.name == name) return spinner;
    }
    return null;
  }

  /// Check if a spinner name exists (excluding a specific ID)
  bool spinnerNameExists(String name, {String? excludeId}) {
    if (_cachedSpinners == null) return false;

    return _cachedSpinners!.values.any(
      (spinner) => spinner.name == name && spinner.id != excludeId,
    );
  }

  /// Find a spinner with identical content (slices and colors)
  SpinnerModel? findSpinnerWithIdenticalContent(SpinnerModel targetSpinner) {
    if (_cachedSpinners == null) return null;

    for (final existingSpinner in _cachedSpinners!.values) {
      if (existingSpinner.id == targetSpinner.id) continue;
      if (targetSpinner.isContentIdenticalTo(existingSpinner)) {
        return existingSpinner;
      }
    }
    return null;
  }

  /// Generate a unique name for a spinner
  String generateUniqueName(String baseName, {String? excludeId}) {
    if (_cachedSpinners == null) return baseName;

    final nameExists = _cachedSpinners!.values.any(
      (spinner) => spinner.name == baseName && spinner.id != excludeId,
    );
    if (!nameExists) return baseName;

    for (int counter = 1; ; counter++) {
      final candidateName = '$baseName ($counter)';
      final candidateExists = _cachedSpinners!.values.any(
        (spinner) => spinner.name == candidateName && spinner.id != excludeId,
      );
      if (!candidateExists) return candidateName;
    }
  }

  /// Save a single spinner and update cache
  Future<bool> saveSpinner(SpinnerModel spinner) async {
    if (_cachedSpinners == null) return false;

    try {
      // Save to storage first
      final storageSuccess = await SpinnerStorageService.saveSpinner(spinner);
      if (!storageSuccess) return false;

      // Update cache
      _cachedSpinners![spinner.id] = spinner;

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
        _cachedSpinners = spinners;

        // Update active spinner if it exists in the new set
        if (_activeSpinnerId != null &&
            spinners.containsKey(_activeSpinnerId)) {
          _activeSpinner = spinners[_activeSpinnerId];
        } else if (spinners.isNotEmpty) {
          // Fallback to first spinner
          _activeSpinner = spinners.values.first;
          _activeSpinnerId = _activeSpinner!.id;
          await SpinnerStorageService.setActiveSpinnerId(_activeSpinnerId!);
        }

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
    if (_cachedSpinners == null || !_cachedSpinners!.containsKey(spinnerId)) {
      return false;
    }

    try {
      final success = await SpinnerStorageService.setActiveSpinnerId(spinnerId);

      if (success) {
        _activeSpinnerId = spinnerId;
        _activeSpinner = _cachedSpinners![spinnerId];
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Failed to set active spinner: $e');
      return false;
    }
  }

  /// Refresh the cache by reloading from storage
  Future<void> refreshCache() async {
    try {
      _cachedSpinners = await SpinnerStorageService.loadAllSpinners();

      if (_activeSpinnerId != null &&
          _cachedSpinners!.containsKey(_activeSpinnerId)) {
        _activeSpinner = _cachedSpinners![_activeSpinnerId];
      } else if (_cachedSpinners!.isNotEmpty) {
        _activeSpinner = _cachedSpinners!.values.first;
        _activeSpinnerId = _activeSpinner!.id;
        await SpinnerStorageService.setActiveSpinnerId(_activeSpinnerId!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh cache: $e');
    }
  }

  /// Clear the cache and reset state
  void clearCache() {
    _cachedSpinners = null;
    _activeSpinnerId = null;
    _activeSpinner = null;
    _isInitialized = false;
    notifyListeners();
  }
}
