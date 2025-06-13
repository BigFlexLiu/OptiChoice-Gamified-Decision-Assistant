import 'package:decision_spin/views/roulette_manager.dart';
import 'package:flutter/material.dart';
import '../enums/roulette_paint_mode.dart';

class RouletteWheelModel {
  String id; // Unique identifier
  String name;
  List<RouletteOption> options;
  int colorThemeIndex;
  List<List<Color>> gradientColors;
  List<Color> solidColors;
  RoulettePaintMode paintMode;
  DateTime createdAt;
  DateTime updatedAt;

  RouletteWheelModel({
    required this.id,
    required this.name,
    required this.options,
    required this.colorThemeIndex,
    required this.gradientColors,
    required this.solidColors,
    this.paintMode = RoulettePaintMode.gradient,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options
          .map((option) => {'text': option.text, 'weight': option.weight})
          .toList(),
      'colorThemeIndex': colorThemeIndex,
      'gradientColors': gradientColors
          .map(
            (colorList) => colorList.map((color) => color.toARGB32()).toList(),
          )
          .toList(),
      'solidColors': solidColors.map((color) => color.toARGB32()).toList(),
      'paintMode': paintMode.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RouletteWheelModel fromJson(Map<String, dynamic> json) {
    return RouletteWheelModel(
      id: json['id'],
      name: json['name'],
      options: (json['options'] as List)
          .map(
            (option) =>
                RouletteOption(text: option['text'], weight: option['weight']),
          )
          .toList(),
      colorThemeIndex: json['colorThemeIndex'],
      gradientColors: (json['gradientColors'] as List)
          .map(
            (colorList) => (colorList as List)
                .map((colorValue) => Color(colorValue as int))
                .toList(),
          )
          .toList(),
      solidColors: (json['solidColors'] as List)
          .map((colorValue) => Color(colorValue as int))
          .toList(),
      paintMode: RoulettePaintMode.values[json['paintMode']],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
