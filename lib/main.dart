import 'package:decision_spin/views/roulette_view.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(RouletteApp());
}

class RouletteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Roulette',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RouletteView(),
    );
  }
}
