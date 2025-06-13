// Custom extension for reorderable list styling
import 'package:flutter/material.dart';

extension ReorderableListStyles on ThemeData {
  Color get dragHandleColor => colorScheme.onSurfaceVariant;
  Color get reorderingItemColor => colorScheme.surface;
  double get reorderAnimationDuration => 200;
}

// Add to colorScheme or create custom extension
extension ErrorContainerColors on ColorScheme {
  Color get errorContainer => error.withValues(alpha: 0.1);
  Color get onErrorContainer => error;
}

// No built-in theme, would need custom styling
extension AvatarStyles on ThemeData {
  Color get activeAvatarBackground => colorScheme.primary;
  Color get inactiveAvatarBackground => colorScheme.surface;
  Color get activeAvatarForeground => colorScheme.onPrimary;
  Color get inactiveAvatarForeground => colorScheme.onSurfaceVariant;
} // Custom button theme extension

extension CustomButtonStyles on ThemeData {
  ButtonStyle get outlinedActionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    elevation: 0,
    textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
} // Custom extension for empty states

extension EmptyStateStyles on ThemeData {
  TextStyle get emptyStateTitle =>
      textTheme.titleMedium!.copyWith(color: colorScheme.onSurfaceVariant);

  TextStyle get emptyStateBody =>
      textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant);

  double get emptyStateIconSize => 64;
} // Custom extension for borders

extension BorderStyles on ThemeData {
  Border get activeBorder => Border.all(color: colorScheme.primary, width: 2);

  Border get errorBorder =>
      Border.all(color: colorScheme.error.withValues(alpha: 0.3));
} // Custom extension for animations

extension AnimationStyles on ThemeData {
  Duration get fastTransition => Duration(milliseconds: 150);
  Duration get normalTransition => Duration(milliseconds: 300);
  Duration get slowTransition => Duration(milliseconds: 500);

  Curve get standardCurve => Curves.easeInOut;
  Curve get emphasizedCurve => Curves.easeInOutCubic;
}
