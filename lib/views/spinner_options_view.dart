import 'package:decision_spinner/consts/color_themes.dart';
import 'package:flutter/material.dart';
import '../storage/spinner_storage_service.dart';
import '../storage/spinner_wheel_model.dart';

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

  SpinnerModel get spinner => widget.spinner;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

      final success = await SpinnerStorageService.saveSpinner(spinner);

      if (mounted && !success) {
        throw Exception('Failed to save spinner');
      }

      if (mounted && success) {
        widget.onSpinnerChanged?.call(spinner);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Spinner saved successfully!')));

        Navigator.of(context).pop(spinner);
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
                    Navigator.of(context).pop(true);
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
                    _buildColorThemeSection(),
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

  Widget _buildColorThemeSection() {
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: DefaultColorThemes.all.asMap().entries.map((entry) {
              final index = entry.key;
              final colorTheme = entry.value;
              final isSelected = spinner.colorThemeIndex == index;

              return GestureDetector(
                onTap: () => _updateColorTheme(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.1,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: (colorTheme.colors.map((c) => [c]).toList())
                            .take(4)
                            .map((colors) {
                              return Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: colors.length > 1
                                      ? LinearGradient(colors: colors)
                                      : null,
                                  color: colors.length == 1 ? colors[0] : null,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        colorTheme.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsListSection() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list),
              const SizedBox(width: 8),
              Text(
                'Options (${spinner.options.length})',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: _isLoading ? null : () => _showAddOptionDialog(),
                icon: Icon(Icons.add, size: 20),
              ),
            ],
          ),
          if (spinner.options.isNotEmpty) ...[Divider(height: 24)],
          const SizedBox(height: 12),
          if (spinner.options.isEmpty)
            _buildEmptyState()
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spinner.options.length,
              onReorder: _reorderOptions,
              itemBuilder: (context, index) {
                return _buildOptionListItem(index, spinner.options[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOptionListItem(int index, SpinnerOption option) {
    final theme = Theme.of(context);
    final color = spinner.colors[index % spinner.colors.length];

    return Container(
      key: ValueKey(option.text + index.toString()),
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
        onTap: () => _showOptionDialog(index, option),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator and number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
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
                    Text(
                      option.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (option.weight != 1.0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Weight: ${option.weight.toStringAsFixed(1)}x',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${option.weight.toStringAsFixed(1)}x',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
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

  void _showOptionDialog(int index, SpinnerOption option) {
    final nameController = TextEditingController(text: option.text);
    double tempWeight = option.weight;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Text('Edit Option'),
              const Spacer(),
              if (spinner.options.length > 2)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmation(index);
                  },
                  icon: Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Delete option',
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
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Option text',
                    hintText: 'Enter option text...',
                    prefixIcon: Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  maxLength: 100,
                ),
                const SizedBox(height: 24),
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
                if (nameController.text.trim().isNotEmpty) {
                  _editOption(index, nameController.text);
                  _updateOptionWeight(index, tempWeight);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Option'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Option text',
            hintText: 'Enter new option...',
            prefixIcon: const Icon(Icons.lightbulb_outline),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              setState(() {
                spinner.options.add(
                  SpinnerOption(text: controller.text.trim(), weight: 1.0),
                );
                _hasChanges = true;
              });
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  spinner.options.add(
                    SpinnerOption(text: controller.text.trim(), weight: 1.0),
                  );
                  _hasChanges = true;
                });
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
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

  void _showEditNameDialog() {
    final controller = TextEditingController(text: spinner.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Spinner Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Spinner name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _editSpinnerName(controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Option'),
        content: Text(
          'Are you sure you want to delete "${spinner.options[index].text}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _removeOption(index);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class SpinnerOption {
  String text;
  double weight;

  SpinnerOption({required this.text, this.weight = 1.0});
}
