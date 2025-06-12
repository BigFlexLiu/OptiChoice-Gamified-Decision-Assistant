import 'package:flutter/material.dart';

class AppTextThemes {
  static TextTheme light = TextTheme(
    // Display styles (largest text)
    displayLarge: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w400,
      color: Colors.deepPurple[800],
    ),
    displayMedium: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w400,
      color: Colors.deepPurple[700],
    ),
    displaySmall: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: Colors.deepPurple[600],
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple[800],
    ),
    headlineMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple[700],
    ),
    headlineSmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: Colors.deepPurple[600],
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    ),
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: Colors.grey[700],
    ),
    titleSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.grey[600],
    ),

    // Body text styles
    bodyLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: Colors.grey[800],
    ),
    bodyMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Colors.grey[700],
    ),
    bodySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.grey[600],
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.deepPurple[700],
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.deepPurple[600],
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.deepPurple[500],
    ),
  );

  static TextTheme dark = light.copyWith(
    displayLarge: light.displayLarge?.copyWith(color: Colors.deepPurple[200]),
    displayMedium: light.displayMedium?.copyWith(color: Colors.deepPurple[300]),
    displaySmall: light.displaySmall?.copyWith(color: Colors.deepPurple[400]),
    headlineLarge: light.headlineLarge?.copyWith(color: Colors.deepPurple[200]),
    headlineMedium: light.headlineMedium?.copyWith(
      color: Colors.deepPurple[300],
    ),
    headlineSmall: light.headlineSmall?.copyWith(color: Colors.deepPurple[400]),
    titleLarge: light.titleLarge?.copyWith(color: Colors.grey[200]),
    titleMedium: light.titleMedium?.copyWith(color: Colors.grey[300]),
    titleSmall: light.titleSmall?.copyWith(color: Colors.grey[400]),
    bodyLarge: light.bodyLarge?.copyWith(color: Colors.grey[200]),
    bodyMedium: light.bodyMedium?.copyWith(color: Colors.grey[300]),
    bodySmall: light.bodySmall?.copyWith(color: Colors.grey[400]),
    labelLarge: light.labelLarge?.copyWith(color: Colors.deepPurple[300]),
    labelMedium: light.labelMedium?.copyWith(color: Colors.deepPurple[400]),
    labelSmall: light.labelSmall?.copyWith(color: Colors.deepPurple[500]),
  );
}
