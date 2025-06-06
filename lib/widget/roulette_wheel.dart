import 'dart:math' as math;

import 'package:decision_spin/painters/roulette_painter.dart';
import 'package:flutter/material.dart';

class RouletteWheel extends StatefulWidget {
  final List<String> options;
  final bool isSpinning;
  final VoidCallback onSpinStart;
  final Function(String) onSpinComplete;

  const RouletteWheel({
    Key? key,
    required this.options,
    required this.isSpinning,
    required this.onSpinStart,
    required this.onSpinComplete,
  }) : super(key: key);

  @override
  _RouletteWheelState createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _determineWinner();
      }
    });
  }

  void _spin() {
    if (widget.isSpinning || widget.options.length < 2) return;

    widget.onSpinStart();
    _startSpinAnimation();
  }

  void _startSpinAnimation() {
    final random = math.Random();
    final spins = 5 + random.nextDouble() * 3;
    final finalRotation = _currentRotation + (spins * 2 * math.pi);

    _animation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _currentRotation = finalRotation;
    _controller.reset();
    _controller.forward();
  }

  void _determineWinner() {
    if (widget.options.isEmpty) return;

    final normalizedRotation = _currentRotation % (2 * math.pi);
    final sectionAngle = (2 * math.pi) / widget.options.length;
    final pointerAngle = (2 * math.pi - normalizedRotation) % (2 * math.pi);
    final winnerIndex =
        (pointerAngle / sectionAngle).floor() % widget.options.length;

    widget.onSpinComplete(widget.options[winnerIndex]);
  }

  List<Color> _getGradientColorsForIndex(int index) {
    final gradients = [
      [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      [Color(0xFF4ECDC4), Color(0xFF44A08D)],
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFf5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
      [Color(0xFFfa709a), Color(0xFFfee140)],
      [Color(0xFF30cfd0), Color(0xFF91a7ff)],
      [Color(0xFFa8edea), Color(0xFFfed6e3)],
      [Color(0xFFffecd2), Color(0xFFfcb69f)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildRouletteWheel(),
          SizedBox(height: 20),
          _buildSpinButton(),
        ],
      ),
    );
  }

  Widget _buildRouletteWheel() {
    return Container(
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildWheelShadow(),
          _buildAnimatedWheel(),
          _buildPointer(),
          _buildCenterCircle(),
        ],
      ),
    );
  }

  Widget _buildWheelShadow() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWheel() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CustomPaint(
              painter: RoulettePainter(
                widget.options,
                _getGradientColorsForIndex,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointer() {
    return Positioned(
      top: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPointerShadow(),
          _buildMainPointer(),
          _buildPointerHighlight(),
        ],
      ),
    );
  }

  Widget _buildPointerShadow() {
    return Transform.translate(
      offset: Offset(2, 2),
      child: Container(
        width: 0,
        height: 0,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.transparent, width: 18),
            right: BorderSide(color: Colors.transparent, width: 18),
            top: BorderSide(color: Colors.black.withOpacity(0.3), width: 35),
          ),
        ),
      ),
    );
  }

  Widget _buildMainPointer() {
    return Container(
      width: 0,
      height: 0,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.transparent, width: 18),
          right: BorderSide(color: Colors.transparent, width: 18),
          top: BorderSide(color: Colors.white, width: 35),
        ),
      ),
    );
  }

  Widget _buildPointerHighlight() {
    return Container(
      width: 0,
      height: 0,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.transparent, width: 15),
          right: BorderSide(color: Colors.transparent, width: 15),
          top: BorderSide(color: Colors.deepPurple, width: 30),
        ),
      ),
    );
  }

  Widget _buildCenterCircle() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [Colors.white, Colors.grey[100]!]),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.deepPurple, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSpinButton() {
    return ElevatedButton(
      onPressed: widget.isSpinning ? null : _spin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(widget.isSpinning ? 'Spinning...' : 'SPIN!'),
    );
  }
}
