import 'package:flutter/material.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/providers/spinners_notifier.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';

class SpinnerProvider extends ChangeNotifier {
  SpinnerModel? _activeSpinner;
  bool _isInitialized = false;
  SpinnersNotifier? _spinnersNotifier;

  SpinnerModel? get activeSpinner => _activeSpinner;
  bool get isInitialized => _isInitialized;

  /// Set the SpinnersNotifier and initialize
  void setSpinnersNotifier(SpinnersNotifier spinnersNotifier) {
    // Remove previous listener if exists
    _spinnersNotifier?.removeListener(_onSpinnersChanged);

    _spinnersNotifier = spinnersNotifier;

    // Add listener for changes
    _spinnersNotifier!.addListener(_onSpinnersChanged);

    // Initialize if not already done
    if (!_isInitialized) {
      _initialize();
    }

    // Update active spinner from notifier
    _updateActiveSpinnerFromNotifier();
  }

  /// Initialize the provider
  void _initialize() {
    if (_spinnersNotifier != null && !_spinnersNotifier!.isInitialized) {
      _spinnersNotifier!.initialize();
    }
    _isInitialized = true;
  }

  /// Update active spinner from SpinnersNotifier
  void _updateActiveSpinnerFromNotifier() {
    if (_spinnersNotifier != null) {
      final newActiveSpinner = _spinnersNotifier!.activeSpinner;
      if (_activeSpinner?.id != newActiveSpinner?.id) {
        _activeSpinner = newActiveSpinner;
        notifyListeners();
      }
    }
  }

  /// Called when SpinnersNotifier changes
  void _onSpinnersChanged() {
    _updateActiveSpinnerFromNotifier();
  }

  /// Manually refresh the active spinner from storage
  Future<void> refreshActiveSpinner() async {
    if (_spinnersNotifier != null) {
      await _spinnersNotifier!.refreshCache();
      // The listener will handle updating _activeSpinner
    }
  }

  void setActiveSpinner(SpinnerModel? spinner) {
    if (spinner != null && _spinnersNotifier != null) {
      // Update via SpinnersNotifier
      _spinnersNotifier!.setActiveSpinnerId(spinner.id);
      // The listener will handle updating _activeSpinner and notifying listeners
    } else {
      _activeSpinner = null;
      notifyListeners();
    }
  }

  /// Toggle a single slice's active state
  Future<void> toggleSlice(Slice slice) async {
    if (_activeSpinner != null && _spinnersNotifier != null) {
      _activeSpinner!.toggleSliceIsActive(slice);
      await _saveCurrentSpinner();
    }
  }

  /// Toggle all slices to active state
  Future<void> setAllSlicesActive() async {
    if (_activeSpinner != null && _spinnersNotifier != null) {
      _activeSpinner!.setAllSlicesActive();
      await _saveCurrentSpinner();
    }
  }

  /// Update the active spinner with new data from the provided SpinnerModel
  Future<void> updateSpinner(SpinnerModel updatedSpinner) async {
    if (_activeSpinner != null &&
        _activeSpinner!.id == updatedSpinner.id &&
        _spinnersNotifier != null) {
      // Copy over the parameters from the updated spinner
      _activeSpinner!.name = updatedSpinner.name;
      _activeSpinner!.slices = updatedSpinner.slices;
      _activeSpinner!.colorThemeIndex = updatedSpinner.colorThemeIndex;
      _activeSpinner!.backgroundColors = updatedSpinner.backgroundColors;
      _activeSpinner!.customBackgroundColors =
          updatedSpinner.customBackgroundColors;
      _activeSpinner!.foregroundColors = updatedSpinner.foregroundColors;
      _activeSpinner!.spinSound = updatedSpinner.spinSound;
      _activeSpinner!.spinEndSound = updatedSpinner.spinEndSound;
      _activeSpinner!.spinDuration = updatedSpinner.spinDuration;
      _activeSpinner!.updatedAt = DateTime.now();
      await _saveCurrentSpinner();
    }
  }

  /// Save the current active spinner to storage via SpinnersNotifier
  Future<void> _saveCurrentSpinner() async {
    if (_activeSpinner != null && _spinnersNotifier != null) {
      await _spinnersNotifier!.saveSpinner(_activeSpinner!);
      notifyListeners();
    }
  }

