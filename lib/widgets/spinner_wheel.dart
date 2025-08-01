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
  int _currentPointingIndex = 0; // Track the current pointing indexfinal
  Color currentOptionColor = Colors.black;

  // Drag rotation variables
  bool _isDragging = false;
  double _lastPanAngle = 0;

  // Cached calculations for efficiency
  double _sectionAngle = 0;
  final double _twoPi = 2 * math.pi;

  List<SpinnerOption> get spinnerOptions => widget.spinnerModel.activeOptions;

  void _updateCachedCalculations() {
    if (spinnerOptions.isNotEmpty) {
      _sectionAngle = _twoPi / spinnerOptions.length;
    }
  }

  @override
  void initState() {
    super.initState();
    _updateCachedCalculations();
    _initializeAnimation();
    _initializeInitialOption();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SpinnerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset animation state when widget parameters change
    if (oldWidget.spinnerModel != widget.spinnerModel) {
      _controller.reset();
      _updateCachedCalculations();
      _initializeAnimation();

      _currentPointingIndex = 0;
      _initializeInitialOption();
    }

    // Spin got cancelled prematurely
    if (oldWidget.isSpinning != widget.isSpinning && !widget.isSpinning) {
      _controller.stop();
    }
  }

  void _initializeInitialOption() {
    final firstOption = spinnerOptions.firstOrNull;
    if (firstOption != null && widget.onPointingOptionChanged != null) {
      widget.onPointingOptionChanged!(firstOption);
      setState(() {
        currentOptionColor = widget.spinnerModel.getCircularBackgroundColor(0);
      });
    }
  }

  void _initializeAnimation() {
    // Use the spinner's configured duration
    _controller = AnimationController(
      duration: widget.spinnerModel.spinDuration,
      vsync: this,
    );

    _initializeCurrentRotation();
    _animation = Tween<double>(
      begin: _currentRotation,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Add listener to track rotation during animation - only when spinning
    _animation.addListener(_onAnimationUpdate);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reportWinner();
      }
    });
  }

  void _onAnimationUpdate() {
    if (widget.onPointingOptionChanged != null && widget.isSpinning) {
      _updatePointingOption();
    }
  }

  void _initializeCurrentRotation() {
    if (spinnerOptions.isNotEmpty) {
      setState(() {
        _currentRotation =
            -_sectionAngle / 2; // Position at middle of first section
      });
    }
  }

  int _calculatePointingIndex(double rotationValue) {
    if (spinnerOptions.isEmpty) return 0;

    final normalizedRotation = rotationValue % _twoPi;
    final pointerAngle = (_twoPi - normalizedRotation) % _twoPi;
    return (pointerAngle / _sectionAngle).floor() % spinnerOptions.length;
  }

  void _updatePointingOption() {
    if (spinnerOptions.isEmpty) return;

    final pointingIndex = _calculatePointingIndex(_animation.value);

    // Only call the callback if the pointing index has changed
    if (_currentPointingIndex != pointingIndex) {
      _currentPointingIndex = pointingIndex;
      widget.onPointingOptionChanged!(spinnerOptions[pointingIndex]);
    }
  }

  void _spin() {
    if (widget.isSpinning || spinnerOptions.length < 2) return;

    widget.onSpinStart();
    _startSpinAnimation();
  }

  void _startSpinAnimation() {
    // Reset drag state when starting spin
    _isDragging = false;

    final random = math.Random();

    // Calculate spins based on duration - reduced speed for shorter durations
    final durationSeconds =
        widget.spinnerModel.spinDuration.inMilliseconds / 1000.0;

    // Use a more conservative scaling for shorter durations
    // Minimum 1.5 spins for shortest duration (0.5s), max 4 spins for longest (5s)
    final baseSpins =
        1 + (durationSeconds - 0.5) * (2.5 / 4.5); // Linear scale from 1.5 to 4
    final randomSpins =
        baseSpins + random.nextDouble() - 0.5; // Smaller random variance

    // Add random offset to ensure any option can be selected regardless of duration
    // This ensures equal probability for all options
    final randomOffset = random.nextDouble() * _sectionAngle;

    final finalRotation =
        _currentRotation + (randomSpins * _twoPi) + randomOffset;

    // Update controller duration to match spinner's configured duration
    _controller.duration = widget.spinnerModel.spinDuration;

    _animation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Re-add the listener for the new animation
    _animation.addListener(_onAnimationUpdate);

    _currentRotation = finalRotation;
    _controller.reset();
    _controller.forward();
  }

  void _reportWinner() {
    final winnerOption = _getCurrentPointingOption();
    if (winnerOption != null) {
      final optionIdx = spinnerOptions.indexOf(winnerOption);
      setState(() {
        currentOptionColor = optionIdx != -1
            ? widget.spinnerModel.getCircularBackgroundColor(optionIdx)
            : widget.spinnerModel.backgroundColors.first;
      });
    }
    widget.onSpinComplete(winnerOption?.text ?? "");
  }

  SpinnerOption? _getCurrentPointingOption() {
    if (spinnerOptions.isEmpty) return null;

    // Use current rotation for drag or animation value for spinning
    final rotationValue = _isDragging ? _currentRotation : _animation.value;
    final pointingIndex = _calculatePointingIndex(rotationValue);

    return spinnerOptions[pointingIndex];
  }

  // Drag handling methods
  void _onPanStart(DragStartDetails details, double wheelSize) {
    if (widget.isSpinning) return;

    _isDragging = true;
    _controller.stop();

    // Sync _currentRotation with the animation value to prevent jerks
    _currentRotation = _animation.value;

    final center = Offset(wheelSize / 2, wheelSize / 2);
    final localPosition = details.localPosition - center;
    _lastPanAngle = math.atan2(localPosition.dy, localPosition.dx);

    // Call onPointingOptionChanged immediately when drag starts
    if (widget.onPointingOptionChanged != null) {
      _updatePointingOptionForDrag();
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double wheelSize) {
    if (widget.isSpinning || !_isDragging) return;

    final center = Offset(wheelSize / 2, wheelSize / 2);
    final localPosition = details.localPosition - center;
    final currentAngle = math.atan2(localPosition.dy, localPosition.dx);

    // Calculate the angle difference
    double angleDelta = currentAngle - _lastPanAngle;

    // Handle angle wrap-around
    if (angleDelta > math.pi) {
      angleDelta -= 2 * math.pi;
    } else if (angleDelta < -math.pi) {
      angleDelta += 2 * math.pi;
    }

    // Update rotation
    setState(() {
      _currentRotation += angleDelta;
    });

    // Update pointing option during drag - this will call onPointingOptionChanged
    if (widget.onPointingOptionChanged != null) {
      _updatePointingOptionForDrag();
    }

    _lastPanAngle = currentAngle;
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isSpinning) return;

    _isDragging = false;

    // Update the animation to start from the current drag position
    // This prevents jerks when transitioning back to animation-based rotation
    _animation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Re-add the listener for consistency
    _animation.addListener(_onAnimationUpdate);

    // Update the pointing option after drag ends
    if (widget.onPointingOptionChanged != null) {
      _updatePointingOptionForDrag();
    }
  }

  void _updatePointingOptionForDrag() {
    if (spinnerOptions.isEmpty) return;

    final pointingIndex = _calculatePointingIndex(_currentRotation);

    // Only call the callback if the pointing index has changed
    if (_currentPointingIndex != pointingIndex) {
      _currentPointingIndex = pointingIndex;
      widget.onPointingOptionChanged!(spinnerOptions[pointingIndex]);

      // Update the current option color
      setState(() {
        currentOptionColor = widget.spinnerModel.getCircularBackgroundColor(
          pointingIndex,
        );
      });
    }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width with 16px margins on both sides
        final availableWidth = MediaQuery.of(context).size.width;

        // Use the widget.size if provided, otherwise use available width
        final containerSize = widget.size ?? availableWidth;
        final shadowSize = containerSize * 0.914; // 320/350 ratio
        final wheelSize = containerSize * 0.857; // 300/350 ratio

        return SizedBox(
          height: containerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildWheelShadow(shadowSize),
              _buildAnimatedWheel(wheelSize),
              _buildPointer(containerSize),
              _buildCenterCircle(wheelSize),
            ],
          ),
        );
      },
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
    return GestureDetector(
      onPanStart: (details) => _onPanStart(details, size),
      onPanUpdate: (details) => _onPanUpdate(details, size),
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Use current rotation for drag or animation value for spinning
          final rotationAngle = _isDragging
              ? _currentRotation
              : _animation.value;

          return Transform.rotate(
            angle: rotationAngle,
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
      ),
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
    final circleSize = wheelSize * 0.167;
    final innerCircleSize = circleSize * 0.75;
    final borderWidth = circleSize * 0.08;

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
              blurRadius: circleSize * 0.2,
              offset: Offset(0, circleSize * 0.06),
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
                color: Colors.black,
                size: innerCircleSize,
              ),
            );
          },
        ),
      ),
    );
  }
}
