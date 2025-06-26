import 'package:flutter/material.dart';

class ColorPickerWidget extends StatefulWidget {
  final List<Color> initialColors;
  final Function(List<Color>) onColorsChanged;

  const ColorPickerWidget({
    Key? key,
    required this.initialColors,
    required this.onColorsChanged,
  }) : super(key: key);

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  List<Color> selectedColors = [];
  bool hasChanges = false;

  // Predefined color palette
  final List<Color> availableColors = [
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
    selectedColors = List.from(widget.initialColors);
  }

  void _toggleColor(Color color) {
    setState(() {
      if (selectedColors.contains(color)) {
        // Remove color if already selected (but keep minimum of 2)
        if (selectedColors.length > 2) {
          selectedColors.remove(color);
          _checkForChanges();
        }
      } else {
        // Add color if not selected (but keep maximum of 12)
        if (selectedColors.length < 12) {
          selectedColors.add(color);
          _checkForChanges();
        }
      }
    });
  }

  void _checkForChanges() {
    bool changed =
        selectedColors.length != widget.initialColors.length ||
        !selectedColors.every((color) => widget.initialColors.contains(color));

    setState(() {
      hasChanges = changed;
    });
  }

  void _saveChanges() {
    widget.onColorsChanged(List.from(selectedColors));
    setState(() {
      hasChanges = false;
    });
  }

  void _resetChanges() {
    setState(() {
      selectedColors = List.from(widget.initialColors);
      hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Picker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: hasChanges
            ? [
                TextButton(
                  onPressed: _resetChanges,
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  child: Text('Save'),
                ),
                SizedBox(width: 8),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected colors count and info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Colors (${selectedColors.length}/12)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select between 2 and 12 colors. Tap to toggle selection.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 12),
                    // Show selected colors
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedColors.map((color) {
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Available colors grid
            Text(
              'Available Colors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  final color = availableColors[index];
                  final isSelected = selectedColors.contains(color);
                  final canDeselect = selectedColors.length > 2;
                  final canSelect = selectedColors.length < 12;

                  return GestureDetector(
                    onTap: () {
                      if (isSelected && canDeselect) {
                        _toggleColor(color);
                      } else if (!isSelected && canSelect) {
                        _toggleColor(color);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade300,
                          width: isSelected ? 4 : 2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 24,
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
    );
  }

  // Helper method to get contrasting color for the check icon
  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// Example usage widget
class ColorPickerExample extends StatefulWidget {
  @override
  _ColorPickerExampleState createState() => _ColorPickerExampleState();
}

class _ColorPickerExampleState extends State<ColorPickerExample> {
  List<Color> myColors = [Colors.red, Colors.blue, Colors.green];

  void _onColorsChanged(List<Color> newColors) {
    setState(() {
      myColors = newColors;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Colors saved! Selected ${newColors.length} colors.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ColorPickerWidget(
        initialColors: myColors,
        onColorsChanged: _onColorsChanged,
      ),
    );
  }
}
