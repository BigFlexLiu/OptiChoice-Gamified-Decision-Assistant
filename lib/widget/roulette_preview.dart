import 'package:flutter/material.dart';
import 'roulette_wheel.dart';
import '../storage/color_storage_service.dart';
import '../enums/roulette_paint_mode.dart';

class RoulettePreview extends StatefulWidget {
  final List<String> options;
  final double? size;
  final bool showSpinButton;

  const RoulettePreview({
    Key? key,
    required this.options,
    this.size,
    this.showSpinButton = false,
  }) : super(key: key);

  @override
  State<RoulettePreview> createState() => _RoulettePreviewState();
}

class _RoulettePreviewState extends State<RoulettePreview> {
  List<List<Color>> _gradientColors = [];
  List<Color> _solidColors = [];
  RoulettePaintMode _paintMode = RoulettePaintMode.gradient;
  bool _colorsLoaded = false;

  // Static cache to avoid reloading colors for multiple instances
  static List<List<Color>>? _cachedGradientColors;
  static List<Color>? _cachedSolidColors;
  static RoulettePaintMode? _cachedPaintMode;
  static bool _cacheInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    // Use cached colors if available
    if (_cacheInitialized &&
        _cachedGradientColors != null &&
        _cachedSolidColors != null &&
        _cachedPaintMode != null) {
      setState(() {
        _gradientColors = _cachedGradientColors!;
        _solidColors = _cachedSolidColors!;
        _paintMode = _cachedPaintMode!;
        _colorsLoaded = true;
      });
      return;
    }

    try {
      final futures = await Future.wait([
        ColorStorageService.gradientColors,
        ColorStorageService.solidColors,
      ]);

      // Cache the results for other instances
      _cachedGradientColors = futures[0] as List<List<Color>>;
      _cachedSolidColors = futures[1] as List<Color>;
      _cachedPaintMode = RoulettePaintMode.gradient;
      _cacheInitialized = true;

      setState(() {
        _gradientColors = _cachedGradientColors!;
        _solidColors = _cachedSolidColors!;
        _paintMode = _cachedPaintMode!;
        _colorsLoaded = true;
      });
    } catch (e) {
      // Use default colors if loading fails
      _useDefaultColors();
      print(e);
    }
  }

  void _useDefaultColors() {
    setState(() {
      _gradientColors = [
        [Colors.red, Colors.pink],
        [Colors.blue, Colors.cyan],
        [Colors.green, Colors.lightGreen],
        [Colors.orange, Colors.yellow],
        [Colors.purple, Colors.purpleAccent],
      ];
      _solidColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
      ];
      _paintMode = RoulettePaintMode.gradient;
      _colorsLoaded = true;
    });
  }

  /// Clear the static cache (useful when colors are updated in settings)
  static void clearCache() {
    _cachedGradientColors = null;
    _cachedSolidColors = null;
    _cachedPaintMode = null;
    _cacheInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_colorsLoaded) {
      return Container(
        width: widget.size ?? 196,
        height: widget.size ?? 196,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return RouletteWheel(
      options: widget.options,
      isSpinning: false,
      onSpinStart: () {},
      onSpinComplete: (_) {},
      gradientColors: _gradientColors,
      solidColors: _solidColors,
      paintMode: _paintMode,
      showSpinButton: widget.showSpinButton,
      size: widget.size,
    );
  }
}
