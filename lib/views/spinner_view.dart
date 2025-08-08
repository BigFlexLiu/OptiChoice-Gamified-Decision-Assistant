import 'package:decision_spinner/utils/spinner_audio_manager.dart';
import 'package:decision_spinner/views/manage_spinners_view.dart';
import 'package:decision_spinner/views/spinner_template_view.dart';
import 'package:decision_spinner/views/edit_spinner_view.dart';
import 'package:decision_spinner/widgets/animated_text.dart';
import 'package:decision_spinner/widgets/spinner_wheel.dart';
import 'package:decision_spinner/providers/spinner_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../storage/spinner_model.dart';

class SpinnerView extends StatefulWidget {
  const SpinnerView({super.key});

  @override
  SpinnerViewState createState() => SpinnerViewState();
}

class SpinnerViewState extends State<SpinnerView> with WidgetsBindingObserver {
  Slice? _currentSpinnerOption;
  bool _isSpinning = false;
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpinnerProvider>(
      builder: (context, spinnerProvider, child) {
        if (!spinnerProvider.isInitialized) {
          return _buildLoadingScreen('Loading spinner...');
        }

        final activeSpinner = spinnerProvider.activeSpinner;

        if (activeSpinner == null) {
          return _buildErrorScreen(spinnerProvider);
        }

        // Initialize current option if needed
        _ensureCurrentOptionInitialized(activeSpinner);

        return Scaffold(
          appBar: _buildAppBar(activeSpinner),
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: _buildSpinnerWheelSection(activeSpinner)),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 64),
                  _buildCurrentPointingOption(activeSpinner),
                ],
              ),
              if (_showCompleteSpinActions)
                _buildCompleteSpinActions(spinnerProvider, activeSpinner),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(SpinnerProvider spinnerProvider) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Decision Spinner'),
        actions: [
          Tooltip(
            message: 'Manage Spinner',
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => spinnerProvider.refreshActiveSpinner(),
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
              onPressed: () => spinnerProvider.refreshActiveSpinner(),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteSpinActions(
    SpinnerProvider spinnerProvider,
    SpinnerModel activeSpinner,
  ) {
    return Column(
      children: [
        Expanded(child: Container()),
        SizedBox(height: 24),
        if (_showRemoveSlice && activeSpinner.activeSlicesCount > 2)
          ElevatedButton.icon(
            onPressed: () {
              if (_currentSpinnerOption != null) {
                spinnerProvider.toggleSlice(_currentSpinnerOption!);
                setState(() => _showRemoveSlice = false);
              }
            },
            icon: Icon(
              Icons.incomplete_circle,
              size: Theme.of(context).textTheme.bodyLarge!.fontSize,
            ),
            label: Text(
              'Remove Slice',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
              ),
            ),
          ),
        SizedBox(height: 72),
      ],
    );
  }

  AppBar _buildAppBar(SpinnerModel activeSpinner) {
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
            // Provider will automatically refresh when we return
          },
        ),
      ),
      title: Text(activeSpinner.name),
      actions: [
        Tooltip(
          message: 'Spinner Templates',
          child: IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () async {
              _onSpinEndPrematurely();
              await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const SpinnerTemplatesView(),
                ),
              );

              // Provider will automatically refresh if a spinner was successfully added
            },
          ),
        ),
        Tooltip(
          message: 'Manage Wheels',
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _navigateToWheelsManagement(activeSpinner),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPointingOption(SpinnerModel activeSpinner) {
    final theme = Theme.of(context);

    if (activeSpinner.slices.isEmpty) {
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

  Widget _buildSpinnerWheelSection(SpinnerModel activeSpinner) {
    if (activeSpinner.slices.isEmpty) {
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
        spinnerModel: activeSpinner,
        isSpinning: _isSpinning,
        onSpinStart: _onSpinStart,
        onSpinComplete: _onSpinComplete,
        onPointingOptionChanged: _onPointingOptionChanged,
      ),
    );
  }

  void _navigateToWheelsManagement(SpinnerModel activeSpinner) async {
    _onSpinEndPrematurely();
    // Navigate to SpinnerManager
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSpinnerView(spinner: activeSpinner),
      ),
    );
    // Provider will automatically refresh when we return
  }

  void _onSpinStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isSpinning = true);
    });
  }

  void _onSpinComplete(String selectedOption) async {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentSpinnerOption = option);
      });
    }
  }

  void setShouldAnimateFalse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shouldAnimateText = false);
    });
  }

  void _ensureCurrentOptionInitialized(SpinnerModel activeSpinner) {
    if (_currentSpinnerOption == null ||
        !activeSpinner.slices.any(
          (slice) => slice.text == _currentSpinnerOption!.text,
        )) {
      if (activeSpinner.slices.isNotEmpty) {
        _currentSpinnerOption = activeSpinner.slices.first;
        _audioManager.preloadAudioSources(activeSpinner);
      }
    }
  }
}
