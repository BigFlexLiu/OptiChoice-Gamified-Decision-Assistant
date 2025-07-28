import 'package:flutter/material.dart';
import '../../utils/audio_utils.dart';
import '../../utils/widget_utils.dart';
import '../default_divider.dart';

class AudioSettingsSection extends StatefulWidget {
  final String? spinSound;
  final String? spinEndSound;
  final List<String> availableSpinSounds;
  final List<String> availableSpinEndSounds;
  final Function(String?) onSpinSoundChanged;
  final Function(String?) onSpinEndSoundChanged;

  const AudioSettingsSection({
    super.key,
    required this.spinSound,
    required this.spinEndSound,
    required this.availableSpinSounds,
    required this.availableSpinEndSounds,
    required this.onSpinSoundChanged,
    required this.onSpinEndSoundChanged,
  });

  @override
  State<AudioSettingsSection> createState() => _AudioSettingsSectionState();
}

class _AudioSettingsSectionState extends State<AudioSettingsSection> {
  bool _isPlayingSpinPreview = false;
  bool _isPlayingEndPreview = false;

  @override
  void dispose() {
    AudioUtils.stopPreview();
    super.dispose();
  }

  // Helper method to get the current valid spin sound
  String? get _validSpinSound {
    if (widget.spinSound == null) return null;
    return widget.availableSpinSounds.contains(widget.spinSound)
        ? widget.spinSound
        : null;
  }

  // Helper method to get the current valid spin end sound
  String? get _validSpinEndSound {
    if (widget.spinEndSound == null) return null;
    return widget.availableSpinEndSounds.contains(widget.spinEndSound)
        ? widget.spinEndSound
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up_outlined,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(128),
              ),
              const SizedBox(width: 8),
              Text('Audio Settings', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          _buildAudioSelector(
            context: context,
            currentSound: _validSpinSound,
            availableSounds: widget.availableSpinSounds,
            onSoundChanged: widget.onSpinSoundChanged,
            isPlaying: _isPlayingSpinPreview,
            onPreview: (sound) => _previewAudio(sound, false),
          ),
          const SizedBox(height: 16),
          _buildAudioSelector(
            context: context,
            currentSound: _validSpinEndSound,
            availableSounds: widget.availableSpinEndSounds,
            onSoundChanged: widget.onSpinEndSoundChanged,
            isPlaying: _isPlayingEndPreview,
            onPreview: (sound) => _previewAudio(sound, true),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSelector({
    required BuildContext context,
    required String? currentSound,
    required List<String> availableSounds,
    required Function(String?) onSoundChanged,
    required bool isPlaying,
    required Function(String) onPreview,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: currentSound,
                    hint: Text(
                      availableSounds.isEmpty ? 'Loading...' : 'Select sound',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'None',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...availableSounds.map((sound) {
                        final isSelected =
                            sound ==
                            currentSound; // compare with your selected value
                        return DropdownMenuItem<String?>(
                          value: sound,
                          child: Text(
                            AudioUtils.formatSoundName(sound),
                            style: isSelected
                                ? theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )
                                : theme.textTheme.bodyMedium,
                          ),
                        );
                      }),
                    ],
                    onChanged: availableSounds.isEmpty ? null : onSoundChanged,
                  ),
                ),
              ),
              if (currentSound != null && availableSounds.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isPlaying ? null : () => onPreview(currentSound),
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    color: isPlaying
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: isPlaying ? 'Stop preview' : 'Preview sound',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _previewAudio(String soundName, bool isEndSound) async {
    // Stop any currently playing preview
    await AudioUtils.stopPreview();

    // Set the appropriate playing state
    setState(() {
      if (isEndSound) {
        _isPlayingEndPreview = true;
        _isPlayingSpinPreview = false;
      } else {
        _isPlayingSpinPreview = true;
        _isPlayingEndPreview = false;
      }
    });

    try {
      await AudioUtils.previewAudio(soundName, isEndSound);
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error playing audio: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingSpinPreview = false;
          _isPlayingEndPreview = false;
        });
      }
    }
  }
}
