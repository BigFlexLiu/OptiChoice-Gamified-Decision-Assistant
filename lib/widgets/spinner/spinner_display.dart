import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';
import '../../painters/spinner_painter.dart';

/// A display-only spinner widget that shows a static spinner wheel.
/// This widget does not handle any interactions like spinning or panning.
class SpinnerDisplay extends StatelessWidget {
  final SpinnerModel spinnerModel;
  final double? size;
  final double rotation;
  final Slice? selectedOption;
  final bool showPointer;
  final bool showCenterCircle;
  final bool showShadow;

  const SpinnerDisplay({
    super.key,
    required this.spinnerModel,
    this.size,
    this.rotation = 0,
    this.selectedOption,
    this.showPointer = true,
    this.showCenterCircle = true,
    this.showShadow = true,
  });

  List<Slice> get spinnerSlices => spinnerModel.activeSlices;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = size ?? constraints.maxWidth;
          final shadowSize = containerSize * 0.914;
          final wheelSize = containerSize * 0.857;

          return SizedBox(
            height: containerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showShadow) _buildWheelShadow(shadowSize),
                _buildWheel(wheelSize),
                if (showPointer) _buildPointer(containerSize),
                if (showCenterCircle) _buildCenterCircle(wheelSize),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWheelShadow(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: size * 0.0625,
          offset: Offset(0, size * 0.03125),
        ),
      ],
    ),
  );

  Widget _buildWheel(double size) => Transform.rotate(
    angle: rotation,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: size * 0.05,
                  offset: Offset(0, size * 0.0167),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: SpinnerPainter(
          spinnerModel: spinnerModel,
          rotation: 0,
          selectedOption: selectedOption,
          wheelSize: size,
        ),
        size: Size(size, size),
      ),
    ),
  );

  Widget _buildPointer(double containerHeight) {
    final pointerTop = containerHeight * 0.357;
    final pointerSize = containerHeight * 0.057;
    return Positioned(
      top: pointerTop,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPointerShadow(pointerSize),
          _buildPointerHighlight(pointerSize),
        ],
      ),
    );
  }

  Widget _buildPointerShadow(double baseSize) => Transform.translate(
    offset: Offset(0, -baseSize * 0.18),
    child: Container(
      width: 0,
      height: 0,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.transparent, width: baseSize * 0.9),
          right: BorderSide(color: Colors.transparent, width: baseSize * 0.9),
          top: BorderSide(color: Colors.black, width: baseSize * 1.8),
        ),
      ),
    ),
  );

  Widget _buildPointerHighlight(double baseSize) => Container(
    width: 0,
    height: 0,
    decoration: BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.transparent, width: baseSize * 0.75),
        right: BorderSide(color: Colors.transparent, width: baseSize * 0.75),
        top: BorderSide(color: Colors.white, width: baseSize * 1.5),
      ),
    ),
  );

  Widget _buildCenterCircle(double wheelSize) {
    final circleSize = wheelSize * 0.167;
    final innerCircleSize = circleSize * 0.75;
    final borderWidth = circleSize * 0.08;

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [Colors.white, Colors.grey[100]!]),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: borderWidth),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: circleSize * 0.2,
                  offset: Offset(0, circleSize * 0.06),
                ),
              ]
            : null,
      ),
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          Icons.cached_sharp,
          color: Colors.black,
          size: innerCircleSize,
        ),
      ),
    );
  }
}
