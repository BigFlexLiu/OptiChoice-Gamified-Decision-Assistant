import 'package:flutter/material.dart';
import 'spinner_wheel.dart';
import '../storage/spinner_model.dart';

class SpinnerPreview extends StatefulWidget {
  final SpinnerModel spinner;
  final double? size;
  final bool showSpinButton;

  const SpinnerPreview({
    super.key,
    required this.spinner,
    this.size,
    this.showSpinButton = false,
  });

  @override
  State<SpinnerPreview> createState() => _SpinnerPreviewState();
}

class _SpinnerPreviewState extends State<SpinnerPreview> {
  @override
  Widget build(BuildContext context) {
    return SpinnerWheel(
      spinnerModel: widget.spinner,
      isSpinning: false,
      onSpinStart: () {},
      onSpinComplete: (_) {},
      showSpinButton: widget.showSpinButton,
      size: widget.size,
    );
  }
}
