import 'package:flutter/material.dart';

class DefaultDivider extends StatelessWidget {
  final double height;

  const DefaultDivider({this.height = 8.0, super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: 2,
      color: Theme.of(context).dividerColor.withAlpha(50),
    );
  }
}
