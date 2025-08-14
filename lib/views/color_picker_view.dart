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
const int _kColorWheelResolution = 400;

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
  late List<Color> selectedColors, _initialColors;
  Color currentColor = Colors.white;
  final ScrollController _scrollController = ScrollController();
  double _brightness = 1.0, _hue = 0.0, _saturation = 1.0;

  @override
  void initState() {
    super.initState();
    selectedColors = List.from(widget.initialColors);
    _initialColors = List.from(widget.initialColors);
    final hsv = HSVColor.fromColor(currentColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _brightness = hsv.value;
  }

  bool _hasChanges() =>
      selectedColors.length != _initialColors.length ||
      selectedColors.indexed.any(
        (e) => e.$2.toARGB32() != _initialColors[e.$1].toARGB32(),
      );

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
    final hsv = HSVColor.fromColor(color);
    setState(() {
      currentColor = color;
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _brightness = hsv.value;
    });
  }

  void _setBrightness(double brightness) => setState(() {
    _brightness = brightness;
    currentColor = HSVColor.fromAHSV(
      1.0,
      _hue,
      _saturation,
      _brightness,
    ).toColor();
  });

  void _addCurrentColorToSelected() {
    if (selectedColors.length >= _kMaxSelectedColors) return;

    final currentARGB = currentColor.toARGB32();
    if (selectedColors.any((color) => color.toARGB32() == currentARGB)) return;

    setState(() => selectedColors.add(currentColor));
  }

  void _removeSelectedColor(Color color) {
    if (selectedColors.length <= _kMinSelectedColors) return;
    setState(() => selectedColors.remove(color));
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
          title: const Text('Customize Colors'),
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
            _buildBrightnessSliderSection(),
            _buildColorPreviewSection(),
            _buildSelectedColorsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorWheelSection() => Expanded(
    child: Center(
      child: ColorWheel(
        onColorSelected: _setCurrentColor,
        size: null, // Let ColorWheel handle its own sizing
        brightness: _brightness,
      ),
    ),
  );

  Widget _buildBrightnessSliderSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.brightness_low,
                color: onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _brightness,
                  onChanged: _setBrightness,
                  divisions: 100,
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.brightness_high,
                color: onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
          Text(
            'Brightness: ${(_brightness * 100).round()}%',
            key: ValueKey(_brightness.round()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreviewSection() {
    final canAdd = selectedColors.length < _kMaxSelectedColors;

    return GestureDetector(
      onTap: canAdd ? _addCurrentColorToSelected : null,
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canAdd ? currentColor : Colors.grey.shade400,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            canAdd
                ? 'Tap to Add Color (${selectedColors.length}/$_kMaxSelectedColors)'
                : 'Maximum $_kMaxSelectedColors colors reached',
            style: TextStyle(
              color: canAdd
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 120,
            ), // Enough for 2 rows
            child: ReorderableBuilder(
              scrollController: _scrollController,
              onReorder: _reorderColors,
              fadeInDuration: const Duration(milliseconds: 100),
              releasedChildDuration: const Duration(milliseconds: 0),
              positionDuration: const Duration(microseconds: 0),
              builder: (children) => GridView(
                shrinkWrap: true,
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 4,
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
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
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
  final double brightness;

  const ColorWheel({
    super.key,
    required this.onColorSelected,
    this.size,
    this.brightness = 1.0,
  });

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

  @override
  void didUpdateWidget(ColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness != widget.brightness) {
      // Brightness change doesn't require cache regeneration
      // The wheel display stays the same, only selection changes
    }
  }

  void _initCache() async {
    if (_globalCache != null) {
      if (mounted) setState(() {});
      return;
    }

    _globalCache = await (_generating ??= _generateColorWheel());
    if (mounted) setState(() {});
  }

  static Future<ui.Image> _generateColorWheel() async {
    const size = _kColorWheelResolution;
    final pixels = Uint8List(size * size * 4);
    const center = size * 0.5;
    const radius = center;
    const radiusSquared = radius * radius;

    // Pre-calculate constant for radian to degree conversion
    const rad2deg = 180.0 / math.pi;

    for (int y = 0, i = 0; y < size; y++) {
      final dy = y - center;
      final dySquared = dy * dy;

      for (int x = 0; x < size; x++, i += 4) {
        final dx = x - center;
        final distSq = dx * dx + dySquared;

        if (distSq <= radiusSquared) {
          final hue = (math.atan2(dy, dx) * rad2deg + 360) % 360;
          final sat = math.sqrt(distSq) / radius;

          // Optimized HSV to RGB conversion
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

          // Direct assignment without rounding for better performance
          pixels[i] = (r * 255).toInt();
          pixels[i + 1] = (g * 255).toInt();
          pixels[i + 2] = (b * 255).toInt();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.8;
        return Center(
          child: GestureDetector(
            onTapDown: _handleColorSelection,
            onPanUpdate: _handleColorSelectionUpdate,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _globalCache != null ? 0.4 : 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _globalCache != null
                  ? CustomPaint(
                      size: Size(size, size),
                      painter: CachedColorWheelPainter(_globalCache!),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }

  void _handleColorSelection(TapDownDetails details) =>
      _selectColorAt(details.globalPosition);

  void _handleColorSelectionUpdate(DragUpdateDetails details) =>
      _selectColorAt(details.globalPosition);

  void _selectColorAt(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final color = _getColorFromPosition(localPosition, box.size);
    if (color != null) widget.onColorSelected(color);
  }

  Color? _getColorFromPosition(Offset position, Size size) {
    final center = size.width * 0.5;
    final (dx, dy) = (position.dx - center, position.dy - center);
    final distSq = dx * dx + dy * dy;

    if (distSq > center * center) return null;

    final hue = (math.atan2(dy, dx) * 180.0 / math.pi + 360) % 360;
    final saturation = math.sqrt(distSq) / center;

    return HSVColor.fromAHSV(1.0, hue, saturation, widget.brightness).toColor();
  }
}

class CachedColorWheelPainter extends CustomPainter {
  final ui.Image cachedImage;

  const CachedColorWheelPainter(this.cachedImage);

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
