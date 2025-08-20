import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/utils/logger.dart';
import '../storage/spinner_model.dart';

class SpinnerAudioManager {
  String? _spinAudioPath;
  String? _spinEndAudioPath;
  AudioSource? _spinAudioSource;
  AudioSource? _spinEndAudioSource;

  Future<void> loadAudioSources(SpinnerModel? activeSpinner) async {
    if (activeSpinner == null) return;

    try {
      if (activeSpinner.spinSound != _spinAudioPath) {
        _spinAudioPath = activeSpinner.spinSound;
        _spinAudioSource = await _loadAudioSource(
          activeSpinner.spinSound,
          AudioUtils.getSpinAudioPath,
        );
      }
      if (activeSpinner.spinEndSound != _spinEndAudioPath) {
        _spinEndAudioPath = activeSpinner.spinEndSound;
        _spinEndAudioSource = await _loadAudioSource(
          activeSpinner.spinEndSound,
          AudioUtils.getSpinEndAudioPath,
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error preloading audio sources",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AudioSource?> _loadAudioSource(
    String? soundName,
    String Function(String) getPath,
  ) async {
    if (soundName?.isNotEmpty == true) {
      return await SoLoud.instance.loadAsset('assets/${getPath(soundName!)}');
    }
    return null;
  }

  Future<void> playSpinSoundIfAvailable() async {
    await _playSound(_spinAudioSource, "spin");
  }

  Future<void> playEndSpinSound() async {
    await _playSound(_spinEndAudioSource, "end spin");
  }

  Future<void> _playSound(AudioSource? source, String type) async {
    if (source != null) {
      try {
        await SoLoud.instance.play(source);
      } catch (e, stackTrace) {
        logger.e("Error playing $type sound", error: e, stackTrace: stackTrace);
      }
    }
  }

  void dispose() {
    [
      _spinAudioSource,
      _spinEndAudioSource,
    ].whereType<AudioSource>().forEach(SoLoud.instance.disposeSource);
  }
}
