import 'package:flutter/material.dart';
import 'roulette_wheel.dart';
import '../storage/roulette_storage_service.dart';
import '../storage/roulette_wheel_model.dart';
import '../enums/roulette_paint_mode.dart';

class RoulettePreview extends StatefulWidget {
  final List<String> options;
  final double? size;
  final bool showSpinButton;
  final String? rouletteId; // Optional: preview specific roulette by ID

  const RoulettePreview({
    Key? key,
    required this.options,
    this.size,
    this.showSpinButton = false,
    this.rouletteId,
  }) : super(key: key);

  @override
  State<RoulettePreview> createState() => _RoulettePreviewState();
}

class _RoulettePreviewState extends State<RoulettePreview> {
  List<List<Color>> _gradientColors = [];
  List<Color> _solidColors = [];
  RoulettePaintMode _paintMode = RoulettePaintMode.gradient;
  int _colorThemeIndex = 0;
  bool _colorsLoaded = false;

  // Static cache to avoid reloading colors for multiple instances
  static RouletteWheelModel? _cachedActiveRoulette;
  static bool _cacheInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRouletteData();
  }

  Future<void> _loadRouletteData() async {
    try {
      RouletteWheelModel? roulette;

      if (widget.rouletteId != null) {
        // Load specific roulette by ID
        roulette = await RouletteStorageService.loadRouletteById(
          widget.rouletteId!,
        );
      } else {
        // Use cached active roulette if available
        if (_cacheInitialized && _cachedActiveRoulette != null) {
          roulette = _cachedActiveRoulette;
        } else {
          // Load active roulette and cache it
          roulette = await RouletteStorageService.loadActiveRoulette();
          if (roulette != null) {
            _cachedActiveRoulette = roulette;
            _cacheInitialized = true;
          }
        }
      }

      if (roulette != null) {
        setState(() {
          _gradientColors = roulette!.gradientColors;
          _solidColors = roulette.solidColors;
          _paintMode = roulette.paintMode;
          _colorThemeIndex = roulette.colorThemeIndex;
          _colorsLoaded = true;
        });
      } else {
        // Use default colors if no roulette is found
        _useDefaultColors();
      }
    } catch (e) {
      // Use default colors if loading fails
      _useDefaultColors();
      debugPrint('RoulettePreview: Failed to load roulette data: $e');
    }
  }

  void _useDefaultColors() {
    setState(() {
      _gradientColors = [
        [Colors.red, Colors.orange],
        [Colors.blue, Colors.cyan],
        [Colors.green, Colors.lime],
        [Colors.purple, Colors.pink],
        [Colors.orange, Colors.yellow],
        [Colors.teal, Colors.blue],
      ];
      _solidColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ];
      _paintMode = RoulettePaintMode.gradient;
      _colorThemeIndex = 0;
      _colorsLoaded = true;
    });
  }

  /// Clear the static cache (useful when active roulette is updated)
  static void clearCache() {
    _cachedActiveRoulette = null;
    _cacheInitialized = false;
  }

  /// Update cache with new active roulette (call this when active roulette changes)
  static void updateCache(RouletteWheelModel roulette) {
    _cachedActiveRoulette = roulette;
    _cacheInitialized = true;
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
