import 'package:decision_spinner/consts/color_themes.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/utils/widget_utils.dart';
import 'package:decision_spinner/widgets/default_divider.dart';
import 'package:decision_spinner/widgets/edit_name_dialogue.dart';
import 'package:decision_spinner/widgets/dialogs/add_option_dialog.dart';
import 'package:decision_spinner/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:decision_spinner/widgets/dialogs/edit_option_dialog.dart';
import 'package:decision_spinner/widgets/settings/audio_settings_section.dart';
import 'package:decision_spinner/widgets/settings/color_theme_selector.dart';
import 'package:decision_spinner/widgets/settings/spin_duration_section.dart';
import 'package:flutter/material.dart';
import '../storage/spinner_storage_service.dart';
import '../storage/spinner_model.dart';

class SpinnerOptionsView extends StatefulWidget {
  final SpinnerModel spinner;
  final Function(SpinnerModel)? onSpinnerChanged;

  const SpinnerOptionsView({
    super.key,
    required this.spinner,
    this.onSpinnerChanged,
  });

  @override
  SpinnerOptionsViewState createState() => SpinnerOptionsViewState();
}

class SpinnerOptionsViewState extends State<SpinnerOptionsView> {
  final TextEditingController _textController = TextEditingController();
  bool _hasChanges = false;
  bool _isLoading = false;
  List<String> _spinAudioFiles = [];
  List<String> _spinEndAudioFiles = [];

  late SpinnerModel spinner;
  SpinnerModel get originalSpinner => widget.spinner;

  @override
  void initState() {
    super.initState();
    spinner = SpinnerModel.duplicate(
      originalSpinner,
      newId: originalSpinner.id,
      newName: originalSpinner.name,
    );
    _loadAudioFiles();
  }

  @override
  void dispose() {
    _textController.dispose();
    AudioUtils.stopPreview();
    super.dispose();
  }

