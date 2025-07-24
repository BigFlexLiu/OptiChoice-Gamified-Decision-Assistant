import 'package:flutter/material.dart';

class AnimatedTextJumpChangeColor extends StatefulWidget {
  final String text;
  final bool shouldAnimate;
  final void Function() setShouldAnimateFalse;
  final Color? color;
  const AnimatedTextJumpChangeColor(
    this.text,
    this.shouldAnimate,
    this.setShouldAnimateFalse,
    this.color, {
    super.key,
  });

  @override
  State<AnimatedTextJumpChangeColor> createState() =>
      _AnimatedTextJumpChangeColorState();
}

class _AnimatedTextJumpChangeColorState
    extends State<AnimatedTextJumpChangeColor>
    with SingleTickerProviderStateMixin {
  final _animationTime = 500;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: _animationTime),
      vsync: this,
    );

    // Create a combined animation that goes up then down
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_scaleController);

    if (widget.shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedTextJumpChangeColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scaleController.isAnimating) {
          _startAnimation();
        }
      });
    }
  }

  void _startAnimation() {
    _scaleController.reset();
    _scaleController.forward().then((_) {
      if (mounted) {
        widget.setShouldAnimateFalse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = (theme.textTheme.headlineLarge ?? TextStyle())
        .copyWith(inherit: false, fontWeight: FontWeight.w700);

    Text baseTextWidget = Text(
      widget.text,
      style: defaultTextStyle,
      textAlign: TextAlign.center,
    );

    if (!widget.shouldAnimate) {
      return baseTextWidget;
    }

    // Use AnimatedBuilder to listen to scale animation
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: baseTextWidget,
        );
      },
    );
  }
}
