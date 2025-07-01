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
  final Map<Color, int> _colorOrder = {};

  late List<Color> _initialColors;
  late Map<Color, int> _initialColorOrder;

  final List<Color> _colorChoices = [
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

    for (int i = 0; i < widget.initialColors.length; i++) {
      _colorOrder[widget.initialColors[i]] = i + 1;
    }

    _initialColors = List.from(widget.initialColors);
    _initialColorOrder = Map.from(_colorOrder);
  }

  bool _hasChanges() {
    // Check if number of selected colors changed
    if (_selectedColors.length != _initialColors.length) {
      return true;
    }

    // Check if selected colors changed
    if (!_selectedColors.containsAll(_initialColors) ||
        !_initialColors.every((color) => _selectedColors.contains(color))) {
      return true;
    }

    // Check if order changed
    for (final color in _selectedColors) {
      if (_colorOrder[color] != _initialColorOrder[color]) {
        return true;
      }
    }

    return false;
  }

  void _toggleColor(Color color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
        _colorOrder.remove(color);
      } else {
        _selectedColors.add(color);
        // Assign the next available order immediately
        _colorOrder[color] = _getNextAvailableOrder();
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

  void _saveColors() {
    _reassignOrders();
    // Get all selected colors with their orders
    final List<MapEntry<Color, int>> colorOrderPairs = _selectedColors
        .map((color) => MapEntry(color, _colorOrder[color] ?? _maxColors + 1))
        .toList();

    // Sort by order to get the relative ordering
    colorOrderPairs.sort((a, b) => a.value.compareTo(b.value));

    // Extract colors in their relative order
    final orderedColors = colorOrderPairs.map((entry) => entry.key).toList();

    widget.onColorsChanged(orderedColors);
    Navigator.of(context).pop();
  }

  int _getNextAvailableOrder() {
    final used = Set.of(_colorOrder.values);
    for (var i = 1; i <= _maxColors; i++) {
      if (!used.contains(i)) return i;
    }
    return _maxColors + 1;
  }

  Future<void> _showDiscardChangesDialog() async {
    final result = await showDialog<bool>(
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

    if (result == true) {
      Navigator.of(context).pop();
    }
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
                  itemCount: _colorChoices.length,
                  itemBuilder: (context, index) {
                    final color = _colorChoices[index];
                    final isSelected = _selectedColors.contains(color);
                    final canDeselect = _selectedColors.length > _minColors;
                    final canSelect = _selectedColors.length < _maxColors;
                    final isEnabled = isSelected ? canDeselect : canSelect;
                    final colorOrder = _colorOrder[color];

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
