import 'package:flutter/material.dart';
import 'color_schemes.dart';

class AppComponentThemes {
  // App Bar Themes
  static AppBarTheme appBarLight = AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Colors.deepPurple.withValues(alpha: 0.3),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static AppBarTheme appBarDark = appBarLight.copyWith(
    backgroundColor: Colors.deepPurple[800],
    shadowColor: Colors.black.withValues(alpha: 0.3),
  );

  // Button Themes
  static ElevatedButtonThemeData elevatedButtonLight = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static TextButtonThemeData textButtonLight = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.deepPurple,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonLight = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.deepPurple,
      side: BorderSide(color: Colors.deepPurple),
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // Card Theme
  static CardThemeData cardLight = CardThemeData(
    elevation: 2,
    shadowColor: ShadowColors.light,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static CardThemeData cardDark = cardLight.copyWith(
    shadowColor: ShadowColors.dark,
  );

  // Input Decoration Theme
  static InputDecorationTheme inputDecorationLight = InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.deepPurple, width: 2),
    ),
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[600],
    ),
    hintStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey[500],
    ),
  );

  // Floating Action Button Theme
  static FloatingActionButtonThemeData fabLight = FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 6,
    focusElevation: 8,
    hoverElevation: 8,
    splashColor: Colors.deepPurple.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  // Dialog Theme
  static DialogThemeData dialogLight = DialogThemeData(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple[800],
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey[700],
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // Expansion Tile Theme
  static ExpansionTileThemeData expansionTileLight = ExpansionTileThemeData(
    backgroundColor: Colors.transparent,
    collapsedBackgroundColor: Colors.transparent,
    tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    childrenPadding: EdgeInsets.all(0),
    iconColor: Colors.deepPurple,
    collapsedIconColor: Colors.grey[600],
    textColor: Colors.grey[800],
    collapsedTextColor: Colors.grey[700],
  );

  // SnackBar Theme
  static SnackBarThemeData snackBarLight = SnackBarThemeData(
    backgroundColor: Colors.deepPurple,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: Colors.white,
  );

  // Icon Themes
  static IconThemeData iconLight = IconThemeData(
    color: Colors.deepPurple,
    size: 24,
  );

  static IconThemeData primaryIconLight = IconThemeData(
    color: Colors.white,
    size: 24,
  );

  // Additional Themes
  static SliderThemeData sliderLight = SliderThemeData(
    activeTrackColor: Colors.deepPurple,
    inactiveTrackColor: Colors.deepPurple.withValues(alpha: 0.3),
    thumbColor: Colors.deepPurple,
    overlayColor: Colors.deepPurple.withValues(alpha: 0.2),
    valueIndicatorColor: Colors.deepPurple,
    valueIndicatorTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  static TooltipThemeData tooltipLight = TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(6),
    ),
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );

  static DividerThemeData dividerLight = DividerThemeData(
    color: Colors.grey[300],
    thickness: 1,
    space: 1,
  );

  static BadgeThemeData badgeLight = BadgeThemeData(
    backgroundColor: Colors.deepPurple,
    textColor: Colors.white,
    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  );
}
