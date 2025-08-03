import 'dart:convert';
import 'package:decision_spinner/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioUtils {
  static const String spinAudioPath = 'assets/audio/spin_audio';
  static const String spinEndAudioPath = 'assets/audio/spin_end_audio';

  // Static sound handle for previews
  static SoundHandle? _previewHandle;

  static Future<List<String>> getSpinAudioFiles() async {
    return await _getAudioFiles(spinAudioPath);
  }

  static Future<List<String>> getSpinEndAudioFiles() async {
    return await _getAudioFiles(spinEndAudioPath);
  }

  static Future<List<String>> _getAudioFiles(String assetPath) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map<String, dynamic>.from(
        json.decode(manifestContent) as Map<String, dynamic>,
      );

      final audioFiles = manifestMap.keys
          .where((String key) => key.startsWith(assetPath))
          .where(
            (String key) =>
                key.endsWith('.mp3') ||
                key.endsWith('.wav') ||
                key.endsWith('.m4a') ||
                key.endsWith('.aac'),
          )
          .map((String key) => key.split('/').last.split('.').first)
          .toList();

      audioFiles.sort();
      return audioFiles;
    } catch (e, stackTrace) {
      logger.e(
        'Error loading audio files from $assetPath',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  static String getSpinAudioPath(String fileName) {
    // Remove "assets/" prefix since AudioPlayer adds it automatically
    return 'audio/spin_audio/$fileName.wav';
  }

  static String getSpinEndAudioPath(String fileName) {
    // Remove "assets/" prefix since AudioPlayer adds it automatically
    return 'audio/spin_end_audio/$fileName.wav';
  }

  static String? getDefaultSpinAudio(List<String> availableFiles) {
    return availableFiles.isNotEmpty ? availableFiles.first : null;
  }

  static String? getDefaultSpinEndAudio(List<String> availableFiles) {
    return availableFiles.isNotEmpty ? availableFiles.first : null;
  }

  // Preview audio functionality
  static Future<void> previewAudio(String fileName, bool isEndSound) async {
    try {
      await stopPreview();
      final audioPath = isEndSound
          ? getSpinEndAudioPath(fileName)
          : getSpinAudioPath(fileName);
      final audioSource = await SoLoud.instance.loadAsset('assets/$audioPath');
      _previewHandle = await SoLoud.instance.play(audioSource);
    } catch (e, stackTrace) {
      logger.e('Error playing preview audio', error: e, stackTrace: stackTrace);
      throw Exception('Failed to play audio preview');
    }
  }

  static Future<void> stopPreview() async {
    try {
      if (_previewHandle != null) {
        await SoLoud.instance.stop(_previewHandle!);
        _previewHandle = null;
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error stopping preview audio",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static String formatSoundName(String fileName) {
    // Convert filename to a more readable format
    return fileName
        .replaceAll('_', ' ')
        .replaceAll('.mp3', '')
        .replaceAll('.wav', '')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