  Future<void> _loadAudioFiles() async {
    final spinAudio = await AudioUtils.getSpinAudioFiles();
    final spinEndAudio = await AudioUtils.getSpinEndAudioFiles();

    setState(() {
      _spinAudioFiles = spinAudio;
      _spinEndAudioFiles = spinEndAudio;

      // Set default audio if none selected
      if (spinner.spinSound == null && _spinAudioFiles.isNotEmpty) {
        spinner.spinSound = _spinAudioFiles.first;
        _hasChanges = true;
      }
      if (spinner.spinEndSound == null && _spinEndAudioFiles.isNotEmpty) {
        spinner.spinEndSound = _spinEndAudioFiles.first;
        _hasChanges = true;
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final nameExists = await SpinnerStorageService.spinnerNameExists(
        spinner.name,
        id: spinner.id,
      );

      if (nameExists) {
        if (mounted) {
          showErrorSnackBar(context, 'A spinner with this name already exists');
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      originalSpinner.copy(spinner);

      final success = await SpinnerStorageService.saveSpinner(originalSpinner);

      if (mounted && !success) {
        throw Exception('Failed to save spinner');
      }

      if (mounted && success) {
        widget.onSpinnerChanged?.call(originalSpinner);

        showSnackBar(context, 'Spinner saved successfully!');

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to save spinner. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasChanges) {
          final dialogResult = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Unsaved Changes'),
              content: Text('Do you want to save them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Discard'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _saveChanges();
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          );

          if (dialogResult == false && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ColorThemeSelector(
                      selectedThemeIndex: spinner.colorThemeIndex,
                      customColors: spinner.customBackgroundColors,
                      onThemeChanged: _updateColorTheme,
                      onCustomColorsChanged: _updateCustomColors,
                    ),
                    const SizedBox(height: 8),
                    AudioSettingsSection(
                      spinSound: spinner.spinSound,
                      spinEndSound: spinner.spinEndSound,
                      availableSpinSounds: _spinAudioFiles,
                      availableSpinEndSounds: _spinEndAudioFiles,
                      onSpinSoundChanged: _updateSpinSound,
                      onSpinEndSoundChanged: _updateSpinEndSound,
                    ),
                    const SizedBox(height: 8),
                    SpinDurationSection(
                      spinDuration: spinner.spinDuration,
                      onDurationChanged: _updateSpinDuration,
                    ),
                    const SizedBox(height: 8),
                    _buildOptionsListSection(),
                  ],
                ),
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: GestureDetector(
        onTap: _isLoading ? null : () => _showEditNameDialog(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                spinner.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit_outlined),
          onPressed: _isLoading ? null : () => _showEditNameDialog(),
          tooltip: 'Edit spinner name',
        ),
        if (_hasChanges)
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: Text(
              'Save',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsListSection() {
    final theme = Theme.of(context);
    final numOptions = spinner.options.length;

    // Separate active and inactive options while preserving original indices
    final activeOptionsWithIndex = <MapEntry<int, SpinnerOption>>[];
    final inactiveOptionsWithIndex = <MapEntry<int, SpinnerOption>>[];

    for (int i = 0; i < spinner.options.length; i++) {
      if (spinner.options[i].isActive) {
        activeOptionsWithIndex.add(MapEntry(i, spinner.options[i]));
      } else {
        inactiveOptionsWithIndex.add(MapEntry(i, spinner.options[i]));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list,
                color: theme.textTheme.bodyMedium?.color?.withAlpha(128),
              ),
              const SizedBox(width: 8),
              Text('$numOptions', style: theme.textTheme.titleSmall),
              Text(
                ' Options',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).hintColor.withAlpha(128),
                ),
              ),
              if (inactiveOptionsWithIndex.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${activeOptionsWithIndex.length} active, ${inactiveOptionsWithIndex.length} inactive)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          if (spinner.options.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: [
                // Active options section
                if (activeOptionsWithIndex.isNotEmpty) ...[
                  if (inactiveOptionsWithIndex.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Active',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...activeOptionsWithIndex.asMap().entries.map((entry) {
                    final displayIndex = entry.key;
                    final originalIndex = entry.value.key;
                    final option = entry.value.value;
                    final activeCount = spinner.activeOptionsCount;

                    return OptionListItem(
                      key: ValueKey('active_${option.text}_$originalIndex'),
                      index: originalIndex,
                      displayIndex: displayIndex + 1,
                      option: option,
                      backgroundColor: _getActiveOptionBackgroundColor(
                        displayIndex,
                      ),
                      foregroundColor: _getActiveOptionForegroundColor(
                        displayIndex,
                      ),
                      onTap: () => _showOptionDialog(originalIndex, option),
                      onActiveToggled: activeCount > 2
                          ? () => _toggleOptionActive(originalIndex)
                          : null,
                    );
                  }),
                ],
                AddOptionItemWidget(
                  index: numOptions,
                  onTap: () => _showAddOptionDialog(),
                ),

                // Inactive options section
                if (inactiveOptionsWithIndex.isNotEmpty) ...[
                  if (activeOptionsWithIndex.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Inactive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...inactiveOptionsWithIndex.asMap().entries.map((entry) {
                    final displayIndex = entry.key;
                    final originalIndex = entry.value.key;
                    final option = entry.value.value;

                    return OptionListItem(
                      key: ValueKey('inactive_${option.text}_$originalIndex'),
                      index: originalIndex,
                      displayIndex:
                          activeOptionsWithIndex.length + displayIndex + 1,
                      option: option,
                      backgroundColor: _getInactiveOptionBackgroundColor(),
                      foregroundColor: _getInactiveOptionForegroundColor(),
                      onTap: () => _showOptionDialog(originalIndex, option),
                      onActiveToggled: () => _toggleOptionActive(originalIndex),
                    );
                  }),

                  // Button to activate all inactive options
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          spinner.setAllOptionsActive();
                          _hasChanges = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Activate all inactive options",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.visibility,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No options yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some options to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSpinSound(String? soundName) {
    setState(() {
      spinner.spinSound = soundName;
      _hasChanges = true;
    });
  }

  void _updateSpinEndSound(String? soundName) {
    setState(() {
      spinner.spinEndSound = soundName;
      _hasChanges = true;
    });
  }

  void _updateSpinDuration(Duration duration) {
    setState(() {
      spinner.spinDuration = duration;
      _hasChanges = true;
    });
  }

  void _removeOption(int index) {
    if (spinner.options.length > 2) {
      setState(() {
        spinner.options.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  void _editOption(int index, String newValue) {
    if (newValue.trim().isNotEmpty &&
        newValue.trim() != spinner.options[index].text) {
      setState(() {
        spinner.options[index].text = newValue;
        _hasChanges = true;
      });
    }
  }

  void _updateOptionWeight(int index, double weight) {
    setState(() {
      spinner.options[index].weight = weight;
      _hasChanges = true;
    });
  }

  void _editSpinnerName(String newName) {
    if (newName.trim().isNotEmpty && newName.trim() != spinner.name) {
      setState(() {
        spinner.name = newName.trim();
        _hasChanges = true;
      });
    }
  }

  void _updateColorTheme(int themeIndex) {
    setState(() {
      spinner.colorThemeIndex = themeIndex;
      spinner.backgroundColors = DefaultColorThemes.getByIndex(
        themeIndex,
      )!.colors;
      _hasChanges = true;
    });
  }

  void _updateCustomColors(List<Color> customColors) {
    setState(() {
      spinner.colorThemeIndex = -1;
      spinner.customBackgroundColors = customColors;
      spinner.backgroundColors = customColors;
      _hasChanges = true;
    });
  }

  void _addOption(String text) {
    setState(() {
      spinner.options.add(SpinnerOption(text: text.trim()));
      _hasChanges = true;
    });
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => EditNameDialog(
        initialName: spinner.name,
        onNameChanged: _editSpinnerName,
      ),
    );
  }

  void _showOptionDialog(int index, SpinnerOption option) {
    showDialog(
      context: context,
      builder: (context) => EditOptionDialog(
        option: option,
        canDelete: spinner.options.length > 2,
        onOptionChanged: (newText, newWeight) {
          _editOption(index, newText);
          _updateOptionWeight(index, newWeight);
        },
        onDeleteRequested: () {
          Navigator.of(context).pop();
          _showDeleteConfirmation(index);
        },
      ),
    );
  }

  void _showAddOptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddOptionDialog(onOptionAdded: _addOption),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Option',
        message:
            'Are you sure you want to delete "${spinner.options[index].text}"?',
        onConfirmed: () => _removeOption(index),
      ),
    );
  }

  void _toggleOptionActive(int index) {
    setState(() {
      spinner.options[index].isActive = !spinner.options[index].isActive;
      _hasChanges = true;
    });
  }

  // Helper methods for color assignment
  Color _getActiveOptionBackgroundColor(int activeIndex) {
    return spinner.backgroundColors[activeIndex %
        spinner.backgroundColors.length];
  }

  Color _getActiveOptionForegroundColor(int activeIndex) {
    return spinner.foregroundColors[activeIndex %
        spinner.foregroundColors.length];
  }

  Color _getInactiveOptionBackgroundColor() {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceContainerHighest;
  }

  Color _getInactiveOptionForegroundColor() {
    final theme = Theme.of(context);
    return theme.colorScheme.onSurfaceVariant;
  }
}

class OptionListItem extends StatelessWidget {
  final int index;
  final int? displayIndex;
  final SpinnerOption option;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final VoidCallback? onActiveToggled;

  const OptionListItem({
    super.key,
    required this.index,
    this.displayIndex,
    required this.option,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.onActiveToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: option.isActive
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isActive
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(
              alpha: option.isActive ? 0.05 : 0.02,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator and number
              Container(
                width: 32,
                height: 32,
                decoration: colorSampleDecoration(
                  context,
                  backgroundColor,
                  alpha: option.isActive ? 64 : 32,
                ),
                child: Center(
                  child: Text(
                    '${displayIndex ?? (index + 1)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: option.isActive
                          ? foregroundColor
                          : foregroundColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Option text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: option.isActive
                            ? null
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        decoration: option.isActive
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),

              // Active/Inactive toggle button
              if (onActiveToggled != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: onActiveToggled,
                    icon: Icon(
                      option.isActive ? Icons.visibility : Icons.visibility_off,
                      color: option.isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    tooltip: option.isActive
                        ? 'Disable option'
                        : 'Enable option',
                    visualDensity: VisualDensity.compact,
                  ),
                ),

              // Weight badge (if different from 1.0)
              if (option.weight != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${option.weight}x',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOptionItemWidget extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const AddOptionItemWidget({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          style: BorderStyle
              .solid, // Use BorderStyle.none if using only box shadow
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator and index bubble (same as OptionListItem)
              Container(
                width: 32,
                height: 32,
                decoration: colorSampleDecoration(context, Colors.white),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Add new option",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.add, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
