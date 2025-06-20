import 'package:flutter/material.dart';

class AppColorSchemes {
  static const Color _primaryColor = Colors.blue;

  static ColorScheme light = ColorScheme.fromSeed(
    seedColor: _primaryColor,
    brightness: Brightness.light,
  );

  static ColorScheme dark = ColorScheme.fromSeed(
    seedColor: _primaryColor,
    brightness: Brightness.dark,
  );
}

// Additional colors not covered by ColorScheme
class BackgroundColors {
  static Color scaffoldLight = Colors.grey[50]!;
  static Color scaffoldDark = Colors.grey[900]!;
  static Color canvasLight = Colors.white;
  static Color canvasDark = Colors.grey[850]!;
}

class ShadowColors {
  static Color light = Colors.grey.withValues(alpha: 0.2);
  static Color dark = Colors.black.withValues(alpha: 0.3);
}
