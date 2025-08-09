import 'dart:math' as math;
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';
import '../painters/spinner_painter.dart';

class SpinnerWheel extends StatefulWidget {
  final SpinnerModel spinnerModel;
  final bool isSpinning;
  final VoidCallback onSpinStart;
  final Function(String) onSpinComplete;
  final Function(Slice)? onPointingOptionChanged;
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
  // Constants
  static const double _twoPi = 2 * math.pi;

  // Animation Controllers and Variables
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationListenerAttached = false;

  // Rotation and State Variables
  double _currentRotation = 0;
  int _currentPointingIndex = 0;
  double _sectionAngle = 0;

  // Drag State Variables
  bool _isDragging = false;
  double _lastPanAngle = 0;
  double _dragDirection = 1.0;

  // Getters
  List<Slice> get spinnerSlices => widget.spinnerModel.activeSlices;
  double get _currentRotationAngle =>
      _isDragging ? _currentRotation : _animation.value;

  // Lifecycle Methods
  @override
  void initState() {
    super.initState();
    if (spinnerSlices.isNotEmpty) _sectionAngle = _twoPi / spinnerSlices.length;
    _initializeAnimation();
    final firstOption = spinnerSlices.firstOrNull;
    if (firstOption != null && widget.onPointingOptionChanged != null) {
      widget.onPointingOptionChanged!(firstOption);
    }
  }

  @override
  void didUpdateWidget(SpinnerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset animation state when widget parameters change
    if (oldWidget.spinnerModel != widget.spinnerModel) {
      _controller.reset();
      if (spinnerSlices.isNotEmpty)
        _sectionAngle = _twoPi / spinnerSlices.length;
      _initializeAnimation();
      _currentPointingIndex = 0;
      final firstOption = spinnerSlices.firstOrNull;
      if (firstOption != null && widget.onPointingOptionChanged != null) {
        widget.onPointingOptionChanged!(firstOption);
      }
    }

    // Spin got cancelled prematurely
    if (oldWidget.isSpinning != widget.isSpinning && !widget.isSpinning) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _detachAnimationListener();
    _controller.dispose();
    super.dispose();
  }

  // Widget Build Methods
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = widget.size ?? constraints.maxWidth;
          final shadowSize = containerSize * 0.914;
          final wheelSize = containerSize * 0.857;

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

