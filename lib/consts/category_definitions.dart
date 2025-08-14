import 'package:decision_spinner/consts/spinner_template_definitions.dart';
import 'package:decision_spinner/storage/spinner_model.dart';
import 'package:flutter/material.dart';

/// Shared category definition used across the app for consistency
class CategoryDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<SpinnerModel> spinnerTemplates;

  const CategoryDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.spinnerTemplates,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Central repository of all category definitions
class CategoryDefinitions {
  static final List<CategoryDefinition> allCategories = [
    lifeAndHome,
    healthAndSelfCare,
    funAndSocial,
    productivityAndWork,
    teachingAndClassroom,
    // gamesAndChallenges,
  ];

  static final CategoryDefinition lifeAndHome = CategoryDefinition(
    id: 'lifeAndHome',
    title: 'Life & Home',
    description: 'Daily living and household decisions',
    icon: Icons.home,
    color: const Color(0xFF4CAF50),
    spinnerTemplates: SpinnerTemplateDefinitions.lifeAndHome,
  );

  static final CategoryDefinition healthAndSelfCare = CategoryDefinition(
    id: 'healthAndSelfCare',
    title: 'Health & Self-Care',
    description: 'Personal wellness and physical activity',
    icon: Icons.favorite,
    color: const Color(0xFFE91E63),
    spinnerTemplates: SpinnerTemplateDefinitions.healthAndSelfCare,
  );

  static final CategoryDefinition funAndSocial = CategoryDefinition(
    id: 'funAndSocial',
    title: 'Fun & Social',
    description: 'Entertainment and group activities',
    icon: Icons.celebration,
    color: const Color(0xFFFF9800),
    spinnerTemplates: SpinnerTemplateDefinitions.funAndSocial,
  );

  static final CategoryDefinition productivityAndWork = CategoryDefinition(
    id: 'productivityAndWork',
    title: 'Productivity & Work',
    description: 'Focus, learning, and skill-building',
    icon: Icons.work,
    color: const Color(0xFF3F51B5),
    spinnerTemplates: SpinnerTemplateDefinitions.productivityAndWork,
  );

  static final CategoryDefinition teachingAndClassroom = CategoryDefinition(
    id: 'teachingAndClassroom',
    title: 'Teaching & Classroom',
    description: 'Educational tools and activities',
    icon: Icons.school,
    color: const Color(0xFF9C27B0),
    spinnerTemplates: SpinnerTemplateDefinitions.teachingAndClassroom,
  );

  static final CategoryDefinition gamesAndChallenges = CategoryDefinition(
    id: 'gamesAndChallenges',
    title: 'Games & Challenges',
    description: 'Gamification and light competition',
    icon: Icons.games,
    color: const Color(0xFF009688),
    spinnerTemplates: SpinnerTemplateDefinitions.gamesAndChallenges,
  );

  /// Map for quick lookups by category ID
  static final Map<String, CategoryDefinition> categoryMap = {
    for (var cat in allCategories) cat.id: cat,
  };
}
