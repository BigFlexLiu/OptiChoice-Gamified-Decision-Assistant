import 'package:flutter/material.dart';

// Custom theme extensions for app-specific styling
@immutable
class SpinnerThemeExtension extends ThemeExtension<SpinnerThemeExtension> {
  const SpinnerThemeExtension({
    required this.wheelBackgroundColor,
    required this.wheelBorderColor,
    required this.segmentBorderColor,
    required this.wheelShadowColor,
    required this.resultTextColor,
    required this.spinButtonColor,
  });

  final Color wheelBackgroundColor;
  final Color wheelBorderColor;
  final Color segmentBorderColor;
  final Color wheelShadowColor;
  final Color resultTextColor;
  final Color spinButtonColor;

  @override
  SpinnerThemeExtension copyWith({
    Color? wheelBackgroundColor,
    Color? wheelBorderColor,
    Color? segmentBorderColor,
    Color? wheelShadowColor,
    Color? resultTextColor,
    Color? spinButtonColor,
  }) {
    return SpinnerThemeExtension(
      wheelBackgroundColor: wheelBackgroundColor ?? this.wheelBackgroundColor,
      wheelBorderColor: wheelBorderColor ?? this.wheelBorderColor,
      segmentBorderColor: segmentBorderColor ?? this.segmentBorderColor,
      wheelShadowColor: wheelShadowColor ?? this.wheelShadowColor,
      resultTextColor: resultTextColor ?? this.resultTextColor,
      spinButtonColor: spinButtonColor ?? this.spinButtonColor,
    );
  }

  @override
  SpinnerThemeExtension lerp(SpinnerThemeExtension? other, double t) {
    if (other is! SpinnerThemeExtension) {
      return this;
    }
    return SpinnerThemeExtension(
      wheelBackgroundColor: Color.lerp(
        wheelBackgroundColor,
        other.wheelBackgroundColor,
        t,
      )!,
      wheelBorderColor: Color.lerp(
        wheelBorderColor,
        other.wheelBorderColor,
        t,
      )!,
      segmentBorderColor: Color.lerp(
        segmentBorderColor,
        other.segmentBorderColor,
        t,
      )!,
      wheelShadowColor: Color.lerp(
        wheelShadowColor,
        other.wheelShadowColor,
        t,
      )!,
      resultTextColor: Color.lerp(resultTextColor, other.resultTextColor, t)!,
      spinButtonColor: Color.lerp(spinButtonColor, other.spinButtonColor, t)!,
    );
  }

  static SpinnerThemeExtension light = SpinnerThemeExtension(
    wheelBackgroundColor: Colors.white,
    wheelBorderColor: Colors.deepPurple,
    segmentBorderColor: Colors.white,
    wheelShadowColor: Colors.grey.withValues(alpha: 0.3),
    resultTextColor: Colors.deepPurple[800]!,
    spinButtonColor: Colors.deepPurple,
  );

  static SpinnerThemeExtension dark = SpinnerThemeExtension(
    wheelBackgroundColor: Colors.grey[800]!,
    wheelBorderColor: Colors.deepPurple[300]!,
    segmentBorderColor: Colors.grey[900]!,
    wheelShadowColor: Colors.black.withValues(alpha: 0.5),
    resultTextColor: Colors.deepPurple[200]!,
    spinButtonColor: Colors.deepPurple[400]!,
  );
}

@immutable
class CustomButtonExtension extends ThemeExtension<CustomButtonExtension> {
  const CustomButtonExtension({
    required this.actionButtonStyle,
    required this.dangerButtonStyle,
    required this.successButtonStyle,
  });

  final ButtonStyle actionButtonStyle;
  final ButtonStyle dangerButtonStyle;
  final ButtonStyle successButtonStyle;

  @override
  CustomButtonExtension copyWith({
    ButtonStyle? actionButtonStyle,
    ButtonStyle? dangerButtonStyle,
    ButtonStyle? successButtonStyle,
  }) {
    return CustomButtonExtension(
      actionButtonStyle: actionButtonStyle ?? this.actionButtonStyle,
      dangerButtonStyle: dangerButtonStyle ?? this.dangerButtonStyle,
      successButtonStyle: successButtonStyle ?? this.successButtonStyle,
    );
  }

