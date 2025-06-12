import 'package:decision_spin/views/roulette_view.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(RouletteApp());
}

class RouletteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Roulette',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          ThemeMode.system, // Automatically switches based on system preference
      home: RouletteView(),
    );
  }
}
