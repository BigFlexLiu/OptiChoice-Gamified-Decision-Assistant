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
  late List<Color> _colors;
  final int _minColors = 2;
  final int _maxColors = 12;

  // Predefined color palette for easy selection
  static const List<Color> _colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _colors = List.from(widget.initialColors);

    // Ensure minimum colors
    while (_colors.length < _minColors) {
      _colors.add(_colorPalette[_colors.length % _colorPalette.length]);
    }
  }

  void _addColor() {
    if (_colors.length < _maxColors) {
      setState(() {
        // Add a color that's not already in the list
        Color newColor = _colorPalette.firstWhere(
          (color) => !_colors.contains(color),
          orElse: () => _colorPalette[_colors.length % _colorPalette.length],
        );
        _colors.add(newColor);
      });
    }
  }

  void _removeColor(int index) {
    if (_colors.length > _minColors) {
      setState(() {
        _colors.removeAt(index);
      });
    }
  }

  void _updateColor(int index, Color color) {
    setState(() {
      _colors[index] = color;
    });
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _colors[index],
        onColorSelected: (color) => _updateColor(index, color),
      ),
    );
  }

  void _saveColors() {
    widget.onColorsChanged(_colors);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose colors for your spinner',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You can have between $_minColors and $_maxColors colors.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Color list
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _colors.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final color = _colors.removeAt(oldIndex);
                    _colors.insert(newIndex, color);
                  });
                },
                itemBuilder: (context, index) {
                  return _buildColorItem(index, theme);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Add color button
            if (_colors.length < _maxColors)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addColor,
                  icon: Icon(Icons.add),
                  label: Text('Add Color'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(int index, ThemeData theme) {
    return Container(
      key: ValueKey('color_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
        title: Text('Color ${index + 1}'),
        subtitle: Text(_getColorName(_colors[index])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showColorPicker(index),
              icon: Icon(Icons.edit),
              tooltip: 'Edit color',
            ),
            if (_colors.length > _minColors)
              IconButton(
                onPressed: () => _removeColor(index),
                icon: Icon(Icons.delete_outline),
                tooltip: 'Remove color',
              ),
          ],
        ),
        onTap: () => _showColorPicker(index),
      ),
    );
  }

  String _getColorName(Color color) {
    // Simple color name detection
    if (color == Colors.red) return 'Red';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.cyan) return 'Cyan';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.lime) return 'Lime';
    if (color == Colors.amber) return 'Amber';
    if (color == Colors.brown) return 'Brown';
    if (color == Colors.grey) return 'Grey';
    if (color == Colors.black) return 'Black';

    // For custom colors, show hex value
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  // Predefined colors for quick selection
  static const List<List<Color>> _colorShades = [
    [Colors.red, Colors.redAccent],
    [Colors.pink, Colors.pinkAccent],
    [Colors.purple, Colors.purpleAccent],
    [Colors.deepPurple, Colors.deepPurpleAccent],
    [Colors.indigo, Colors.indigoAccent],
    [Colors.blue, Colors.blueAccent],
    [Colors.lightBlue, Colors.lightBlueAccent],
    [Colors.cyan, Colors.cyanAccent],
    [Colors.teal, Colors.tealAccent],
    [Colors.green, Colors.greenAccent],
    [Colors.lightGreen, Colors.lightGreenAccent],
    [Colors.lime, Colors.limeAccent],
    [Colors.yellow, Colors.yellowAccent],
    [Colors.amber, Colors.amberAccent],
    [Colors.orange, Colors.orangeAccent],
    [Colors.deepOrange, Colors.deepOrangeAccent],
    [Colors.brown],
    [Colors.grey],
    [Colors.blueGrey],
    [Colors.black, Colors.white],
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Choose Color'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected color preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.outline, width: 2),
              ),
            ),
            const SizedBox(height: 24),

            // Color palette
            SizedBox(
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _colorShades.expand((shades) => shades).length,
                itemBuilder: (context, index) {
                  final allColors = _colorShades
                      .expand((shades) => shades)
                      .toList();
                  final color = allColors[index];
                  final isSelected = color == _selectedColor;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
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
            widget.onColorSelected(_selectedColor);
            Navigator.of(context).pop();
          },
          child: Text('Select'),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate contrast color for the check icon
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
