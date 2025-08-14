import 'package:decision_spinner/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SpinnerModel {
  String id; // Unique identifier
  String name;
  List<Slice> slices;
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
    required this.slices,
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
    int lastIdx = activeSlices.length - 1;
    if (idx != lastIdx) {
      return false;
    }
    int lastColorIndex = lastIdx % backgroundColors.length;

    return 0 == lastColorIndex;
  }

  Color get blendedBackgroundColor =>
      blend(backgroundColors[0], backgroundColors[1]);

  Color blend(Color a, Color b, {double t = 0.5}) {
    return Color.fromARGB(
      ((a.a * (1 - t) + b.a * t) * 255).round(),
      ((a.r * (1 - t) + b.r * t) * 255).round(),
      ((a.g * (1 - t) + b.g * t) * 255).round(),
      ((a.b * (1 - t) + b.b * t) * 255).round(),
    );
  }

  List<Slice> get activeSlices =>
      slices.where((option) => option.isActive).toList();

  List<Slice> get inactiveSlices =>
      slices.where((option) => !option.isActive).toList();

  int get activeSlicesCount => slices.where((option) => option.isActive).length;

  void toggleSliceIsActive(Slice option) {
    option.isActive = !option.isActive;
    updatedAt = DateTime.now();
  }

  void setAllSlicesActive() {
    for (var option in slices) {
      option.isActive = true;
    }
    updatedAt = DateTime.now();
  }

  static const _uuid = Uuid();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slices': slices
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
      slices: (json['slices'] as List)
          .map(
            (option) => Slice(
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
      slices: original.slices
          .map(
            (option) => Slice(
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
    slices = other.slices;
    colorThemeIndex = other.colorThemeIndex;
    backgroundColors = other.backgroundColors;
    customBackgroundColors = other.customBackgroundColors;
    foregroundColors = other.foregroundColors;
    spinSound = other.spinSound;
    spinEndSound = other.spinEndSound;
    spinDuration = other.spinDuration;
    updatedAt = other.updatedAt;
  }

  /// Check if this spinner has identical content to another spinner
  bool isContentIdenticalTo(SpinnerModel other) {
    if (slices.length != other.slices.length) return false;
    for (int i = 0; i < slices.length; i++) {
      final thisSlice = slices[i];
      final otherSlice = other.slices[i];
      if (thisSlice.text != otherSlice.text ||
          thisSlice.weight != otherSlice.weight ||
          thisSlice.isActive != otherSlice.isActive) {
        return false;
      }
    }
    if (colorThemeIndex != other.colorThemeIndex ||
        backgroundColors.length != other.backgroundColors.length) {
      return false;
    }
    for (int i = 0; i < backgroundColors.length; i++) {
      if (backgroundColors[i] != other.backgroundColors[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return 'SpinnerModel('
        'id: $id, '
        'name: $name, '
        'slices: [${slices.length} items], '
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

class Slice {
  String text;
  double weight;
  bool isActive;

  Slice({required this.text, this.weight = 1.0, this.isActive = true});
}