  Widget _buildAnimatedWheel(double size) => GestureDetector(
    onPanStart: (details) => _onPanStart(details, size),
    onPanUpdate: (details) => _onPanUpdate(details, size),
    onPanEnd: _onPanEnd,
    child: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.rotate(
        angle: _currentRotationAngle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: size * 0.05,
                offset: Offset(0, size * 0.0167),
              ),
            ],
          ),
          child: CustomPaint(
            painter: SpinnerPainter(
              spinnerModel: widget.spinnerModel,
              rotation: 0,
              selectedOption: _getCurrentPointingOption(),
              wheelSize: size,
            ),
            size: Size(size, size),
          ),
        ),
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

    final centerWidget = Container(
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
          final rotationAngle = _currentRotationAngle;
          return Transform.rotate(
            angle: rotationAngle,
            child: Icon(
              Icons.cached_sharp,
              color: Colors.black,
              size: innerCircleSize,
            ),
          );
        },
      ),
    );

    // Only make it tappable if showSpinButton is true
    if (widget.showSpinButton) {
      return InkWell(onTap: _spin, child: centerWidget);
    } else {
      return centerWidget;
    }
  }

  // Animation Setup Methods
  void _initializeAnimation() {
    _controller = AnimationController(
      duration: widget.spinnerModel.spinDuration,
      vsync: this,
    );
    _currentRotation = spinnerSlices.isNotEmpty ? -_sectionAngle / 2 : 0;
    _animation = Tween<double>(
      begin: _currentRotation,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _ensureAnimationListenerAttached();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _reportWinner();
    });
  }

  void _ensureAnimationListenerAttached() {
    if (!_animationListenerAttached) {
      _animation.addListener(_onAnimationUpdate);
      _animationListenerAttached = true;
    }
  }

  void _detachAnimationListener() {
    if (_animationListenerAttached) {
      _animation.removeListener(_onAnimationUpdate);
      _animationListenerAttached = false;
    }
  }

  void _onAnimationUpdate() {
    if (widget.onPointingOptionChanged != null && widget.isSpinning) {
      _updatePointingOptionWithRotation(_animation.value);
    }
  }

  // Calculation Methods
  int _calculatePointingIndex(double rotationValue) {
    if (spinnerSlices.isEmpty) return 0;
    final normalizedRotation = rotationValue % _twoPi;
    final pointerAngle = (_twoPi - normalizedRotation) % _twoPi;
    return (pointerAngle / _sectionAngle).floor() % spinnerSlices.length;
  }

  double _calculateSpinRotations() {
    final durationSeconds =
        widget.spinnerModel.spinDuration.inMilliseconds / 1000.0;
    final baseSpins = 1 + (durationSeconds - 0.5) * (2.5 / 4.5);
    return baseSpins + math.Random().nextDouble() - 0.5;
  }

  // Spin Methods
  void _spin() {
    if (spinnerSlices.length < 2) return;

    // If already spinning, stop the current animation first (interrupt)
    if (widget.isSpinning) {
      _controller.stop();
    }

    widget.onSpinStart();
    _startSpinAnimation();
  }

  void _startSpinAnimation() => _executeSpinAnimation(
    _calculateSpinRotations(),
    widget.spinnerModel.spinDuration,
  );

  void _startDragBasedSpinAnimation(Offset velocity) {
    final velocityMagnitude = velocity.distance;
    final spins =
        (velocityMagnitude * 0.001).clamp(1.0, 6.0) +
        (math.Random().nextDouble() - 0.5) * 0.5;

    // Calculate duration based on drag velocity instead of spinner model
    // Higher velocity = longer spin duration
    // Scale: 500px/s = 1s, 1500px/s = 3s, 3000px/s = 5s
    final baseDurationMs = (velocityMagnitude / 500.0 * 1000.0).clamp(
      500.0,
      5000.0,
    );
    final duration = Duration(milliseconds: baseDurationMs.round());

    _executeSpinAnimation(spins, duration);
  }

  void _executeSpinAnimation(double spins, Duration duration) {
    // Reset drag state
    _isDragging = false;

    final random = math.Random();
    final randomOffset = random.nextDouble() * _sectionAngle;

    // Use tracked drag direction for drag-based spins, clockwise for regular spins
    final spinDirection = _dragDirection.sign;
    final finalRotation =
        _currentRotation + (spins * _twoPi * spinDirection) + randomOffset;

    // Update controller and create new animation
    _controller.duration = duration;
    _detachAnimationListener();

    _animation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _ensureAnimationListenerAttached();
    _currentRotation = finalRotation;

    _controller.reset();
    _controller.forward();
  }

  void _createStaticAnimation() {
    _detachAnimationListener();
    _animation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _ensureAnimationListenerAttached();
  }

  // Result and Option Update Methods
  void _reportWinner() {
    final winnerOption = _getCurrentPointingOption();
    widget.onSpinComplete(winnerOption?.text ?? "");
  }

  Slice? _getCurrentPointingOption() {
    if (spinnerSlices.isEmpty) return null;

    // Use current rotation for drag or animation value for spinning
    final rotationValue = _isDragging ? _currentRotation : _animation.value;
    final pointingIndex = _calculatePointingIndex(rotationValue);

    return spinnerSlices[pointingIndex];
  }

  void _updatePointingOptionForDrag() {
    if (widget.onPointingOptionChanged == null) return;
    _updatePointingOptionWithRotation(_currentRotation);
  }

  void _updatePointingOptionWithRotation(double rotationValue) {
    if (spinnerSlices.isEmpty) return;
    final pointingIndex = _calculatePointingIndex(rotationValue);
    if (_currentPointingIndex != pointingIndex) {
      _currentPointingIndex = pointingIndex;
      widget.onPointingOptionChanged!(spinnerSlices[pointingIndex]);
    }
  }

  // Pan/Drag Event Handlers
  void _onPanStart(DragStartDetails details, double wheelSize) {
    // Allow interrupting spin animation by starting drag
    if (widget.isSpinning) {
      _controller.stop();
      // Notify that spinning was interrupted
      // Note: We don't call widget.onSpinStart() here as we're interrupting, not starting
    }

    _isDragging = true;
    _dragDirection = 1.0;
    _currentRotation = _animation.value;
    final center = Offset(wheelSize / 2, wheelSize / 2);
    _lastPanAngle = math.atan2(
      (details.localPosition - center).dy,
      (details.localPosition - center).dx,
    );
    _updatePointingOptionForDrag();
  }

  void _onPanUpdate(DragUpdateDetails details, double wheelSize) {
    // Allow panning even during spinning (interruption is handled in _onPanStart)
    if (!_isDragging) return;
    final center = Offset(wheelSize / 2, wheelSize / 2);
    final localPosition = details.localPosition - center;
    final currentAngle = math.atan2(localPosition.dy, localPosition.dx);
    double angleDelta = currentAngle - _lastPanAngle;

    if (angleDelta > math.pi)
      angleDelta -= _twoPi;
    else if (angleDelta < -math.pi)
      angleDelta += _twoPi;

    if (angleDelta.abs() > 0.01) {
      final newDirection = angleDelta > 0 ? 1.0 : -1.0;
      _dragDirection = (_dragDirection * 0.7) + (newDirection * 0.3);
    }

    setState(() => _currentRotation += angleDelta);
    _updatePointingOptionForDrag();
    _lastPanAngle = currentAngle;
  }

  void _onPanEnd(DragEndDetails details) {
    // Allow pan end processing even if originally spinning (since we can interrupt)
    if (!_isDragging) return;
    _isDragging = false;
    final velocityMagnitude = details.velocity.pixelsPerSecond.distance;

    if (velocityMagnitude > 500.0 && spinnerSlices.length >= 2) {
      widget.onSpinStart();
      _startDragBasedSpinAnimation(details.velocity.pixelsPerSecond);
    } else {
      _createStaticAnimation();
      _updatePointingOptionForDrag();
    }
  }
}
