import 'package:decision_spinner/views/spinner_view.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(SpinnerApp());
}

class SpinnerApp extends StatelessWidget {
  const SpinnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Spinner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          ThemeMode.system, // Automatically switches based on system preference
      home: SpinnerView(),
    );
  }
}
