import 'package:flutter/material.dart';
import '../storage/roulette_storage_service.dart';
import '../storage/roulette_wheel_model.dart';
import '../enums/roulette_paint_mode.dart';

class RouletteManager extends StatefulWidget {
  final String? rouletteId; // Optional: if null, edits active roulette
  final Function(RouletteWheelModel)? onRouletteChanged;

  const RouletteManager({super.key, this.rouletteId, this.onRouletteChanged});

  @override
  RouletteManagerState createState() => RouletteManagerState();
}

class RouletteManagerState extends State<RouletteManager> {
  RouletteWheelModel? _roulette;
  late List<RouletteOption> _options;
  String _rouletteName = '';
  final TextEditingController _textController = TextEditingController();
  bool _hasChanges = false;
  bool _isLoading = false;
  int _selectedTheme = 0;
  RoulettePaintMode _paintMode = RoulettePaintMode.gradient;

  final List<ColorTheme> _colorThemes = [
    ColorTheme(
      name: 'Vibrant',
      gradientColors: [
        [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        [Color(0xFF667eea), Color(0xFF764ba2)],
        [Color(0xFFf093fb), Color(0xFFf5576c)],
        [Color(0xFF4facfe), Color(0xFF00f2fe)],
        [Color(0xFF43e97b), Color(0xFF38f9d7)],
        [Color(0xFFfa709a), Color(0xFFfee140)],
        [Color(0xFF30cfd0), Color(0xFF91a7ff)],
      ],
      solidColors: [
        Color(0xFFFF6B6B),
        Color(0xFF4ECDC4),
        Color(0xFF667eea),
        Color(0xFFf093fb),
        Color(0xFF4facfe),
        Color(0xFF43e97b),
        Color(0xFFfa709a),
        Color(0xFF30cfd0),
      ],
    ),
    ColorTheme(
      name: 'Ocean',
      gradientColors: [
        [Color(0xFF2E86AB), Color(0xFF72DBD9)],
        [Color(0xFF00B4DB), Color(0xFF0083B0)],
        [Color(0xFF1CB5E0), Color(0xFF000851)],
        [Color(0xFF4481EB), Color(0xFF04BEFE)],
        [Color(0xFF5B73C4), Color(0xFF9198E5)],
        [Color(0xFF2196F3), Color(0xFF21CBF3)],
        [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        [Color(0xFF00ACC1), Color(0xFF26C6DA)],
      ],
      solidColors: [
        Color(0xFF2E86AB),
        Color(0xFF00B4DB),
        Color(0xFF1CB5E0),
        Color(0xFF4481EB),
        Color(0xFF5B73C4),
        Color(0xFF2196F3),
        Color(0xFF4FC3F7),
        Color(0xFF00ACC1),
      ],
    ),
    ColorTheme(
      name: 'Sunset',
      gradientColors: [
        [Color(0xFFFF9A8B), Color(0xFFA890FE)],
        [Color(0xFFFFAD84), Color(0xFFFF6B6B)],
        [Color(0xFFFFA726), Color(0xFFFF7043)],
        [Color(0xFFFF8A65), Color(0xFFFF5722)],
        [Color(0xFFFFB74D), Color(0xFFFF9800)],
        [Color(0xFFFFCC02), Color(0xFFFF6F00)],
        [Color(0xFFFF5722), Color(0xFFE91E63)],
        [Color(0xFFF57F17), Color(0xFFFF6F00)],
      ],
      solidColors: [
        Color(0xFFFF9A8B),
        Color(0xFFFFAD84),
        Color(0xFFFFA726),
        Color(0xFFFF8A65),
        Color(0xFFFFB74D),
        Color(0xFFFFCC02),
        Color(0xFFFF5722),
        Color(0xFFF57F17),
      ],
    ),
    ColorTheme(
      name: 'Forest',
      gradientColors: [
        [Color(0xFF56AB2F), Color(0xFFA8E6CF)],
        [Color(0xFF11998E), Color(0xFF38EF7D)],
        [Color(0xFF00B09B), Color(0xFF96C93D)],
        [Color(0xFF2E8B57), Color(0xFF90EE90)],
        [Color(0xFF228B22), Color(0xFF32CD32)],
        [Color(0xFF006400), Color(0xFF7CFC00)],
        [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        [Color(0xFF388E3C), Color(0xFF66BB6A)],
      ],
      solidColors: [
        Color(0xFF56AB2F),
        Color(0xFF11998E),
        Color(0xFF00B09B),
        Color(0xFF2E8B57),
        Color(0xFF228B22),
        Color(0xFF006400),
        Color(0xFF4CAF50),
        Color(0xFF388E3C),
      ],
    ),
    ColorTheme(
      name: 'Purple',
      gradientColors: [
        [Color(0xFF667eea), Color(0xFF764ba2)],
        [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
        [Color(0xFF673AB7), Color(0xFF9575CD)],
        [Color(0xFF3F51B5), Color(0xFF7986CB)],
        [Color(0xFF5E35B1), Color(0xFF9575CD)],
        [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
        [Color(0xFF8E24AA), Color(0xFFCE93D8)],
        [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
      ],
      solidColors: [
        Color(0xFF667eea),
        Color(0xFF9C27B0),
        Color(0xFF673AB7),
        Color(0xFF3F51B5),
        Color(0xFF5E35B1),
        Color(0xFF7B1FA2),
        Color(0xFF8E24AA),
        Color(0xFF6A1B9A),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRouletteData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadRouletteData() async {
    setState(() => _isLoading = true);

    try {
      RouletteWheelModel? roulette;

      if (widget.rouletteId != null) {
        roulette = await RouletteStorageService.loadRouletteById(
          widget.rouletteId!,
        );
      } else {
        roulette = await RouletteStorageService.loadActiveRoulette();
      }

      if (roulette != null) {
        setState(() {
          _roulette = roulette;
          _rouletteName = roulette!.name;
          _options = List.from(roulette.options);
          _selectedTheme = roulette.colorThemeIndex;
          _paintMode = roulette.paintMode;
        });
      } else {
        // This shouldn't happen, but handle gracefully
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load roulette data'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_roulette == null) return;

    setState(() => _isLoading = true);

    try {
      // Check if name already exists (for other roulettes)
      if (_rouletteName != _roulette!.name) {
        final nameExists = await RouletteStorageService.rouletteNameExists(
          _rouletteName,
        );
        if (nameExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('A roulette with this name already exists'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      // Update the roulette model
      final updatedRoulette = RouletteWheelModel(
        id: _roulette!.id,
        name: _rouletteName,
        options: List.from(_options),
        colorThemeIndex: _selectedTheme,
        gradientColors: _colorThemes[_selectedTheme].gradientColors,
        solidColors: _colorThemes[_selectedTheme].solidColors,
        paintMode: _paintMode,
        createdAt: _roulette!.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await RouletteStorageService.saveRoulette(
        updatedRoulette,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _roulette = updatedRoulette;
            _hasChanges = false;
          });

          widget.onRouletteChanged?.call(updatedRoulette);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Roulette saved successfully!')),
          );

          Navigator.of(context).pop(updatedRoulette);
        } else {
          throw Exception('Failed to save roulette');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save roulette. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  void _editOption(int index, String newValue) {
    if (newValue.trim().isNotEmpty && newValue.trim() != _options[index].text) {
      setState(() {
        _options[index] = RouletteOption(
          text: newValue.trim(),
          weight: _options[index].weight,
        );
        _hasChanges = true;
      });
    }
  }

  void _updateOptionWeight(int index, double weight) {
    setState(() {
      _options[index] = RouletteOption(
        text: _options[index].text,
        weight: weight,
      );
      _hasChanges = true;
    });
  }

  void _reorderOptions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _options.removeAt(oldIndex);
      _options.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  void _editRouletteName(String newName) {
    if (newName.trim().isNotEmpty && newName.trim() != _rouletteName) {
      setState(() {
        _rouletteName = newName.trim();
        _hasChanges = true;
      });
    }
  }

  void _updateColorTheme(int themeIndex) {
    setState(() {
      _selectedTheme = themeIndex;
      _hasChanges = true;
    });
  }

  void _updatePaintMode(RoulettePaintMode mode) {
    setState(() {
      _paintMode = mode;
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
                    _buildPaintModeSection(),
                    const SizedBox(height: 16),
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
                _rouletteName,
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
          tooltip: 'Edit roulette name',
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

  Widget _buildPaintModeSection() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.brush_outlined),
              const SizedBox(width: 8),
              Text('Paint Style', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaintModeOption(
                  RoulettePaintMode.gradient,
                  'Gradient',
                  Icons.gradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaintModeOption(
                  RoulettePaintMode.solid,
                  'Solid',
                  Icons.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaintModeOption(
    RoulettePaintMode mode,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _paintMode == mode;

    return GestureDetector(
      onTap: () => _updatePaintMode(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
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
            children: _colorThemes.asMap().entries.map((entry) {
              final index = entry.key;
              final colorTheme = entry.value;
              final isSelected = _selectedTheme == index;

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
                        children:
                            (_paintMode == RoulettePaintMode.gradient
                                    ? colorTheme.gradientColors
                                    : colorTheme.solidColors
                                          .map((c) => [c])
                                          .toList())
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
                                      color: colors.length == 1
                                          ? colors[0]
                                          : null,
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
                'Options (${_options.length})',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: _isLoading ? null : () => _showAddOptionDialog(),
                icon: Icon(Icons.add, size: 20),
              ),
            ],
          ),
          if (_options.isNotEmpty) ...[Divider(height: 24)],
          const SizedBox(height: 12),
          if (_options.isEmpty)
            _buildEmptyState()
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _options.length,
              onReorder: _reorderOptions,
              itemBuilder: (context, index) {
                return _buildOptionListItem(index, _options[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOptionListItem(int index, RouletteOption option) {
    final theme = Theme.of(context);
    final colorTheme = _colorThemes[_selectedTheme];
    final colors = _paintMode == RoulettePaintMode.gradient
        ? colorTheme.gradientColors[index % colorTheme.gradientColors.length]
        : [colorTheme.solidColors[index % colorTheme.solidColors.length]];

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
                  gradient: colors.length > 1
                      ? LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: colors.length == 1 ? colors[0] : null,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.3),
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

              const SizedBox(width: 8),

              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionDialog(int index, RouletteOption option) {
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
              if (_options.length > 2)
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

                // Weight section
                // Text('Weight', style: Theme.of(context).textTheme.titleSmall),
                // const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Icon(
                //       Icons.tune,
                //       size: 18,
                //       color: Theme.of(context).colorScheme.onSurfaceVariant,
                //     ),
                //     const SizedBox(width: 8),
                //     Expanded(
                //       child: Slider(
                //         value: tempWeight,
                //         min: 1.0,
                //         max: 10.0,
                //         divisions: 9,
                //         label: tempWeight.toStringAsFixed(1),
                //         onChanged: (value) {
                //           setDialogState(() {
                //             tempWeight = value;
                //           });
                //         },
                //       ),
                //     ),
                //     Container(
                //       width: 50,
                //       child: Text(
                //         '${tempWeight.toStringAsFixed(1)}x',
                //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //           fontWeight: FontWeight.bold,
                //         ),
                //         textAlign: TextAlign.end,
                //       ),
                //     ),
                //   ],
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
                _options.add(
                  RouletteOption(text: controller.text.trim(), weight: 1.0),
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
                  _options.add(
                    RouletteOption(text: controller.text.trim(), weight: 1.0),
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
    final controller = TextEditingController(text: _rouletteName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Roulette Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Roulette name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _editRouletteName(controller.text);
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
          'Are you sure you want to delete "${_options[index].text}"?',
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

class RouletteOption {
  String text;
  double weight;

  RouletteOption({required this.text, this.weight = 1.0});
}

class ColorTheme {
  final String name;
  final List<List<Color>> gradientColors;
  final List<Color> solidColors;

  ColorTheme({
    required this.name,
    required this.gradientColors,
    required this.solidColors,
  });
}
