import 'package:decision_spinner/widgets/spinner/spinner_display.dart';
import 'package:flutter/material.dart';
import '../../storage/spinner_model.dart';

class SpinnerPreview extends StatelessWidget {
  final SpinnerModel spinner;
  final double? size;
  final bool showSpinButton;
  final VoidCallback? onTap;

  const SpinnerPreview({
    super.key,
    required this.spinner,
    this.size,
    this.showSpinButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SpinnerDisplay(spinnerModel: spinner, size: size),
    );
  }
}