  @override
  CustomButtonExtension lerp(CustomButtonExtension? other, double t) {
    if (other is! CustomButtonExtension) {
      return this;
    }
    return CustomButtonExtension(
      actionButtonStyle: ButtonStyle.lerp(
        actionButtonStyle,
        other.actionButtonStyle,
        t,
      )!,
      dangerButtonStyle: ButtonStyle.lerp(
        dangerButtonStyle,
        other.dangerButtonStyle,
        t,
      )!,
      successButtonStyle: ButtonStyle.lerp(
        successButtonStyle,
        other.successButtonStyle,
        t,
      )!,
    );
  }

  static CustomButtonExtension light = CustomButtonExtension(
    actionButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dangerButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      foregroundColor: Colors.red,
      elevation: 0,
    ),
    successButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.withValues(alpha: 0.1),
      foregroundColor: Colors.green,
      elevation: 0,
    ),
  );

  static CustomButtonExtension dark = light; // Can be customized differently
}

// Animation and spacing constants
@immutable
class AppConstants extends ThemeExtension<AppConstants> {
  const AppConstants({
    required this.fastDuration,
    required this.normalDuration,
    required this.slowDuration,
    required this.standardCurve,
    required this.emphasizedCurve,
    required this.smallSpacing,
    required this.mediumSpacing,
    required this.largeSpacing,
  });

  final Duration fastDuration;
  final Duration normalDuration;
  final Duration slowDuration;
  final Curve standardCurve;
  final Curve emphasizedCurve;
  final double smallSpacing;
  final double mediumSpacing;
  final double largeSpacing;

  @override
  AppConstants copyWith({
    Duration? fastDuration,
    Duration? normalDuration,
    Duration? slowDuration,
    Curve? standardCurve,
    Curve? emphasizedCurve,
    double? smallSpacing,
    double? mediumSpacing,
    double? largeSpacing,
  }) {
    return AppConstants(
      fastDuration: fastDuration ?? this.fastDuration,
      normalDuration: normalDuration ?? this.normalDuration,
      slowDuration: slowDuration ?? this.slowDuration,
      standardCurve: standardCurve ?? this.standardCurve,
      emphasizedCurve: emphasizedCurve ?? this.emphasizedCurve,
      smallSpacing: smallSpacing ?? this.smallSpacing,
      mediumSpacing: mediumSpacing ?? this.mediumSpacing,
      largeSpacing: largeSpacing ?? this.largeSpacing,
    );
  }

  @override
  AppConstants lerp(AppConstants? other, double t) {
    if (other is! AppConstants) {
      return this;
    }
    return AppConstants(
      fastDuration: Duration(
        milliseconds:
            (fastDuration.inMilliseconds * (1 - t) +
                    other.fastDuration.inMilliseconds * t)
                .round(),
      ),
      normalDuration: Duration(
        milliseconds:
            (normalDuration.inMilliseconds * (1 - t) +
                    other.normalDuration.inMilliseconds * t)
                .round(),
      ),
      slowDuration: Duration(
        milliseconds:
            (slowDuration.inMilliseconds * (1 - t) +
                    other.slowDuration.inMilliseconds * t)
                .round(),
      ),
      standardCurve: standardCurve,
      emphasizedCurve: emphasizedCurve,
      smallSpacing: smallSpacing * (1 - t) + other.smallSpacing * t,
      mediumSpacing: mediumSpacing * (1 - t) + other.mediumSpacing * t,
      largeSpacing: largeSpacing * (1 - t) + other.largeSpacing * t,
    );
  }

  static AppConstants standard = AppConstants(
    fastDuration: Duration(milliseconds: 150),
    normalDuration: Duration(milliseconds: 300),
    slowDuration: Duration(milliseconds: 500),
    standardCurve: Curves.easeInOut,
    emphasizedCurve: Curves.easeInOutCubic,
    smallSpacing: 8.0,
    mediumSpacing: 16.0,
    largeSpacing: 24.0,
  );
}
