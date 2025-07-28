import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';

class ColorPickerView extends StatefulWidget {
  final List<Color> initialColors;
  final Function(List<Color>) onColorsChanged;

  const ColorPickerView({
    super.key,
    required this.initialColors,
    required this.onColorsChanged,
  });

  @override
  State<ColorPickerView> createState() => _ColorPickerViewState();
}

class _ColorPickerViewState extends State<ColorPickerView> {
  List<Color> selectedColors = [];
  Color? currentColor;
  final ScrollController _scrollController = ScrollController();
  late List<Color> _initialColors;

  @override
  void initState() {
    super.initState();
    selectedColors = List.from(widget.initialColors);
    _initialColors = List.from(widget.initialColors);
  }

  bool _hasChanges() {
    if (selectedColors.length != _initialColors.length) return true;
    for (int i = 0; i < selectedColors.length; i++) {
      if (selectedColors[i] != _initialColors[i]) return true;
    }
    return false;
  }

  void _saveColors() {
    widget.onColorsChanged(selectedColors);
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
                // Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _setCurrentColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  void _addCurrentColorToSelected() {
    if (currentColor != null && selectedColors.length < 12) {
      setState(() {
        if (!selectedColors.contains(currentColor!)) {
          selectedColors.add(currentColor!);
        }
      });
    }
  }

  void _removeSelectedColor(Color color) {
    if (selectedColors.length > 2) {
      setState(() {
        selectedColors.remove(color);
      });
    }
  }

  void _reorderColors(ReorderedListFunction reorderedListFunction) {
    setState(() {
      selectedColors = reorderedListFunction(selectedColors) as List<Color>;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          title: const Text('Custom Colors'),
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
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: ColorWheel(onColorSelected: _setCurrentColor),
              ),
            ),
            if (currentColor != null)
              GestureDetector(
                onTap: selectedColors.length < 12
                    ? _addCurrentColorToSelected
                    : null,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  color: selectedColors.length < 12
                      ? currentColor
                      : Colors.grey.shade400,
                  child: Center(
                    child: Text(
                      selectedColors.length < 12
                          ? 'Tap to Add Color (${selectedColors.length}/12)'
                          : 'Maximum 12 colors reached',
                      style: TextStyle(
                        color: selectedColors.length < 12
                            ? (currentColor!.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white)
                            : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: ReorderableBuilder(
                        scrollController: _scrollController,
                        onReorder: _reorderColors,
                        fadeInDuration: const Duration(milliseconds: 100),
                        releasedChildDuration: const Duration(milliseconds: 0),
                        positionDuration: const Duration(microseconds: 0),
                        builder: (children) {
                          return GridView(
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                            children: children,
                          );
                        },
                        children: List.generate(selectedColors.length, (index) {
                          final color = selectedColors[index];
                          return GestureDetector(
                            key: Key('color_$index'),
                            onTap: selectedColors.length > 2
                                ? () => _removeSelectedColor(color)
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: selectedColors.length > 2
                                      ? Colors.white70
                                      : Colors.white30,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorWheel extends StatefulWidget {
  final Function(Color) onColorSelected;

  const ColorWheel({super.key, required this.onColorSelected});

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final color = _getColorFromPosition(localPosition, box.size);
        if (color != null) {
          widget.onColorSelected(color);
        }
      },
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final color = _getColorFromPosition(localPosition, box.size);
        if (color != null) {
          widget.onColorSelected(color);
        }
      },
      child: CustomPaint(
        size: const Size(300, 300),
        painter: ColorWheelPainter(),
      ),
    );
  }

  Color? _getColorFromPosition(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final distance = (position - center).distance;

    if (distance > radius) return null;

    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    final hue = (angle * 180 / math.pi + 360) % 360;
    final saturation = distance / radius;

    return HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
  }
}

class ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < 360; i++) {
      final hue = i.toDouble();
      for (double r = 0; r < radius; r += 1) {
        final saturation = r / radius;
        final color = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();

        final x = center.dx + r * math.cos(i * math.pi / 180);
        final y = center.dy + r * math.sin(i * math.pi / 180);

        final paint = Paint()..color = color;
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
