import 'package:flutter/material.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:decision_spinner/storage/spinner_storage_service.dart';

class SpinnerProvider extends ChangeNotifier {
  SpinnerModel? _activeSpinner;
  bool _isInitialized = false;

  SpinnerModel? get activeSpinner => _activeSpinner;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider and load the active spinner
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Register callback to receive updates from storage service
    SpinnerStorageService.setActiveSpinnerChangeCallback(
      _onActiveSpinnerChanged,
    );

    // Load the initial active spinner
    _activeSpinner = await SpinnerStorageService.loadActiveSpinner();
    _isInitialized = true;
    notifyListeners();
  }

  /// Called by SpinnerStorageService when the active spinner changes
  void _onActiveSpinnerChanged(SpinnerModel? spinner) {
    if (_activeSpinner?.id != spinner?.id) {
      _activeSpinner = spinner;
      notifyListeners();
    }
  }

  /// Manually refresh the active spinner from storage
  Future<void> refreshActiveSpinner() async {
    _activeSpinner = await SpinnerStorageService.loadActiveSpinner();
    notifyListeners();
  }

  void setActiveSpinner(SpinnerModel? spinner) {
    if (spinner != null) {
      // Update storage service's active spinner ID
      SpinnerStorageService.setActiveSpinnerId(spinner.id);
      // The callback will handle updating _activeSpinner and notifying listeners
    } else {
      _activeSpinner = null;
      notifyListeners();
    }
  }

  /// Toggle a single slice's active state
  void toggleSlice(Slice slice) {
    if (_activeSpinner != null) {
      _activeSpinner!.toggleSliceIsActive(slice);
      _saveCurrentSpinner();
    }
  }

  /// Toggle all slices to active state
  void setAllSlicesActive() {
    if (_activeSpinner != null) {
      _activeSpinner!.setAllSlicesActive();
      _saveCurrentSpinner();
    }
  }

  /// Update the active spinner with new data from the provided SpinnerModel
  void updateSpinner(SpinnerModel updatedSpinner) {
    if (_activeSpinner != null && _activeSpinner!.id == updatedSpinner.id) {
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
      _saveCurrentSpinner();
    }
  }

  /// Save the current active spinner to storage
  void _saveCurrentSpinner() {
    if (_activeSpinner != null) {
      SpinnerStorageService.saveSpinner(_activeSpinner!);
      notifyListeners();
    }
  }
}
