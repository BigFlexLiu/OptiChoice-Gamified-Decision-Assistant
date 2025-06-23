import 'package:decision_spinner/consts/color_themes.dart';
import 'package:decision_spinner/utils/audio_utils.dart';
import 'package:decision_spinner/views/custom_color_picker_view.dart';
import 'package:decision_spinner/widgets/default_divider.dart';
import 'package:decision_spinner/widgets/edit_name_dialogue.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A spinner with this name already exists'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Spinner saved successfully!')));

        Navigator.of(context).pop(originalSpinner);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save spinner. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _reorderOptions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = spinner.options.removeAt(oldIndex);
      spinner.options.insert(newIndex, item);
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
      spinner.colors = DefaultColorThemes.getByIndex(themeIndex)!.colors;
      _hasChanges = true;
    });
  }

  void _updateCustomColors(List<Color> customColors) {
    setState(() {
      spinner.colorThemeIndex = -1; // Use -1 to indicate custom theme
      spinner.colors = customColors;
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
              content: Text(
                'You have unsaved changes. Do you want to save them?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Discard'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _saveChanges();
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
                      currentColors: spinner.colors,
                      onThemeChanged: _updateColorTheme,
                      onCustomColorsChanged: _updateCustomColors,
                    ),
                    const SizedBox(height: 16),
                    AudioSettingsSection(
                      spinSound: spinner.spinSound,
                      spinEndSound: spinner.spinEndSound,
                      availableSpinSounds: _spinAudioFiles,
                      availableSpinEndSounds: _spinEndAudioFiles,
                      onSpinSoundChanged: _updateSpinSound,
                      onSpinEndSoundChanged: _updateSpinEndSound,
                    ),
                    const SizedBox(height: 16),
                    SpinDurationSection(
                      spinDuration: spinner.spinDuration,
                      onDurationChanged: _updateSpinDuration,
                    ),
                    const SizedBox(height: 16),
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list),
              const SizedBox(width: 8),
              Text('Options ($numOptions)', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          if (spinner.options.isEmpty)
            _buildEmptyState()
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: numOptions,
              onReorder: _reorderOptions,
              itemBuilder: (context, index) {
                return OptionListItem(
                  key: ValueKey(spinner.options[index].text + index.toString()),
                  index: index,
                  option: spinner.options[index],
                  color: spinner.colors[index % spinner.colors.length],
                  onTap: () => _showOptionDialog(index, spinner.options[index]),
                );
              },
            ),
          AddOptionItemWidget(
            index: numOptions,
            color: spinner.colors[numOptions % spinner.colors.length],
            onTap: () => _showAddOptionDialog(),
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
}

class ColorThemeSelector extends StatelessWidget {
  final int selectedThemeIndex;
  final List<Color> currentColors;
  final Function(int) onThemeChanged;
  final Function(List<Color>) onCustomColorsChanged;

  const ColorThemeSelector({
    super.key,
    required this.selectedThemeIndex,
    required this.currentColors,
    required this.onThemeChanged,
    required this.onCustomColorsChanged,
  });

  void _showCustomColorPicker(BuildContext context) {
    // Use current colors if it's a custom theme, otherwise use default colors
    List<Color> initialColors = selectedThemeIndex == -1
        ? currentColors
        : DefaultColorThemes.getByIndex(0)?.colors ?? [];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomColorPickerView(
          initialColors: initialColors,
          onColorsChanged: (colors) {
            onCustomColorsChanged(colors);
          },
        ),
      ),
    );
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
              Icon(Icons.palette_outlined),
              const SizedBox(width: 8),
              Text('Color Theme', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              // Existing predefined themes
              ...DefaultColorThemes.all.asMap().entries.map((entry) {
                final index = entry.key;
                final colorTheme = entry.value;
                final isSelected = selectedThemeIndex == index;

                return GestureDetector(
                  onTap: () => onThemeChanged(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: colorTheme.colors.take(4).map((color) {
                            return Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                        Text(colorTheme.name, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              }),

              // Custom theme option
              GestureDetector(
                onTap: () => _showCustomColorPicker(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: selectedThemeIndex == -1
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            selectedThemeIndex == -1 && currentColors.isNotEmpty
                            ? currentColors.take(4).map((color) {
                                return Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList()
                            : [
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.red, Colors.blue],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green, Colors.yellow],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.purple, Colors.orange],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.pink, Colors.cyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                      ),
                      const SizedBox(height: 4),
                      Text('Custom', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OptionListItem extends StatelessWidget {
  final int index;
  final SpinnerOption option;
  final Color color;
  final VoidCallback onTap;

  const OptionListItem({
    super.key,
    required this.index,
    required this.option,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
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
                    Text(option.text, style: theme.textTheme.bodyLarge),
                  ],
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
  final Color color;
  final VoidCallback onTap;

  const AddOptionItemWidget({
    super.key,
    required this.index,
    required this.color,
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // "Add new option" label and icon
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

class EditOptionDialog extends StatefulWidget {
  final SpinnerOption option;
  final bool canDelete;
  final Function(String, double) onOptionChanged;
  final VoidCallback onDeleteRequested;

  const EditOptionDialog({
    super.key,
    required this.option,
    required this.canDelete,
    required this.onOptionChanged,
    required this.onDeleteRequested,
  });

  @override
  State<EditOptionDialog> createState() => _EditOptionDialogState();
}

class _EditOptionDialogState extends State<EditOptionDialog> {
  late final TextEditingController _nameController;
  late double _tempWeight;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.option.text);
    _tempWeight = widget.option.weight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Edit Option'),
          const Spacer(),
          if (widget.canDelete)
            IconButton(
              tooltip: 'Delete option',
              icon: Icon(Icons.delete_outline),
              onPressed: widget.onDeleteRequested,
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Option text',
                hintText: 'Enter option text...',
                prefixIcon: const Icon(Icons.lightbulb_outline),
              ),
              maxLength: 100,
            ),
            // const SizedBox(height: 24),
            // Weight slider
            // Text('Weight: ${_tempWeight.toStringAsFixed(1)}'),
            // Slider(
            //   value: _tempWeight,
            //   min: 0.1,
            //   max: 5.0,
            //   divisions: 49,
            //   onChanged: (value) {
            //     setState(() {
            //       _tempWeight = value;
            //     });
            //   },
            // ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onOptionChanged(_nameController.text, _tempWeight);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class AddOptionDialog extends StatefulWidget {
  final Function(String) onOptionAdded;

  const AddOptionDialog({super.key, required this.onOptionAdded});

  @override
  State<AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<AddOptionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onOptionAdded(_controller.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Option'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Option text',
          hintText: 'Enter new option...',
          prefixIcon: const Icon(Icons.lightbulb_outline),
        ),
        autofocus: true,
        onSubmitted: (_) => _addOption(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addOption, child: Text('Add')),
      ],
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirmed;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmed();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text('Delete'),
        ),
      ],
    );
  }
}

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
              Icon(Icons.volume_up_outlined),
              const SizedBox(width: 8),
              Text('Audio Settings', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          _buildAudioSelector(
            context: context,
            label: 'Spin Sound',
            icon: Icons.play_circle_outline,
            currentSound: _validSpinSound,
            availableSounds: widget.availableSpinSounds,
            onSoundChanged: widget.onSpinSoundChanged,
            isPlaying: _isPlayingSpinPreview,
            onPreview: (sound) => _previewAudio(sound, false),
          ),
          const SizedBox(height: 16),
          _buildAudioSelector(
            context: context,
            label: 'Spin End Sound',
            icon: Icons.stop_circle_outlined,
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
    required String label,
    required IconData icon,
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
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                        return DropdownMenuItem<String?>(
                          value: sound,
                          child: Text(
                            AudioUtils.formatSoundName(sound),
                            style: theme.textTheme.bodyMedium,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
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

class SpinDurationSection extends StatelessWidget {
  final Duration spinDuration;
  final Function(Duration) onDurationChanged;

  const SpinDurationSection({
    super.key,
    required this.spinDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = spinDuration.inMilliseconds / 1000.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined),
              const SizedBox(width: 8),
              Text('Spin Duration', style: theme.textTheme.titleSmall),
            ],
          ),
          DefaultDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.speed, size: 16),
              const SizedBox(width: 8),
              Text(
                '${seconds.toStringAsFixed(1)} seconds',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Slider(
                  value: seconds,
                  min: 0.5,
                  max: 5.0,
                  divisions: 45, // 0.1 second increments
                  label: '${seconds.toStringAsFixed(1)}s',
                  onChanged: (value) {
                    final duration = Duration(
                      milliseconds: (value * 1000).round(),
                    );
                    onDurationChanged(duration);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.0s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Fast',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      'Slow',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '5.0s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDurationDescription(seconds),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationDescription(double seconds) {
    if (seconds <= 1.5) {
      return 'Quick spin - great for fast decisions';
    } else if (seconds <= 2.5) {
      return 'Balanced spin - good for most situations';
    } else if (seconds <= 3.5) {
      return 'Moderate spin - builds anticipation';
    } else {
      return 'Long spin - maximum suspense';
    }
  }
}
