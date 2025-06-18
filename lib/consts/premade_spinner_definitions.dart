import 'package:decision_spinner/storage/spinner_wheel_model.dart';
import 'package:decision_spinner/views/spinner_options_view.dart';
import 'package:flutter/material.dart';

class PremadeSpinnerDefinitions {
  static SpinnerModel get yesNoSpinner => SpinnerModel(
    newId: 'premade_yes_no',
    name: 'Yes or No',
    options: [
      SpinnerOption(text: 'Yes', weight: 1.0),
      SpinnerOption(text: 'No', weight: 1.0),
    ],
    colorThemeIndex: 0,
    colors: [Colors.green.shade500, Colors.red.shade500],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
