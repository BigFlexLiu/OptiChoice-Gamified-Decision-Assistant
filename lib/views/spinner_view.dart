import 'package:audioplayers/audioplayers.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/utils/logger.dart';
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
  String _currentOptionText = '';
  bool _isSpinning = false;
  bool _isLoading = true;
  bool _shouldAnimateText = false;
  Color _textColor = Colors.black;

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
    setState(() {
      _textColor = _getCurrentOptionColor;
    });
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

  Color get _getCurrentOptionColor {
    final defaultColor = Colors.black;
    if (_activeSpinner == null) return defaultColor;

    final colors = _activeSpinner!.colors;
    final currOptionIdx = _activeSpinner!.options.indexWhere(
      (e) => e.text == _currentOptionText,
    );

    if (currOptionIdx == -1) return defaultColor;

    return colors[currOptionIdx % colors.length];
  }

  Future<void> _loadActiveWheel() async {
    setState(() => _isLoading = true);

    try {
      final spinnerModel = await SpinnerStorageService.loadActiveSpinner();
      if (spinnerModel == null) {
        throw Exception('Spinner model is unexpectedly null.');
      }

      setState(() {
        _activeSpinner = spinnerModel;
        _currentOptionText = spinnerModel.options.isNotEmpty
            ? spinnerModel.options[0].text
            : '';
        _isLoading = false;
      });

      await _preloadAudioSources();
    } catch (e) {
      // Handle error by setting loading to false and showing empty state
      setState(() {
        _activeSpinner = null;
        _currentOptionText = '';
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadAudioSources() async {
    if (_activeSpinner == null) return;

    try {
      // Preload spin sound
      final spinSound = _activeSpinner?.spinSound;
      if (spinSound != null && spinSound.isNotEmpty) {
        final audioPath = AudioUtils.getSpinAudioPath(spinSound);
        _spinAudioAsset = AssetSource(audioPath);
      }

      // Preload spin end sound
      final spinEndSound = _activeSpinner?.spinEndSound;
      if (spinEndSound != null && spinEndSound.isNotEmpty) {
        final audioPath = AudioUtils.getSpinEndAudioPath(spinEndSound);
        _spinEndAudioAsset = AssetSource(audioPath);
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error preloading audio sources",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onSpinComplete(String selectedOption) async {
    setState(() {
      _isSpinning = false;
      _shouldAnimateText = true;
      _textColor = _getCurrentOptionColor;
    });

    await _playEndSpinSound();
  }

  void _onSpinStart() {
    setState(() {
      _isSpinning = true;
    });
  }

  void _onPointingOptionChanged(String option) {
    if (_isSpinning && option != _currentOptionText) {
      _playSpinSoundIfAvailable();
      setState(() {
        _currentOptionText = option;
      });
    }
  }

  AudioPlayer? _getNextAvailableSpinPlayer() {
    int checkIndex = _currentSpinPlayerIndex % _spinAudioPlayerCount;
    AudioPlayer player = _spinAudioPlayers[checkIndex];
    _currentSpinPlayerIndex = (checkIndex + 1) % _spinAudioPlayerCount;
    return player;
  }

  Future<void> _playSpinSoundIfAvailable() async {
    if (_spinAudioAsset == null) return;

    try {
      AudioPlayer? availablePlayer = _getNextAvailableSpinPlayer();

      if (availablePlayer != null) {
        await availablePlayer.stop();
        await availablePlayer.play(_spinAudioAsset!);
      }
    } catch (e, stackTrace) {
      logger.e("Error playing spin sound", error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _playEndSpinSound() async {
    if (_spinEndAudioAsset == null) return;

    try {
      await _spinEndAudioPlayer.stop();
      await _spinEndAudioPlayer.play(_spinEndAudioAsset!);
    } catch (e, stackTrace) {
      logger.e(
        "Error playing end spin sound",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _navigateToWheelsManagement() async {
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
      child: AnimatedTextJumpChangeColor(
        _currentOptionText,
        _shouldAnimateText,
        setShouldAnimateFalse,
        _textColor,
      ),
    );
  }

  void setShouldAnimateFalse() => {
    setState(() {
      _shouldAnimateText = false;
    }),
  };

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

class AnimatedTextJumpChangeColor extends StatefulWidget {
  final String text;
  final bool shouldAnimate;
  final void Function() setShouldAnimateFalse;
  final Color? color;
  const AnimatedTextJumpChangeColor(
    this.text,
    this.shouldAnimate,
    this.setShouldAnimateFalse,
    this.color, {
    super.key,
  });

  @override
  State<AnimatedTextJumpChangeColor> createState() =>
      _AnimatedTextJumpChangeColorState();
}

class _AnimatedTextJumpChangeColorState
    extends State<AnimatedTextJumpChangeColor> {
  final _animationTime = 500;
  bool _shouldAnimateJump = false;
  bool _shouldAnimateFall = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _shouldAnimateJump = widget.shouldAnimate;
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedTextJumpChangeColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.shouldAnimate &&
          !_shouldAnimateJump &&
          !_shouldAnimateFall) {
        setState(() {
          _shouldAnimateJump = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = (theme.textTheme.headlineLarge ?? TextStyle())
        .copyWith(inherit: false, fontWeight: FontWeight.w700);
    final maxFontSize = theme.textTheme.displayLarge!.fontSize;

    Text baseTextWidget = Text(
      widget.text,
      style: defaultTextStyle,
      textAlign: TextAlign.center,
    );
    if (!_shouldAnimateFall && !_shouldAnimateJump) {
      return AnimatedDefaultTextStyle(
        style: baseTextWidget.style!,
        duration: Duration(),
        onEnd: null,
        child: baseTextWidget,
      );
    }

    final jumpEndTextStyle = defaultTextStyle.copyWith(
      inherit: false,
      // color: widget.color,
      fontSize: maxFontSize,
    );
    if (_shouldAnimateJump) {
      return animateJump(jumpEndTextStyle);
    }

    // Animate fall after the jump
    final fallEndTextStyle = defaultTextStyle.copyWith(inherit: false);
    return animateFall(fallEndTextStyle);
  }

  Widget animateJump(TextStyle endStyle) {
    return AnimatedDefaultTextStyle(
      style: endStyle,
      duration: Duration(milliseconds: _animationTime ~/ 2),
      onEnd: () => {
        setState(() {
          _shouldAnimateJump = false;
          _shouldAnimateFall = true;
        }),
      },
      curve: Curves.easeOut,
      child: Text(widget.text, textAlign: TextAlign.center),
    );
  }

  Widget animateFall(TextStyle endStyle) {
    return AnimatedDefaultTextStyle(
      style: endStyle,
      duration: Duration(milliseconds: _animationTime ~/ 2),
      onEnd: () => {
        setState(() {
          _shouldAnimateJump = false;
          _shouldAnimateFall = false;
          widget.setShouldAnimateFalse();
        }),
      },
      curve: Curves.easeIn,
      child: Text(widget.text, textAlign: TextAlign.center),
    );
  }
}
