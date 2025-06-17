import 'package:flutter/material.dart';
import 'roulette_wheel.dart';
import '../storage/roulette_wheel_model.dart';

class RoulettePreview extends StatefulWidget {
  final RouletteModel roulette;
  final double? size;
  final bool showSpinButton;

  const RoulettePreview({
    super.key,
    required this.roulette,
    this.size,
    this.showSpinButton = false,
  });

  @override
  State<RoulettePreview> createState() => _RoulettePreviewState();
}

class _RoulettePreviewState extends State<RoulettePreview> {
  @override
  Widget build(BuildContext context) {
    return RouletteWheel(
      rouletteModel: widget.roulette,
      isSpinning: false,
      onSpinStart: () {},
      onSpinComplete: (_) {},
      showSpinButton: widget.showSpinButton,
      size: widget.size,
    );
  }
}
