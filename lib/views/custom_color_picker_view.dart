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
  late Set<Color> _selectedColors;
  final int _minColors = 2;
  final int _maxColors = 12;
  bool _isReordering = false;
  final Map<Color, int> _colorOrder = {};

  // Predefined color palette for selection
  final List<Color> _colors = [
    Colors.red,
    Colors.redAccent,
    Colors.pink,
    Colors.pinkAccent,
    Colors.purple,
    Colors.purpleAccent,
    Colors.deepPurple,
    Colors.deepPurpleAccent,
    Colors.indigo,
    Colors.indigoAccent,
    Colors.blue,
    Colors.blueAccent,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.teal,
    Colors.tealAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.lightGreen,
    Colors.lightGreenAccent,
    Colors.lime,
    Colors.limeAccent,
    Colors.yellow,
    Colors.yellowAccent,
    Colors.amber,
    Colors.amberAccent,
    Colors.orange,
    Colors.orangeAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ].map((color) => Color(color.toARGB32())).toList();

  @override
  void initState() {
    super.initState();
    _selectedColors = Set.from(widget.initialColors);

    // Initialize order for existing colors
    for (int i = 0; i < widget.initialColors.length; i++) {
      _colorOrder[widget.initialColors[i]] = i + 1;
    }
  }

  void _toggleColor(Color color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
        _colorOrder.remove(color);
        // Reassign orders to maintain sequence
        _reassignOrders();
      } else {
        _selectedColors.add(color);
        // Assign the next available order immediately
        _colorOrder[color] = _selectedColors.length;
      }
    });
  }

  void _reassignOrders() {
    // Get all colors that still have orders and sort them by their current order
    List<Color> orderedColors = _colorOrder.keys
        .where((color) => _selectedColors.contains(color))
        .toList();
    orderedColors.sort((a, b) => _colorOrder[a]!.compareTo(_colorOrder[b]!));

    // Reassign sequential orders starting from 1
    for (int i = 0; i < orderedColors.length; i++) {
      _colorOrder[orderedColors[i]] = i + 1;
    }
  }

  void _toggleAndSaveReordering() {
    final wasReordering = _isReordering;
    setState(() {
      _isReordering = !_isReordering;
    });

    if (wasReordering) {
      _applyNewOrder();
    }
  }

  void _toggleColorOrder(Color color) {
    setState(() {
      if (_colorOrder.containsKey(color)) {
        // Remove order
        _colorOrder.remove(color);
      } else {
        // Assign the earliest missing order
        int nextOrder = _getNextAvailableOrder();
        _colorOrder[color] = nextOrder;
      }
    });
  }

  int _getNextAvailableOrder() {
    final used = Set.of(_colorOrder.values);
    for (var i = 1; i <= _selectedColors.length; i++) {
      if (!used.contains(i)) return i;
    }
    return _selectedColors.length + 1;
  }

  List<Color> _applyNewOrder() {
    // Partition into ordered and unordered
    final orderedColors = <Color>[];
    final unorderedColors = <Color>[];

    for (final color in _selectedColors) {
      (_colorOrder.containsKey(color) ? orderedColors : unorderedColors).add(
        color,
      );
    }

    // Sort ordered by assigned order
    orderedColors.sort((a, b) => _colorOrder[a]!.compareTo(_colorOrder[b]!));

    // Reassign sequential orders
    for (var i = 0; i < orderedColors.length; i++) {
      _colorOrder[orderedColors[i]] = i + 1;
    }

    // Assign new orders to unordered
    final startOrder = orderedColors.length + 1;
    for (var i = 0; i < unorderedColors.length; i++) {
      _colorOrder[unorderedColors[i]] = startOrder + i;
    }

    return [...orderedColors, ...unorderedColors];
  }

  void _saveColors() {
    print("save");
    if (_isReordering) {
      final reorderedColors = _applyNewOrder();
      widget.onColorsChanged(reorderedColors);
    } else {
      // Initialize a list with null placeholders based on color order size
      final List<Color?> orderedColors = List.filled(_colorOrder.length, null);

      // Place each color in its designated position
      for (var entry in _colorOrder.entries) {
        final color = entry.key;
        final position = entry.value;
        orderedColors[position - 1] = color;
      }

      // Cast the list to non-nullable Color list and pass to callback
      widget.onColorsChanged(
        orderedColors.map((color) => color as Color).toList(),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Colors'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
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

            // Selected colors count indicator and reorder button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedColors.length} of $_maxColors colors selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_selectedColors.length > 1)
                  ElevatedButton.icon(
                    onPressed: _toggleAndSaveReordering,
                    icon: Icon(_isReordering ? Icons.check : Icons.reorder),
                    label: Text(_isReordering ? 'Done' : 'Reorder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isReordering
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                      foregroundColor: _isReordering
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSecondary,
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
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColors.contains(color);
                  final canDeselect = _selectedColors.length > _minColors;
                  final canSelect = _selectedColors.length < _maxColors;
                  final isEnabled = _isReordering
                      ? isSelected
                      : (isSelected ? canDeselect : canSelect);
                  final colorOrder = _colorOrder[color];

                  return GestureDetector(
                    onTap: isEnabled
                        ? () => _isReordering
                              ? _toggleColorOrder(color)
                              : _toggleColor(color)
                        : null,
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
                          if (isSelected && !_isReordering)
                            Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 24,
                            ),
                          if (_isReordering && isSelected && colorOrder != null)
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
                          if (!isEnabled || (_isReordering && !isSelected))
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
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
