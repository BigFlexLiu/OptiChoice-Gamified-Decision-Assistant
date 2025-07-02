import 'dart:math' as math;
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';
import '../painters/spinner_painter.dart';

class SpinnerWheel extends StatefulWidget {
  final SpinnerModel spinnerModel;
  final bool isSpinning;
  final VoidCallback onSpinStart;
  final Function(String) onSpinComplete;
  final Function(SpinnerOption)? onPointingOptionChanged;
  final double? size;
  final bool showSpinButton;

  const SpinnerWheel({
    super.key,
    required this.spinnerModel,
    required this.isSpinning,
    required this.onSpinStart,
    required this.onSpinComplete,
    this.onPointingOptionChanged,
    this.size,
    this.showSpinButton = true,
  });

  @override
  SpinnerWheelState createState() => SpinnerWheelState();
}

class SpinnerWheelState extends State<SpinnerWheel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0;
  int? _currentPointingIndex; // Track the current pointing indexfinal
  double? wheelSize;
  Color currentOptionColor = Colors.black;

  List<String> get spinnerTextOptions =>
      widget.spinnerModel.options.map((e) => e.text).toList();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    // Initialize with the first option pointing
    final firstOption = widget.spinnerModel.options.firstOrNull;

    if (firstOption != null && widget.onPointingOptionChanged != null) {
      _currentPointingIndex = 0; // Set initial pointing index
      widget.onPointingOptionChanged!(firstOption);
      setState(() {
        currentOptionColor = widget.spinnerModel.getCircularBackgroundColor(0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    // Use the spinner's configured duration
    _controller = AnimationController(
      duration: widget.spinnerModel.spinDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Add listener to track rotation during animation
    _animation.addListener(() {
      if (widget.onPointingOptionChanged != null && widget.isSpinning) {
        _updatePointingOption();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reportWinner();
      }
    });
  }

  void _updatePointingOption() {
    if (spinnerTextOptions.isEmpty) return;

    final normalizedRotation = _animation.value % (2 * math.pi);
    final sectionAngle = (2 * math.pi) / spinnerTextOptions.length;
    final pointerAngle = (2 * math.pi - normalizedRotation) % (2 * math.pi);
    final pointingIndex =
        (pointerAngle / sectionAngle).floor() % spinnerTextOptions.length;

    // Only call the callback if the pointing index has changed
    if (_currentPointingIndex != pointingIndex) {
      _currentPointingIndex = pointingIndex;
      widget.onPointingOptionChanged!(
        widget.spinnerModel.options[pointingIndex],
      );
    }
  }

  void _spin() {
    if (widget.isSpinning || spinnerTextOptions.length < 2) return;

    widget.onSpinStart();
    _startSpinAnimation();
  }

  void _startSpinAnimation() {
    final random = math.Random();

    // Calculate spins based on duration - reduced speed for shorter durations
    final durationSeconds =
        widget.spinnerModel.spinDuration.inMilliseconds / 1000.0;

    // Use a more conservative scaling for shorter durations
    // Minimum 1.5 spins for shortest duration (0.5s), max 4 spins for longest (5s)
    final baseSpins =
        1 + (durationSeconds - 0.5) * (2.5 / 4.5); // Linear scale from 1.5 to 4
    final randomSpins =
        baseSpins + random.nextDouble() * 0.5; // Smaller random variance

    // Add random offset to ensure any option can be selected regardless of duration
    // This ensures equal probability for all options
    final sectionAngle = (2 * math.pi) / spinnerTextOptions.length;
    final randomOffset = random.nextDouble() * sectionAngle;

    final finalRotation =
        _currentRotation + (randomSpins * 2 * math.pi) + randomOffset;

    // Update controller duration to match spinner's configured duration
    _controller.duration = widget.spinnerModel.spinDuration;

    _animation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Re-add the listener for the new animation
    _animation.addListener(() {
      if (widget.onPointingOptionChanged != null && widget.isSpinning) {
        _updatePointingOption();
      }
    });

    _currentRotation = finalRotation;
    _controller.reset();
    _controller.forward();
  }

  void _reportWinner() {
    final winnerOption = _getCurrentPointingOption();
    if (winnerOption != null) {
      setState(() {
        currentOptionColor = widget.spinnerModel.getCircularColorOfOption(
          winnerOption,
        );
      });
    }
    widget.onSpinComplete(winnerOption?.text ?? "");
  }

  SpinnerOption? _getCurrentPointingOption() {
    if (spinnerTextOptions.isEmpty) return null;

    final normalizedRotation = _animation.value % (2 * math.pi);
    final sectionAngle = (2 * math.pi) / spinnerTextOptions.length;
    final pointerAngle = (2 * math.pi - normalizedRotation) % (2 * math.pi);
    final pointingIndex =
        (pointerAngle / sectionAngle).floor() % spinnerTextOptions.length;

    return widget.spinnerModel.options[pointingIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_buildSpinnerWheel()],
      ),
    );
  }

  Widget _buildSpinnerWheel() {
    final containerHeight = widget.size ?? 350;
    final shadowSize = containerHeight * 0.914; // 320/350 ratio
    final wheelSize = containerHeight * 0.857; // 300/350 ratio

    return SizedBox(
      height: containerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildWheelShadow(shadowSize),
          _buildAnimatedWheel(wheelSize),
          _buildPointer(containerHeight),
          _buildCenterCircle(wheelSize),
        ],
      ),
    );
  }

  Widget _buildWheelShadow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: size * 0.0625, // 20/320 ratio
            offset: Offset(0, size * 0.03125), // 10/320 ratio
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWheel(double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: size * 0.05, // 15/300 ratio
                  offset: Offset(0, size * 0.0167), // 5/300 ratio
                ),
              ],
            ),
            child: CustomPaint(
              painter: SpinnerPainter(
                spinnerModel: widget.spinnerModel,
                rotation: 0, // Rotation is handled by Transform.rotate
                selectedOption: _getCurrentPointingOption(),
                wheelSize: size, // Pass the wheel size for text scaling
              ),
              size: Size(size, size),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointer(double containerHeight) {
    final pointerTop = containerHeight * 0.357; // 125/350 ratio
    final pointerSize =
        containerHeight * 0.057; // Scale pointer relative to spinner size

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

  Widget _buildPointerShadow(double baseSize) {
    final width = baseSize * 0.9; // Proportional to pointer base size
    final height = baseSize * 1.8; // Proportional to pointer base size

    return Transform.translate(
      offset: Offset(0, -height * 0.1), // Proportional shadow offset
      child: Container(
        width: 0,
        height: 0,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.transparent, width: width),
            right: BorderSide(color: Colors.transparent, width: width),
            top: BorderSide(
              color: Colors.black.withValues(alpha: 1),
              width: height,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointerHighlight(double baseSize) {
    final width = baseSize * 0.75; // Proportional to pointer base size
    final height = baseSize * 1.5; // Proportional to pointer base size

    return Container(
      width: 0,
      height: 0,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.transparent, width: width),
          right: BorderSide(color: Colors.transparent, width: width),
          top: BorderSide(color: Colors.white, width: height),
        ),
      ),
    );
  }

  Widget _buildCenterCircle(double wheelSize) {
    final circleSize = wheelSize * 0.167; // 50/300 ratio
    final innerCircleSize = circleSize * 0.75; // 20/50 ratio
    final borderWidth = circleSize * 0.08; // 4/50 ratio

    return InkWell(
      onTap: _spin,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [Colors.white, Colors.grey[100]!]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: circleSize * 0.2, // 10/50 ratio
              offset: Offset(0, circleSize * 0.06), // 3/50 ratio
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: Icon(
                Icons.cached_sharp,
                color: currentOptionColor,
                size: innerCircleSize,
              ),
            );
          },
        ),
      ),
    );
  }
}
