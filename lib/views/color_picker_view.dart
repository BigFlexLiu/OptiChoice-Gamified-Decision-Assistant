import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import '../widgets/dialogs/unsaved_changes_dialog.dart';

// Constants
const int _kMaxSelectedColors = 12;
const int _kMinSelectedColors = 2;
const double _kColorWheelMargin = 96.0;
const double _kMinColorWheelSize = 200.0;
const int _kColorWheelResolution = 400;
const double _kHueConversionFactor = 57.2958;

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
  Color currentColor = Color.from(alpha: 255, red: 255, green: 255, blue: 255);
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
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const UnsavedChangesDialog(),
    );

    if (result == 'save') {
      _saveColors();
    } else if (result == 'discard') {
      // Reset to initial colors and close the page
      selectedColors = List.from(_initialColors);
      widget.onColorsChanged(selectedColors);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    // If result is null (dialog dismissed), do nothing - stay on page
  }

  void _setCurrentColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  void _addCurrentColorToSelected() {
    if (selectedColors.length < _kMaxSelectedColors) {
      setState(() {
        if (!selectedColors.contains(currentColor)) {
          selectedColors.add(currentColor);
        }
      });
    }
  }

  void _removeSelectedColor(Color color) {
    if (selectedColors.length > _kMinSelectedColors) {
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
            _buildColorWheelSection(),
            _buildColorPreviewSection(),
            _buildSelectedColorsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorWheelSection() {
    return Expanded(
      flex: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = MediaQuery.of(context).size.width;
          final availableHeight = constraints.maxHeight;
          final maxSize =
              math.min(availableWidth, availableHeight) - _kColorWheelMargin;
          final wheelSize = math.max(_kMinColorWheelSize, maxSize.toDouble());

          return Center(
            child: ColorWheel(
              onColorSelected: _setCurrentColor,
              size: wheelSize,
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPreviewSection() {
    return GestureDetector(
      onTap: selectedColors.length < _kMaxSelectedColors
          ? _addCurrentColorToSelected
          : null,
      child: Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedColors.length < _kMaxSelectedColors
              ? currentColor
              : Colors.grey.shade400,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            selectedColors.length < _kMaxSelectedColors
                ? 'Tap to Add Color (${selectedColors.length}/$_kMaxSelectedColors)'
                : 'Maximum $_kMaxSelectedColors colors reached',
            style: TextStyle(
              color: selectedColors.length < _kMaxSelectedColors
                  ? (currentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedColorsSection() {
    return Expanded(
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
                builder: (children) => GridView(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  children: children,
                ),
                children: List.generate(selectedColors.length, (index) {
                  final color = selectedColors[index];
                  return GestureDetector(
                    key: Key('color_$index'),
                    onTap: selectedColors.length > _kMinSelectedColors
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
                          color: selectedColors.length > _kMinSelectedColors
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
    );
  }
}

/// A circular color wheel widget that displays the full color spectrum.
///
/// The wheel is generated once at high resolution and cached for performance.
/// It adapts to different sizes by scaling the cached image.
class ColorWheel extends StatefulWidget {
  final Function(Color) onColorSelected;
  final double? size;

  const ColorWheel({super.key, required this.onColorSelected, this.size});

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  static ui.Image? _globalCache;
  static Future<ui.Image>? _generating;

  double get _wheelSize => widget.size ?? 300.0;

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  @override
  void didUpdateWidget(ColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    const size = _kColorWheelResolution;
    final pixels = Uint8List(size * size * 4);
    const center = size * 0.5;
    const radius = center;

    for (int y = 0, i = 0; y < size; y++) {
      final dy = y - center;
      for (int x = 0; x < size; x++, i += 4) {
        final dx = x - center;
        final distSq = dx * dx + dy * dy;

        if (distSq <= radius * radius) {
          final hue = (math.atan2(dy, dx) * _kHueConversionFactor + 360) % 360;
          final sat = math.sqrt(distSq) / radius;

          // HSV to RGB conversion
          final h60 = hue / 60;
          final c = sat;
          final x = c * (1 - (h60 % 2 - 1).abs());
          final m = 1.0 - c;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleColorSelection,
      onPanUpdate: _handleColorSelection,
      child: Container(
        width: _wheelSize,
        height: _wheelSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_globalCache != null ? 0.4 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _globalCache != null
            ? CustomPaint(
                size: Size(_wheelSize, _wheelSize),
                painter: CachedColorWheelPainter(_globalCache!),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _handleColorSelection(details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final color = _getColorFromPosition(
      localPosition,
      Size(_wheelSize, _wheelSize),
    );
    if (color != null) {
      widget.onColorSelected(color);
    }
  }

  Color? _getColorFromPosition(Offset position, Size size) {
    final center = size.width * 0.5;
    final dx = position.dx - center;
    final dy = position.dy - center;
    final distSq = dx * dx + dy * dy;

    if (distSq > center * center) return null;

    final hue = (math.atan2(dy, dx) * _kHueConversionFactor + 360) % 360;
    final saturation = math.sqrt(distSq) / center;

    return HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
  }
}

class CachedColorWheelPainter extends CustomPainter {
  final ui.Image cachedImage;

  CachedColorWheelPainter(this.cachedImage);

  @override
  void paint(Canvas canvas, Size size) {
    final srcRect = Rect.fromLTWH(
      0,
      0,
      cachedImage.width.toDouble(),
      cachedImage.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(cachedImage, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(CachedColorWheelPainter oldDelegate) =>
      oldDelegate.cachedImage != cachedImage;
}
