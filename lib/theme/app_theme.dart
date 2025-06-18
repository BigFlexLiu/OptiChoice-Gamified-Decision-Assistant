import 'package:decision_spinner/theme/color_schemes.dart';
import 'package:decision_spinner/theme/component_theme.dart';
import 'package:decision_spinner/theme/text_themes.dart';
import 'package:decision_spinner/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    // Base Configuration
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Color Scheme
    colorScheme: AppColorSchemes.light,
    primarySwatch: Colors.deepPurple,
    primaryColor: Colors.deepPurple,

    // Background Colors
    scaffoldBackgroundColor: BackgroundColors.scaffoldLight,
    canvasColor: BackgroundColors.canvasLight,

    // Typography
    textTheme: AppTextThemes.light,

    // Component Themes
    appBarTheme: AppComponentThemes.appBarLight,
    elevatedButtonTheme: AppComponentThemes.elevatedButtonLight,
    textButtonTheme: AppComponentThemes.textButtonLight,
    outlinedButtonTheme: AppComponentThemes.outlinedButtonLight,
    cardTheme: AppComponentThemes.cardLight,
    inputDecorationTheme: AppComponentThemes.inputDecorationLight,
    floatingActionButtonTheme: AppComponentThemes.fabLight,
    dialogTheme: AppComponentThemes.dialogLight,
    expansionTileTheme: AppComponentThemes.expansionTileLight,
    snackBarTheme: AppComponentThemes.snackBarLight,
    iconTheme: AppComponentThemes.iconLight,
    primaryIconTheme: AppComponentThemes.primaryIconLight,
    sliderTheme: AppComponentThemes.sliderLight,
    tooltipTheme: AppComponentThemes.tooltipLight,
    dividerTheme: AppComponentThemes.dividerLight,
    badgeTheme: AppComponentThemes.badgeLight,

    // Custom Extensions
    extensions: [
      SpinnerThemeExtension.light,
      CustomButtonExtension.light,
      AppConstants.standard,
    ],
  );

  static ThemeData dark = ThemeData(
    // Base Configuration
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Color Scheme
    colorScheme: AppColorSchemes.dark,
    primarySwatch: Colors.deepPurple,
    primaryColor: Colors.deepPurple,

    // Background Colors
    scaffoldBackgroundColor: BackgroundColors.scaffoldDark,
    canvasColor: BackgroundColors.canvasDark,

    // Typography
    textTheme: AppTextThemes.dark,

    // Component Themes (you can create dark variants)
    appBarTheme: AppComponentThemes.appBarDark,
    cardTheme: AppComponentThemes.cardDark,
    // ... other themes can be light or create dark variants

    // Custom Extensions
    extensions: [
      SpinnerThemeExtension.dark,
      CustomButtonExtension.dark,
      AppConstants.standard,
    ],
  );
}
