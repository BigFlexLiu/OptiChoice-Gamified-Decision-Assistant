import 'package:audioplayers/audioplayers.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/utils/logger.dart';
import '../storage/spinner_model.dart';

class SpinnerAudioManager {
  // Audio players for spinner sounds - configurable count
  static const int _spinAudioPlayerCount = 10;
  final List<AudioPlayer> _spinAudioPlayers = [];

  int _currentSpinPlayerIndex = 0;
  final AudioPlayer _spinEndAudioPlayer = AudioPlayer();

  AssetSource? _spinAudioAsset;
  AssetSource? _spinEndAudioAsset;

  SpinnerAudioManager() {
    _initializeAudioPlayers();
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

  Future<void> preloadAudioSources(SpinnerModel? activeSpinner) async {
    if (activeSpinner == null) return;

    try {
      // Preload spin sound
      final spinSound = activeSpinner.spinSound;
      if (spinSound != null && spinSound.isNotEmpty) {
        final audioPath = AudioUtils.getSpinAudioPath(spinSound);
        _spinAudioAsset = AssetSource(audioPath);
      } else {
        _spinAudioAsset = null;
      }

      // Preload spin end sound
      final spinEndSound = activeSpinner.spinEndSound;
      if (spinEndSound != null && spinEndSound.isNotEmpty) {
        final audioPath = AudioUtils.getSpinEndAudioPath(spinEndSound);
        _spinEndAudioAsset = AssetSource(audioPath);
      } else {
        _spinEndAudioAsset = null;
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error preloading audio sources",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  AudioPlayer? _getNextAvailableSpinPlayer() {
    int checkIndex = _currentSpinPlayerIndex % _spinAudioPlayerCount;
    AudioPlayer player = _spinAudioPlayers[checkIndex];
    _currentSpinPlayerIndex = (checkIndex + 1) % _spinAudioPlayerCount;
    return player;
  }

  Future<void> playSpinSoundIfAvailable() async {
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

  Future<void> playEndSpinSound() async {
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

  void dispose() {
    // Dispose all audio players
    for (final player in _spinAudioPlayers) {
      player.dispose();
    }
    _spinEndAudioPlayer.dispose();
  }
}
