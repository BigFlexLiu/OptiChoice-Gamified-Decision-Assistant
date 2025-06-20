import 'package:audioplayers/audioplayers.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/views/all_spinners_view.dart';
import 'package:decision_spinner/views/spinner_options_view.dart';
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
  String _currentPointingOption = '';
  bool _isSpinning = false;
  bool _isLoading = true;

  // Audio players for spinner sounds - configurable count
  static const int _spinAudioPlayerCount = 10;
  final List<AudioPlayer> _spinAudioPlayers = [];

  int _currentSpinPlayerIndex = 0;
  final AudioPlayer _spinEndAudioPlayer = AudioPlayer();

  AssetSource? _spinAudioAsset;
  AssetSource? _spinEndAudioAsset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAudioPlayers();
    _loadActiveWheel();
  }

  void _initializeAudioPlayers() {
    // Initialize the spin audio players
    for (int i = 0; i < _spinAudioPlayerCount; i++) {
      _spinAudioPlayers.add(
        AudioPlayer()
          ..setPlayerMode(PlayerMode.lowLatency)
          ..setReleaseMode(ReleaseMode.stop),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose all audio players
    for (final player in _spinAudioPlayers) {
      player.dispose();
    }
    _spinEndAudioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadActiveWheel();
    }
  }

  Future<void> _loadActiveWheel() async {
    setState(() => _isLoading = true);

    try {
      // Load the active wheel from the storage service
      final wheel = await SpinnerStorageService.loadActiveSpinner();

      if (wheel != null) {
        setState(() {
          _activeSpinner = wheel;
          _currentPointingOption = wheel.options.isNotEmpty
              ? wheel.options[0].text
              : '';
          _isLoading = false;
        });

        // Preload audio after setting the active spinner
        await _preloadAudioSources();
      } else {
        // This shouldn't happen as SpinnerStorageService creates default if none exist
        // But handle it gracefully just in case
        setState(() {
          _activeSpinner = null;
          _currentPointingOption = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error by setting loading to false and showing empty state
      setState(() {
        _activeSpinner = null;
        _currentPointingOption = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadAudioSources() async {
    if (_activeSpinner == null) return;

    try {
      // Preload spin sound
      if (_activeSpinner!.spinSound != null &&
          _activeSpinner!.spinSound!.isNotEmpty) {
        final audioPath = AudioUtils.getSpinAudioPath(
          _activeSpinner!.spinSound!,
        );
        _spinAudioAsset = AssetSource(audioPath);
      }

      // Preload spin end sound
      if (_activeSpinner!.spinEndSound != null &&
          _activeSpinner!.spinEndSound!.isNotEmpty) {
        final audioPath = AudioUtils.getSpinEndAudioPath(
          _activeSpinner!.spinEndSound!,
        );

        _spinEndAudioAsset = AssetSource(audioPath);
      }
    } catch (e) {
      print('Error preloading audio sources: $e');
    }
  }

  void _onSpinComplete(String selectedOption) async {
    setState(() {
      _isSpinning = false;
      // _currentPointingOption = selectedOption;
    });

    // Play end spin sound if configured
    await _playEndSpinSound();
  }

  void _onSpinStart() {
    setState(() {
      _isSpinning = true;
    });
  }

  void _onPointingOptionChanged(String option) {
    if (_isSpinning && option != _currentPointingOption) {
      _playSpinSoundIfAvailable();
      setState(() {
        _currentPointingOption = option;
      });
    }
  }

  AudioPlayer? _getNextAvailableSpinPlayer() {
    // Start from the current index and look for an available player
    for (int i = 0; i < _spinAudioPlayerCount; i++) {
      int checkIndex = (_currentSpinPlayerIndex + i) % _spinAudioPlayerCount;
      AudioPlayer player = _spinAudioPlayers[checkIndex];

      // Check if this player is available (not playing)
      // if (player.state == PlayerState.playing) continue;
      _currentSpinPlayerIndex = (checkIndex + 1) % _spinAudioPlayerCount;
      return player;
    }

    // No available player found
    return null;
  }

  Future<void> _playSpinSoundIfAvailable() async {
    if (_spinAudioAsset == null) return;

    try {
      // Get the next available player
      AudioPlayer? availablePlayer = _getNextAvailableSpinPlayer();

      if (availablePlayer != null) {
        // Play the preloaded sound
        await availablePlayer.stop();
        await availablePlayer.play(_spinAudioAsset!);
      }
      // If no player is available, we simply don't play the sound
    } catch (e) {
      print('Error playing spin sound: $e');
    }
  }

  Future<void> _playEndSpinSound() async {
    if (_spinEndAudioAsset == null) return;

    try {
      // Stop any currently playing end sound and play the new one
      await _spinEndAudioPlayer.stop();
      await _spinEndAudioPlayer.play(_spinEndAudioAsset!);
    } catch (e) {
      print('Error playing end spin sound: $e');
    }
  }

  void _navigateToWheelsManagement() async {
    // Do nothing if no active spinner
    if (_activeSpinner == null) {
      return;
    }
    // Navigate to SpinnerManager and reload active wheel when returning
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpinnerOptionsView(spinner: _activeSpinner!),
      ),
    );

    // Reload active wheel when returning from management screen
    await _loadActiveWheel();
  }

  // ...existing code...

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
              ElevatedButton(onPressed: _loadActiveWheel, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 32),
          Expanded(child: _buildCurrentPointingOption()),
          Expanded(flex: 5, child: _buildSpinnerWheelSection()),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(_activeSpinner?.name ?? 'Decision Spinner'),
      actions: [
        Tooltip(
          message: 'All Spinners',
          child: IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => AllSpinnerView()));
              // Reload active wheel when returning from all spinners view
              await _loadActiveWheel();
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

    if (_activeSpinner!.options.isEmpty) {
      return Center(
        child: Text(
          'No options available',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Center(
      child: Text(
        _currentPointingOption,
        style: theme.textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSpinnerWheelSection() {
    if (_activeSpinner!.options.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.casino_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No options to spin',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add some options to get started',
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
}
