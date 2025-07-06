import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // Dismiss existing one
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

void showErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // Dismiss existing one
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

BoxDecoration colorSampleDecoration(
  BuildContext context,
  Color fillColor, {
  double width = 2,
  int alpha = 128,
  double strokeAlign = BorderSide.strokeAlignOutside,
}) => BoxDecoration(
  color: fillColor,
  shape: BoxShape.circle,
  border: Border.all(
    width: 2,
    color: Theme.of(context).colorScheme.outline.withAlpha(alpha),
    strokeAlign: strokeAlign,
  ),
);

class AnimatedRotation extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedRotation({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.rotate(angle: animation.value, child: child);
      },
    );
  }
}
