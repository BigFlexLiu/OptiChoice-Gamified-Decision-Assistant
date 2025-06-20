import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioUtils {
  static const String spinAudioPath = 'assets/audio/spin_audio';
  static const String spinEndAudioPath = 'assets/audio/spin_end_audio';

  // Static audio player for previews
  static final AudioPlayer _previewPlayer = AudioPlayer();

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
    } catch (e) {
      print('Error loading audio files from $assetPath: $e');
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
      // Stop any currently playing preview
      await _previewPlayer.stop();

      // Determine the correct path (without "assets/" prefix)
      String audioPath = isEndSound
          ? getSpinEndAudioPath(fileName)
          : getSpinAudioPath(fileName);

      // Play the audio using AssetSource (which automatically adds "assets/")
      await _previewPlayer.play(AssetSource(audioPath));
    } catch (e) {
      print('Error playing preview audio: $e');
      throw Exception('Failed to play audio preview');
    }
  }

  static Future<void> stopPreview() async {
    try {
      await _previewPlayer.stop();
    } catch (e) {
      print('Error stopping preview audio: $e');
    }
  }

  static void dispose() {
    _previewPlayer.dispose();
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
