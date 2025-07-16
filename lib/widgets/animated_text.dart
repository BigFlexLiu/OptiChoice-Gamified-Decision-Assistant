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
    extends State<AnimatedTextJumpChangeColor> {
  final _animationTime = 500;
  bool _shouldAnimateJump = false;
  bool _shouldAnimateFall = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _shouldAnimateJump = widget.shouldAnimate;
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedTextJumpChangeColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.shouldAnimate &&
          !_shouldAnimateJump &&
          !_shouldAnimateFall) {
        setState(() {
          _shouldAnimateJump = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = (theme.textTheme.headlineLarge ?? TextStyle())
        .copyWith(inherit: false, fontWeight: FontWeight.w700);
    final maxFontSize = theme.textTheme.displayLarge!.fontSize;

    Text baseTextWidget = Text(
      widget.text,
      style: defaultTextStyle,
      textAlign: TextAlign.center,
    );
    if (!_shouldAnimateFall && !_shouldAnimateJump) {
      return AnimatedDefaultTextStyle(
        style: baseTextWidget.style!,
        duration: Duration(),
        onEnd: null,
        child: baseTextWidget,
      );
    }

    final jumpEndTextStyle = defaultTextStyle.copyWith(
      inherit: false,
      // color: widget.color,
      fontSize: maxFontSize,
    );
    if (_shouldAnimateJump) {
      return animateJump(jumpEndTextStyle);
    }

    // Animate fall after the jump
    final fallEndTextStyle = defaultTextStyle.copyWith(inherit: false);
    return animateFall(fallEndTextStyle);
  }

  Widget animateJump(TextStyle endStyle) {
    return AnimatedDefaultTextStyle(
      style: endStyle,
      duration: Duration(milliseconds: _animationTime ~/ 2),
      onEnd: () => {
        setState(() {
          _shouldAnimateJump = false;
          _shouldAnimateFall = true;
        }),
      },
      curve: Curves.easeOut,
      child: Text(widget.text, textAlign: TextAlign.center),
    );
  }

  Widget animateFall(TextStyle endStyle) {
    return AnimatedDefaultTextStyle(
      style: endStyle,
      duration: Duration(milliseconds: _animationTime ~/ 2),
      onEnd: () => {
        setState(() {
          _shouldAnimateJump = false;
          _shouldAnimateFall = false;
          widget.setShouldAnimateFalse();
        }),
      },
      curve: Curves.easeIn,
      child: Text(widget.text, textAlign: TextAlign.center),
    );
  }
}
