import 'dart:ui';

class ColorTheme {
  final String name;
  final List<List<Color>> gradientColors;
  final List<Color> colors;

  const ColorTheme({
    required this.name,
    required this.gradientColors,
    required this.colors,
  });
}

class DefaultColorThemes {
  // Private constructor to prevent instantiation
  DefaultColorThemes._();
  // Static list of all available color themes
  static final List<ColorTheme> _colorThemes = [
    _vibrantTheme,
    _oceanTheme,
    _sunsetTheme,
    _forestTheme,
    _purpleTheme,
  ];

  // Individual theme definitions as static constants
  static const ColorTheme _vibrantTheme = ColorTheme(
    name: 'Vibrant',
    gradientColors: [
      [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFf5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
      [Color(0xFFfa709a), Color(0xFFfee140)],
      [Color(0xFF30cfd0), Color(0xFF91a7ff)],
    ],
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

  static const ColorTheme _oceanTheme = ColorTheme(
    name: 'Ocean',
    gradientColors: [
      [Color(0xFF2E86AB), Color(0xFF72DBD9)],
      [Color(0xFF00B4DB), Color(0xFF0083B0)],
      [Color(0xFF1CB5E0), Color(0xFF000851)],
      [Color(0xFF4481EB), Color(0xFF04BEFE)],
      [Color(0xFF5B73C4), Color(0xFF9198E5)],
      [Color(0xFF2196F3), Color(0xFF21CBF3)],
      [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
      [Color(0xFF00ACC1), Color(0xFF26C6DA)],
    ],
    colors: [
      Color(0xFF2E86AB),
      Color(0xFF00B4DB),
      Color(0xFF1CB5E0),
      Color(0xFF4481EB),
      Color(0xFF5B73C4),
      Color(0xFF2196F3),
      Color(0xFF4FC3F7),
      Color(0xFF00ACC1),
    ],
  );

  static const ColorTheme _sunsetTheme = ColorTheme(
    name: 'Sunset',
    gradientColors: [
      [Color(0xFFFF9A8B), Color(0xFFA890FE)],
      [Color(0xFFFFAD84), Color(0xFFFF6B6B)],
      [Color(0xFFFFA726), Color(0xFFFF7043)],
      [Color(0xFFFF8A65), Color(0xFFFF5722)],
      [Color(0xFFFFB74D), Color(0xFFFF9800)],
      [Color(0xFFFFCC02), Color(0xFFFF6F00)],
      [Color(0xFFFF5722), Color(0xFFE91E63)],
      [Color(0xFFF57F17), Color(0xFFFF6F00)],
    ],
    colors: [
      Color(0xFFFF9A8B),
      Color(0xFFFFAD84),
      Color(0xFFFFA726),
      Color(0xFFFF8A65),
      Color(0xFFFFB74D),
      Color(0xFFFFCC02),
      Color(0xFFFF5722),
      Color(0xFFF57F17),
    ],
  );

  static const ColorTheme _forestTheme = ColorTheme(
    name: 'Forest',
    gradientColors: [
      [Color(0xFF56AB2F), Color(0xFFA8E6CF)],
      [Color(0xFF11998E), Color(0xFF38EF7D)],
      [Color(0xFF00B09B), Color(0xFF96C93D)],
      [Color(0xFF2E8B57), Color(0xFF90EE90)],
      [Color(0xFF228B22), Color(0xFF32CD32)],
      [Color(0xFF006400), Color(0xFF7CFC00)],
      [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      [Color(0xFF388E3C), Color(0xFF66BB6A)],
    ],
    colors: [
      Color(0xFF56AB2F),
      Color(0xFF11998E),
      Color(0xFF00B09B),
      Color(0xFF2E8B57),
      Color(0xFF228B22),
      Color(0xFF006400),
      Color(0xFF4CAF50),
      Color(0xFF388E3C),
    ],
  );

  static const ColorTheme _purpleTheme = ColorTheme(
    name: 'Purple',
    gradientColors: [
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
      [Color(0xFF673AB7), Color(0xFF9575CD)],
      [Color(0xFF3F51B5), Color(0xFF7986CB)],
      [Color(0xFF5E35B1), Color(0xFF9575CD)],
      [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
      [Color(0xFF8E24AA), Color(0xFFCE93D8)],
      [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    ],
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

  // Individual theme getters for direct access
  static ColorTheme get vibrant => _vibrantTheme;
  static ColorTheme get ocean => _oceanTheme;
  static ColorTheme get sunset => _sunsetTheme;
  static ColorTheme get forest => _forestTheme;
  static ColorTheme get purple => _purpleTheme;
}