  // Business Logic Methods - moved from SpinnersNotifier

  /// Find a spinner by name from cached data
  SpinnerModel? findSpinnerByName(String name) {
    return _spinnersNotifier?.findSpinnerByName(name);
  }

  /// Check if a spinner name exists (excluding a specific ID)
  bool spinnerNameExists(String name, {String? excludeId}) {
    return _spinnersNotifier?.spinnerNameExists(name, excludeId: excludeId) ??
        false;
  }

  /// Find a spinner with identical content (slices and colors)
  SpinnerModel? findSpinnerWithIdenticalContent(SpinnerModel targetSpinner) {
    return _spinnersNotifier?.findSpinnerWithIdenticalContent(targetSpinner);
  }

  /// Generate a unique name for a spinner
  String generateUniqueName(String baseName, {String? excludeId}) {
    return _spinnersNotifier?.generateUniqueName(
          baseName,
          excludeId: excludeId,
        ) ??
        baseName;
  }

  /// Create a new spinner with business logic validation
  Future<SpinnerModel?> createSpinner(
    String name,
    List<Slice> slices, {
    int colorThemeIndex = 0,
  }) async {
    if (_spinnersNotifier == null) return null;

    try {
      // Generate unique name
      final uniqueName = generateUniqueName(name);

      // Create via storage service
      final newSpinner = await SpinnerStorageService.createSpinner(
        uniqueName,
        slices,
        colorThemeIndex: colorThemeIndex,
      );

      if (newSpinner != null) {
        // Update cache and set as active via notifier
        await _spinnersNotifier!.refreshCache();
        await _spinnersNotifier!.setActiveSpinnerId(newSpinner.id);
      }

      return newSpinner;
    } catch (e) {
      debugPrint('Failed to create spinner: $e');
      return null;
    }
  }

  /// Duplicate an existing spinner with business logic
  Future<SpinnerModel?> duplicateSpinner(
    String originalId,
    String newName,
  ) async {
    if (_spinnersNotifier == null) return null;

    try {
      // Generate unique name
      final uniqueName = generateUniqueName(newName);

      // Duplicate via storage service
      final duplicatedSpinner = await SpinnerStorageService.duplicateSpinner(
        originalId,
        uniqueName,
      );

      if (duplicatedSpinner != null) {
        // Update cache
        await _spinnersNotifier!.refreshCache();
      }

      return duplicatedSpinner;
    } catch (e) {
      debugPrint('Failed to duplicate spinner: $e');
      return null;
    }
  }

  /// Delete a spinner with business logic validation
  Future<bool> deleteSpinner(String id) async {
    if (_spinnersNotifier == null) return false;

    // Prevent deleting if it's the last spinner
    final cachedSpinners = _spinnersNotifier!.spinners;
    if (cachedSpinners == null || cachedSpinners.length <= 1) return false;

    try {
      final success = await SpinnerStorageService.deleteSpinner(id);

      if (success) {
        // Update cache and handle active spinner change
        await _spinnersNotifier!.refreshCache();
      }

      return success;
    } catch (e) {
      debugPrint('Failed to delete spinner: $e');
      return false;
    }
  }

  /// Save a spinner with business logic
  Future<bool> saveSpinner(SpinnerModel spinner) async {
    if (_spinnersNotifier == null) return false;
    try {
      // Update timestamp
      spinner.updatedAt = DateTime.now();

      // Save via storage service
      final success = await SpinnerStorageService.saveSpinner(spinner);

      if (success) {
        // Update cache
        await _spinnersNotifier!.refreshCache();
      }

      return success;
    } catch (e) {
      debugPrint('Failed to save spinner: $e');
      return false;
    }
  }

  /// Save the order of spinners
  Future<void> saveSpinnerOrder(List<String> orderedIds) async {
    if (_spinnersNotifier == null) return;

    try {
      await SpinnerStorageService.saveSpinnerOrder(orderedIds);
      // Update cache to reflect new order
      await _spinnersNotifier!.refreshCache();
    } catch (e) {
      debugPrint('Failed to save spinner order: $e');
    }
  }

  @override
  void dispose() {
    // Remove listener from SpinnersNotifier
    _spinnersNotifier?.removeListener(_onSpinnersChanged);
    super.dispose();
  }
}
