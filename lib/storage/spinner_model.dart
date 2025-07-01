import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SpinnerModel {
  String id; // Unique identifier
  String name;
  List<SpinnerOption> options;
  int colorThemeIndex;
  List<Color> colors;
  List<Color> customColors;
  String? spinSound;
  String? spinEndSound;
  Duration spinDuration;
  DateTime createdAt;
  DateTime updatedAt;
  SpinnerModel({
    required this.name,
    required this.options,
    required this.colorThemeIndex,
    required this.colors,
    List<Color>? customColors,
    String? spinSound,
    String? spinEndSound,
    Duration? spinDuration,
    String? newId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       spinDuration = spinDuration ?? const Duration(seconds: 2),
       customColors = customColors ?? [Colors.red, Colors.green, Colors.blue],
       spinSound = spinSound ?? "pen_tick",
       spinEndSound = spinEndSound ?? 'tada_end',
       id = newId ?? _uuid.v4();

  // Blend the color of the last idx item
  Color getCircularColor(int idx) {
    if (shouldUseBlendedColorAtIdx(idx)) {
      return blendedColor;
    }
    return colors[idx % colors.length];
  }

  Color getCircularColorOfOption(SpinnerOption option) {
    final optionIdx = options.indexOf(option);
    if (optionIdx == -1) {
      return colors.first;
    }
    return getCircularColor(optionIdx);
  }

  bool shouldUseBlendedColorAtIdx(int idx) {
    int lastIdx = options.length - 1;
    if (idx != lastIdx) {
      return false;
    }
    int lastColorIndex = lastIdx % colors.length;

    return 0 == lastColorIndex;
  }

  Color get blendedColor =>
      blend(colors[0], colors[(options.length - 2) % colors.length]);

  Color blend(Color a, Color b, {double t = 0.5}) {
    return Color.fromARGB(
      (a.alpha * (1 - t) + b.alpha * t).round(),
      (a.red * (1 - t) + b.red * t).round(),
      (a.green * (1 - t) + b.green * t).round(),
      (a.blue * (1 - t) + b.blue * t).round(),
    );
  }

  static const _uuid = Uuid();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options
          .map((option) => {'text': option.text, 'weight': option.weight})
          .toList(),
      'colorThemeIndex': colorThemeIndex,
      'colors': colors.map((color) => color.toARGB32()).toList(),
      'customColors': customColors.map((color) => color.toARGB32()).toList(),
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
            (option) =>
                SpinnerOption(text: option['text'], weight: option['weight']),
          )
          .toList(),
      colorThemeIndex: json['colorThemeIndex'],
      colors: (json['colors'] as List)
          .map((colorValue) => Color(colorValue as int))
          .toList(),
      customColors: json['customColors'] != null
          ? (json['customColors'] as List)
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
            (option) => SpinnerOption(text: option.text, weight: option.weight),
          )
          .toList(),
      colorThemeIndex: original.colorThemeIndex,
      colors: List<Color>.from(original.colors),
      customColors: List<Color>.from(original.customColors),
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
    colors = other.colors;
    customColors = other.customColors;
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
        'colors: [${colors.length} colors], '
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

  SpinnerOption({required this.text, this.weight = 1.0});
}
