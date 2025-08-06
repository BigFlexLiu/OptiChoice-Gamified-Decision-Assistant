import 'package:decision_spinner/utils/spinner_audio_manager.dart';
import 'package:decision_spinner/views/manage_spinners_view.dart';
import 'package:decision_spinner/views/spinner_template_view.dart';
import 'package:decision_spinner/views/edit_spinner_view.dart';
import 'package:decision_spinner/widgets/animated_text.dart';
import 'package:decision_spinner/widgets/spinner_wheel.dart';
import 'package:flutter/material.dart';
import '../storage/spinner_storage_service.dart';
import '../storage/spinner_model.dart';

class SpinnerView extends StatefulWidget {
  const SpinnerView({super.key});

  @override
  SpinnerViewState createState() => SpinnerViewState();
}

class SpinnerViewState extends State<SpinnerView> with WidgetsBindingObserver {
  SpinnerModel? _activeSpinner;
  late Slice? _currentSpinnerOption;
  bool _isSpinning = false;
  bool _isLoading = true;
  bool _shouldAnimateText = false;

  bool _showCompleteSpinActions = false;
  bool _showRemoveSlice = false;

  // Audio manager for spinner sounds
  late SpinnerAudioManager _audioManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioManager = SpinnerAudioManager();
    _loadActiveSpinner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_activeSpinner == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Decision Spinner'),
          actions: [
            Tooltip(
              message: 'Manage Spinner',
              child: IconButton(
                icon: Icon(Icons.settings),
                onPressed: _navigateToWheelsManagement,
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Active spinner wheel found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Please check your settings or try restarting the app',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadActiveSpinner,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Expanded(child: _buildSpinnerWheelSection())],
          ),
          Column(
            children: [
              const SizedBox(height: 64),
              _buildCurrentPointingOption(),
            ],
          ),
          if (_showCompleteSpinActions)
            Column(
              children: [
                Expanded(child: Container()),
                SizedBox(height: 24),
                if (_showRemoveSlice &&
                    _activeSpinner != null &&
                    _activeSpinner!.activeSlicesCount > 2)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_activeSpinner != null &&
                          _currentSpinnerOption != null) {
                        _activeSpinner!.toggleSliceIsActive(
                          _currentSpinnerOption!,
                        );
                        setState(() {
                          _showRemoveSlice = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.incomplete_circle,
                      size: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    ), // the icon
                    label: Text(
                      'Remove Slice',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.fontSize,
                      ),
                    ), // the text
                  ),
                SizedBox(height: 72),
              ],
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: Tooltip(
        message: 'Manage Spinners',
        child: IconButton(
          icon: Icon(Icons.list),
          onPressed: () async {
            _onSpinEndPrematurely();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ManageSpinnerView()),
            );
            await _loadActiveSpinner();
          },
        ),
      ),
      title: Text(_activeSpinner?.name ?? 'Decision Spinner'),
      actions: [
        Tooltip(
          message: 'Spinner Templates',
          child: IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () async {
              _onSpinEndPrematurely();
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const SpinnerTemplatesView(),
                ),
              );

              // If a spinner was successfully added, reload the active spinner
              if (result == true) {
                await _loadActiveSpinner();
              }
            },
          ),
        ),
        Tooltip(
          message: 'Manage Wheels',
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToWheelsManagement,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPointingOption() {
    final theme = Theme.of(context);

    if (_activeSpinner!.slices.isEmpty) {
      return Center(
        child: Text(
          'No slice available',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: AnimatedTextJumpChangeColor(
        _currentSpinnerOption?.text ?? "",
        _shouldAnimateText,
        setShouldAnimateFalse,
      ),
    );
  }

  Widget _buildSpinnerWheelSection() {
    if (_activeSpinner!.slices.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.casino_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No spinner to spin',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add some slices to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SpinnerWheel(
        spinnerModel: _activeSpinner!,
        isSpinning: _isSpinning,
        onSpinStart: _onSpinStart,
        onSpinComplete: _onSpinComplete,
        onPointingOptionChanged: _onPointingOptionChanged,
      ),
    );
  }

  void _navigateToWheelsManagement() async {
    _onSpinEndPrematurely();
    if (_activeSpinner == null) {
      return;
    }
    // Navigate to SpinnerManager and reload active wheel when returning
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSpinnerView(spinner: _activeSpinner!),
      ),
    );

    // Reload active wheel when returning from management screen
    await _loadActiveSpinner();
  }

  void _onSpinStart() {
    // Use addPostFrameCallback to ensure setState is not called during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isSpinning = true;
        });
      }
    });
  }

  void _onSpinComplete(String selectedOption) async {
    // Use addPostFrameCallback to ensure setState is not called during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _shouldAnimateText = true;
          _showCompleteSpinActions = true;
          _showRemoveSlice = true;
        });
      }
    });

    await _audioManager.playEndSpinSound();
  }

  void _onSpinEndPrematurely() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _shouldAnimateText = false;
        });
      }
    });
  }

  void _onPointingOptionChanged(Slice option) {
    if (option != _currentSpinnerOption) {
      _audioManager.playSpinSoundIfAvailable();
      // Use addPostFrameCallback to ensure setState is not called during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentSpinnerOption = option;
          });
        }
      });
    }
  }

  void setShouldAnimateFalse() {
    // Use addPostFrameCallback to ensure setState is not called during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _shouldAnimateText = false;
        });
      }
    });
  }

  Future<void> _loadActiveSpinner() async {
    setState(() => _isLoading = true);

    try {
      final spinnerModel = await SpinnerStorageService.loadActiveSpinner();
      if (spinnerModel == null) {
        throw Exception('Spinner model is unexpectedly null.');
      }

      setState(() {
        // Check if this is the same spinner and preserve current option if possible
        Slice? preservedOption;
        if (_activeSpinner != null &&
            _activeSpinner!.id == spinnerModel.id &&
            _currentSpinnerOption != null) {
          // Try to find the same option in the new spinner model
          preservedOption = spinnerModel.slices
              .where((option) => option.text == _currentSpinnerOption!.text)
              .firstOrNull;
        }

        _activeSpinner = spinnerModel;
        _currentSpinnerOption = preservedOption ?? spinnerModel.slices.first;
        _showRemoveSlice = false;
        _isLoading = false;
      });

      await _audioManager.preloadAudioSources(_activeSpinner);
    } catch (e) {
      // Handle error by setting loading to false and showing empty state
      setState(() {
        _activeSpinner = null;
        _currentSpinnerOption = null;
        _isLoading = false;
      });
    }
  }
}
