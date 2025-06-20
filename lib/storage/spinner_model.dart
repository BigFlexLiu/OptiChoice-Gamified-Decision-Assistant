import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SpinnerModel {
  String id; // Unique identifier
  String name;
  List<SpinnerOption> options;
  int colorThemeIndex;
  List<Color> colors;
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
    this.spinSound,
    this.spinEndSound,
    Duration? spinDuration,
    String? newId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       spinDuration = spinDuration ?? const Duration(seconds: 3),
       id = newId ?? _uuid.v4();

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
    spinSound = other.spinSound;
    spinEndSound = other.spinEndSound;
    spinDuration = other.spinDuration;
    updatedAt = other.updatedAt;
  }
}

class SpinnerOption {
  String text;
  double weight;

  SpinnerOption({required this.text, this.weight = 1.0});
}
