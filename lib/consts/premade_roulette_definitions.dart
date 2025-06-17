import 'package:decision_spin/storage/roulette_wheel_model.dart';
import 'package:decision_spin/views/roulette_options_view.dart';
import 'package:flutter/material.dart';

class PremadeRouletteDefinitions {
  static RouletteModel get yesNoRoulette => RouletteModel(
    newId: 'premade_yes_no',
    name: 'Yes or No',
    options: [
      RouletteOption(text: 'Yes', weight: 1.0),
      RouletteOption(text: 'No', weight: 1.0),
    ],
    colorThemeIndex: 0,
    colors: [Colors.green.shade500, Colors.red.shade500],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
