import 'package:decision_spin/views/roulette_options_view.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RouletteModel {
  String id; // Unique identifier
  String name;
  List<RouletteOption> options;
  int colorThemeIndex;
  List<Color> colors;
  DateTime createdAt;
  DateTime updatedAt;

  RouletteModel({
    required this.name,
    required this.options,
    required this.colorThemeIndex,
    required this.colors,
    String? newId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RouletteModel fromJson(Map<String, dynamic> json) {
    return RouletteModel(
      newId: json['id'],
      name: json['name'],
      options: (json['options'] as List)
          .map(
            (option) =>
                RouletteOption(text: option['text'], weight: option['weight']),
          )
          .toList(),
      colorThemeIndex: json['colorThemeIndex'],
      colors: (json['colors'] as List)
          .map((colorValue) => Color(colorValue as int))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Create a duplicate with a new ID and updated timestamps
  static RouletteModel duplicate(
    RouletteModel original, {
    String? newId,
    String? newName,
  }) {
    return RouletteModel(
      name: newName ?? '${original.name} (Copy)',
      options: original.options
          .map(
            (option) =>
                RouletteOption(text: option.text, weight: option.weight),
          )
          .toList(),
      colorThemeIndex: original.colorThemeIndex,
      colors: List<Color>.from(original.colors),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
