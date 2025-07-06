import 'package:decision_spinner/consts/color_themes.dart';
import 'package:decision_spinner/utils/color_utils.dart';
import 'package:flutter/material.dart';

class CustomColorPickerView extends StatefulWidget {
  final List<Color> initialColors;
  final Function(List<Color>) onColorsChanged;

  const CustomColorPickerView({
    super.key,
    required this.initialColors,
    required this.onColorsChanged,
  });

  @override
  State<CustomColorPickerView> createState() => _CustomColorPickerViewState();
}

class _CustomColorPickerViewState extends State<CustomColorPickerView> {
  late List<Color> _selectedColors;
  final int _minColors = 2;
  final int _maxColors = 12;

  late List<Color> _initialColors;

  @override
  void initState() {
    super.initState();
    _selectedColors = List.from(widget.initialColors);
    _initialColors = List.from(widget.initialColors);
  }

  bool _hasChanges() {
    // Use value-based comparison for color lists
    return !_selectedColors.hasSameColorsInOrder(_initialColors);
  }

  void _toggleColor(Color color) {
    setState(() {
      if (_selectedColors.containsColorValue(color)) {
        _selectedColors.removeColorValue(color);
      } else {
        _selectedColors.add(color);
      }
    });
  }

  void _saveColors() {
    widget.onColorsChanged(_selectedColors);
    Navigator.of(context).pop();
  }

  Future<void> _showDiscardChangesDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                _saveColors();
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasChanges(),
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _hasChanges()) {
          await _showDiscardChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Custom Colors'),
          backgroundColor: theme.colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges()) {
                await _showDiscardChangesDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (_hasChanges())
              TextButton(
                onPressed: _saveColors,
                child: Text(
                  'Save',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Selected colors count indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedColors.length} of $_maxColors colors selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Color selection grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: DefaultColorThemes.customColors.length,
                  itemBuilder: (context, index) {
                    final color = DefaultColorThemes.customColors[index];
                    final isSelected = _selectedColors.containsColorValue(
                      color,
                    );
                    final canDeselect = _selectedColors.length > _minColors;
                    final canSelect = _selectedColors.length < _maxColors;
                    final isEnabled = isSelected ? canDeselect : canSelect;
                    final colorOrder = isSelected
                        ? _selectedColors.indexOfColorValue(color) + 1
                        : null;

                    return GestureDetector(
                      onTap: isEnabled ? () => _toggleColor(color) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isSelected && colorOrder != null)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  colorOrder.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            if (!isEnabled)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
