import 'dart:ui';

class ColorTheme {
  final String name;
  final List<Color> colors;

  const ColorTheme({required this.name, required this.colors});
}

class DefaultColorThemes {
  // Private constructor to prevent instantiation
  DefaultColorThemes._();
  // Static list of all available color themes
  static final List<ColorTheme> _colorThemes = [
    _vibrantTheme,
    _neonPopTheme,
    _earthSkyTheme,
    _technoNightTheme,
    _retroArcadeTheme,
  ];
  static const ColorTheme _vibrantTheme = ColorTheme(
    name: 'Vibrant',
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFF667eea),
      Color(0xFFf093fb),
      Color(0xFF4facfe),
      Color(0xFF43e97b),
      Color(0xFFfa709a),
      Color(0xFF30cfd0),
    ],
  );
  static const ColorTheme _neonPopTheme = ColorTheme(
    name: 'Neon Pop',
    colors: [
      Color(0xFFFF00FF), // Magenta
      Color(0xFF00FFFF), // Cyan
      Color(0xFFFFFF00), // Yellow
      Color(0xFFFF0000), // Red
      Color(0xFF00FF00), // Lime
      Color(0xFF0000FF), // Blue
      Color(0xFFFFA500), // Orange
      Color(0xFF00CED1), // Dark Turquoise
    ],
  );
  static const ColorTheme _earthSkyTheme = ColorTheme(
    name: 'Earth & Sky',
    colors: [
      Color(0xFF2E8B57), // Sea Green
      Color(0xFF4682B4), // Steel Blue
      Color(0xFFDAA520), // Goldenrod
      Color(0xFF8B0000), // Dark Red
      Color(0xFF20B2AA), // Light Sea Green
      Color(0xFFB22222), // Firebrick
      Color(0xFF5F9EA0), // Cadet Blue
      Color(0xFFFF8C00), // Dark Orange
    ],
  );
  static const ColorTheme _retroArcadeTheme = ColorTheme(
    name: 'Retro Arcade',
    colors: [
      Color(0xFFFC427B), // Bright Pink
      Color(0xFFF8EFBA), // Pale Yellow
      Color(0xFF55E6C1), // Mint
      Color(0xFF3B3B98), // Indigo
      Color(0xFFFF6B81), // Light Red
      Color(0xFF25CCF7), // Aqua
      Color(0xFFFD7272), // Salmon
      Color(0xFFF19066), // Coral
    ],
  );
  static const ColorTheme _technoNightTheme = ColorTheme(
    name: 'Techno Night',
    colors: [
      Color(0xFF0F3460), // Deep Navy
      Color(0xFFE94560), // Vivid Red
      Color(0xFF53354A), // Purple Brown
      Color(0xFF903749), // Dark Rose
      Color(0xFFFFD460), // Gold
      Color(0xFF3EC1D3), // Teal
      Color(0xFF6A2C70), // Dark Purple
      Color(0xFF1FAB89), // Sea Green
    ],
  );

  static const ColorTheme _purpleTheme = ColorTheme(
    name: 'Purple',
    colors: [
      Color(0xFF667eea),
      Color(0xFF9C27B0),
      Color(0xFF673AB7),
      Color(0xFF3F51B5),
      Color(0xFF5E35B1),
      Color(0xFF7B1FA2),
      Color(0xFF8E24AA),
      Color(0xFF6A1B9A),
    ],
  );

  // Public static getters and methods for accessing themes

  /// Returns all available color themes
  static List<ColorTheme> get all => List.unmodifiable(_colorThemes);

  /// Returns the number of available themes
  static int get count => _colorThemes.length;

  /// Returns theme names
  static List<String> get names =>
      _colorThemes.map((theme) => theme.name).toList();

  /// Gets a theme by name (case-insensitive)
  static ColorTheme? getByName(String name) {
    try {
      return _colorThemes.firstWhere(
        (theme) => theme.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets a theme by index
  static ColorTheme? getByIndex(int index) {
    if (index >= 0 && index < _colorThemes.length) {
      return _colorThemes[index];
    }
    return null;
  }

  /// Gets the default theme (first in the list)
  static ColorTheme get defaultTheme => _colorThemes.first;
}
