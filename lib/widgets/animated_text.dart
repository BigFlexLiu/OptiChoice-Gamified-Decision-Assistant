import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final bool shouldAnimate;
  final Color color;
  final void Function() setShouldAnimateFalse;
  const AnimatedText(
    this.text,
    this.shouldAnimate,
    this.color,
    this.setShouldAnimateFalse, {
    super.key,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  final _animationTime = 500;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Cache for font size calculations to avoid expensive recalculations
  final Map<String, double> _fontSizeCache = {};

  String _cacheKey(String text, double maxWidth, double maxHeight) =>
      '$text|$maxWidth|$maxHeight';

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
          end: 2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2,
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
  void didUpdateWidget(covariant AnimatedText oldWidget) {
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

  // Helper method to calculate appropriate font size for two lines
  double _calculateOptimalFontSize(
    String text,
    double maxWidth,
    double maxHeight,
    TextStyle baseStyle,
  ) {
    // Check cache first
    final cacheKey = _cacheKey(text, maxWidth, maxHeight);
    if (_fontSizeCache.containsKey(cacheKey)) {
      return _fontSizeCache[cacheKey]!;
    }

    const maxLines = 2;
    double fontSize = baseStyle.fontSize ?? 24.0;
    const minFontSize = 12.0;
    const maxFontSize = 48.0;

    // Start with a reasonable font size
    fontSize = fontSize.clamp(minFontSize, maxFontSize);

    // Use binary search for faster convergence instead of linear search
    double low = minFontSize;
    double high = fontSize;
    double result = minFontSize;

    while (high - low > 1.0) {
      final mid = (low + high) / 2;
      final textStyle = baseStyle.copyWith(fontSize: mid);
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        textAlign: TextAlign.center,
      );

      textPainter.layout(maxWidth: maxWidth);

      // Check if text fits within the constraints
      if (textPainter.height <= maxHeight && !textPainter.didExceedMaxLines) {
        result = mid;
        low = mid;
      } else {
        high = mid;
      }
    }

    final finalResult = result.clamp(minFontSize, maxFontSize);

    // Cache the result
    _fontSizeCache[cacheKey] = finalResult;

    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle = (theme.textTheme.headlineLarge ?? TextStyle())
        .copyWith(inherit: false, fontWeight: FontWeight.w700);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Define margin and padding values
        const marginHorizontal = 16.0;
        const marginVertical = 8.0;
        const paddingAll = 8.0;

        // Calculate available space after accounting for margin and padding
        final availableWidth =
            constraints.maxWidth - (marginHorizontal * 2) - (paddingAll * 2);
        final availableHeight = constraints.maxHeight == double.infinity
            ? (baseTextStyle.fontSize ?? 24.0) * 2.5
            : constraints.maxHeight - (marginVertical * 2) - (paddingAll * 2);

        final optimalFontSize = _calculateOptimalFontSize(
          widget.text,
          availableWidth,
          availableHeight,
          baseTextStyle,
        );

        final adaptiveTextStyle = baseTextStyle.copyWith(
          fontSize: optimalFontSize,
          color: widget.color,
        );

        Text baseTextWidget = Text(
          widget.text,
          style: adaptiveTextStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // Fallback in case of extreme cases
        );

        // Wrap text with margin/padding using the defined constants
        Widget textWithMargin = Container(
          margin: const EdgeInsets.symmetric(
            horizontal: marginHorizontal,
            vertical: marginVertical,
          ),
          padding: const EdgeInsets.all(paddingAll),
          child: baseTextWidget,
        );

        if (!widget.shouldAnimate) {
          return textWithMargin;
        }

        // Use AnimatedBuilder to listen to scale animation
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: textWithMargin,
            );
          },
        );
      },
    );
  }
}
