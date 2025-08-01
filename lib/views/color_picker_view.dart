import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
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
  static ui.Image? _globalCache;
  static Future<ui.Image>? _generating;

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  void _initCache() async {
    if (_globalCache != null) {
      setState(() {});
      return;
    }

    _generating ??= _generateColorWheel();
    _globalCache = await _generating;
    if (mounted) setState(() {});
  }

  static Future<ui.Image> _generateColorWheel() async {
    const size = 300;
    final pixels = Uint8List(size * size * 4);
    const center = size * 0.5;
    const radius = size * 0.5;

    for (int y = 0, i = 0; y < size; y++) {
      final dy = y - center;
      for (int x = 0; x < size; x++, i += 4) {
        final dx = x - center;
        final distSq = dx * dx + dy * dy;

        if (distSq <= radius * radius) {
          final angle = math.atan2(dy, dx);
          final hue = (angle * 57.2958 + 360) % 360; // 180/π ≈ 57.2958
          final sat = math.sqrt(distSq) / radius;

          // Correct HSV to RGB using full value (brightness = 1.0)
          final h60 = hue / 60;
          final c = sat; // chroma = saturation * value (where value = 1.0)
          final x = c * (1 - (h60 % 2 - 1).abs());
          final m = 1.0 - c; // m = value - chroma = 1.0 - sat

          final (r, g, b) = switch (h60.floor()) {
            0 => (c + m, x + m, m),
            1 => (x + m, c + m, m),
            2 => (m, c + m, x + m),
            3 => (m, x + m, c + m),
            4 => (x + m, m, c + m),
            _ => (c + m, m, x + m),
          };

          pixels[i] = (r * 255).round();
          pixels[i + 1] = (g * 255).round();
          pixels[i + 2] = (b * 255).round();
          pixels[i + 3] = 255;
        }
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  void dispose() {
    // Don't dispose the globally cached image, just clear local reference
    super.dispose();
  }

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
      child: _globalCache != null
          ? CustomPaint(
              size: const Size(300, 300),
              painter: CachedColorWheelPainter(_globalCache!),
            )
          : const SizedBox(
              width: 300,
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  Color? _getColorFromPosition(Offset position, Size size) {
    final center = size.width * 0.5;
    final dx = position.dx - center;
    final dy = position.dy - center;
    final distSq = dx * dx + dy * dy;

    if (distSq > center * center) return null;

    final hue = (math.atan2(dy, dx) * 57.2958 + 360) % 360;
    final saturation = math.sqrt(distSq) / center;

    return HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
  }
}

class CachedColorWheelPainter extends CustomPainter {
  final ui.Image cachedImage;

  CachedColorWheelPainter(this.cachedImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Simply draw the cached image
    canvas.drawImage(cachedImage, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CachedColorWheelPainter oldDelegate) {
    return oldDelegate.cachedImage != cachedImage;
  }
}
