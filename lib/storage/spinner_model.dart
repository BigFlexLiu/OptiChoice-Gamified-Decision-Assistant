import 'package:decision_spinner/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SpinnerModel {
  String id; // Unique identifier
  String name;
  List<SpinnerOption> options;
  int colorThemeIndex;
  List<Color> _backgroundColors;
  List<Color> customBackgroundColors;
  List<Color> foregroundColors;
  String? spinSound;
  String? spinEndSound;
  Duration spinDuration;
  DateTime createdAt;
  DateTime updatedAt;
  SpinnerModel({
    required this.name,
    required this.options,
    required this.colorThemeIndex,
    required List<Color> backgroundColors,
    List<Color>? customColors,
    List<Color>? foregroundColors,
    String? spinSound,
    String? spinEndSound,
    Duration? spinDuration,
    String? newId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       spinDuration = spinDuration ?? const Duration(seconds: 2),
       _backgroundColors = backgroundColors,
       customBackgroundColors =
           customColors ?? [Colors.red, Colors.green, Colors.blue],
       foregroundColors =
           foregroundColors ??
           backgroundColors
               .map((color) => ColorUtils.bestFgColorForBg(color))
               .toList(),
       spinSound = spinSound ?? "pen_tick",
       spinEndSound = spinEndSound ?? 'tada_end',
       id = newId ?? _uuid.v4();

  // Getter and setter for backgroundColors
  List<Color> get backgroundColors => _backgroundColors;

  set backgroundColors(List<Color> colors) {
    _backgroundColors = colors;
    foregroundColors = colors
        .map((color) => ColorUtils.bestFgColorForBg(color))
        .toList();
    updatedAt = DateTime.now();
  }

  // Blend the color of the last idx item
  Color getCircularBackgroundColor(int idx) {
    if (shouldUseBlendedColorAtIdx(idx)) {
      return blendedBackgroundColor;
    }
    return backgroundColors[idx % backgroundColors.length];
  }

  // Get foreground color for the given index
  Color getCircularForegroundColor(int idx) {
    return foregroundColors[idx % foregroundColors.length];
  }

  bool shouldUseBlendedColorAtIdx(int idx) {
    int lastIdx = activeOptions.length - 1;
    if (idx != lastIdx) {
      return false;
    }
    int lastColorIndex = lastIdx % backgroundColors.length;

    return 0 == lastColorIndex;
  }

  Color get blendedBackgroundColor => blend(
    backgroundColors[0],
    backgroundColors[(options.length - 2) % backgroundColors.length],
  );

  Color blend(Color a, Color b, {double t = 0.5}) {
    return Color.fromARGB(
      (a.alpha * (1 - t) + b.alpha * t).round(),
      (a.red * (1 - t) + b.red * t).round(),
      (a.green * (1 - t) + b.green * t).round(),
      (a.blue * (1 - t) + b.blue * t).round(),
    );
  }

  // Get only enabled options
  List<SpinnerOption> get activeOptions =>
      options.where((option) => option.isActive).toList();

  // Get only enabled options
  List<SpinnerOption> get inactiveOptions =>
      options.where((option) => !option.isActive).toList();

  // Get the count of enabled options
  int get activeOptionsCount =>
      options.where((option) => option.isActive).length;

  // Toggle the enabled state of an option
  void toggleOptionIsActive(SpinnerOption option) {
    option.isActive = !option.isActive;
    updatedAt = DateTime.now();
  }

  // Enable or disable all options
  void setAllOptionsActive() {
    for (var option in options) {
      option.isActive = true;
    }
    updatedAt = DateTime.now();
  }

  static const _uuid = Uuid();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options
          .map(
            (option) => {
              'text': option.text,
              'weight': option.weight,
              'isActive': option.isActive,
            },
          )
          .toList(),
      'colorThemeIndex': colorThemeIndex,
      'colors': backgroundColors.map((color) => color.toARGB32()).toList(),
      'customColors': customBackgroundColors
          .map((color) => color.toARGB32())
          .toList(),
      'foregroundColors': foregroundColors
          .map((color) => color.toARGB32())
          .toList(),
      'spinSound': spinSound,
      'spinEndSound': spinEndSound,
      'spinDuration': spinDuration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static SpinnerModel fromJson(Map<String, dynamic> json) {
    return SpinnerModel(
      newId: json['id'],
      name: json['name'],
      options: (json['options'] as List)
          .map(
            (option) => SpinnerOption(
              text: option['text'],
              weight: option['weight'],
              isActive: option['isActive'] ?? true,
            ),
          )
          .toList(),
      colorThemeIndex: json['colorThemeIndex'],
      backgroundColors: (json['colors'] as List)
          .map((colorValue) => Color(colorValue as int))
          .toList(),
      customColors: json['customColors'] != null
          ? (json['customColors'] as List)
                .map((colorValue) => Color(colorValue as int))
                .toList()
          : null,
      foregroundColors: json['foregroundColors'] != null
          ? (json['foregroundColors'] as List)
                .map((colorValue) => Color(colorValue as int))
                .toList()
          : null,
      spinSound: json['spinSound'],
      spinEndSound: json['spinEndSound'],
      spinDuration: Duration(milliseconds: json['spinDuration'] ?? 3000),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Create a duplicate with a new ID and updated timestamps
  static SpinnerModel duplicate(
    SpinnerModel original, {
    String? newId,
    String? newName,
  }) {
    return SpinnerModel(
      newId: newId,
      name: newName ?? '${original.name} (Copy)',
      options: original.options
          .map(
            (option) => SpinnerOption(
              text: option.text,
              weight: option.weight,
              isActive: option.isActive,
            ),
          )
          .toList(),
      colorThemeIndex: original.colorThemeIndex,
      backgroundColors: List<Color>.from(original.backgroundColors),
      customColors: List<Color>.from(original.customBackgroundColors),
      foregroundColors: List<Color>.from(original.foregroundColors),
      spinSound: original.spinSound,
      spinEndSound: original.spinEndSound,
      spinDuration: original.spinDuration,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void copy(SpinnerModel other) {
    name = other.name;
    options = other.options;
    colorThemeIndex = other.colorThemeIndex;
    backgroundColors = other.backgroundColors;
    customBackgroundColors = other.customBackgroundColors;
    foregroundColors = other.foregroundColors;
    spinSound = other.spinSound;
    spinEndSound = other.spinEndSound;
    spinDuration = other.spinDuration;
    updatedAt = other.updatedAt;
  }

  @override
  String toString() {
    return 'SpinnerModel('
        'id: $id, '
        'name: $name, '
        'options: [${options.length} items], '
        'colorThemeIndex: $colorThemeIndex, '
        'colors: [${backgroundColors.length} colors], '
        'foregroundColors: [${foregroundColors.length} colors], '
        'spinSound: ${spinSound ?? "null"}, '
        'spinEndSound: ${spinEndSound ?? "null"}, '
        'spinDuration: ${spinDuration.inMilliseconds}ms, '
        'createdAt: ${createdAt.toIso8601String()}, '
        'updatedAt: ${updatedAt.toIso8601String()})';
  }
}

class SpinnerOption {
  String text;
  double weight;
  bool isActive;

  SpinnerOption({required this.text, this.weight = 1.0, this.isActive = true});
}
