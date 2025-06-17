class StorageConstants {
  // Roulette related keys
  static const String roulettesKey = 'decision_spin_roulettes';
  static const String activeRouletteKey = 'decision_spin_active_roulette';

  // Color related keys
  static const String savedGradientColorsKey =
      'decision_spin_saved_gradient_colors';
  static const String savedSolidColorsKey = 'decision_spin_saved_solid_colors';
  static const String useGradientKey = 'decision_spin_use_gradient';
  static const String colorThemeKey = 'decision_spin_color_theme';

  // Default values
  static const String defaultRouletteName = 'Food Options';

  static const List<String> defaultOptions = [
    'Pizza',
    'Burger',
    'Thai',
    'Taco',
    'Soup',
  ];

  // Legacy key for migration
  static const String oldOptionsKey = 'decision_spin_options';
}
