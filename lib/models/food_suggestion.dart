import 'package:flutter/material.dart';

enum FoodCategory {
  crampRelief('Cramp Relief', 'Relaxes uterine muscles & eases tension', Icons.spa_outlined),
  ironEnergy('Iron & Energy', 'Replenishes lost minerals & combats fatigue', Icons.bolt_outlined),
  moodComfort('Mood & Comfort', 'Promotes serotonin & eases PMS stress', Icons.favorite_border_rounded),
  antiBloat('Anti-Bloat & Gut', 'Reduces water retention & soothes digestion', Icons.water_drop_outlined);

  const FoodCategory(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final IconData icon;
}

class FoodDish {
  const FoodDish({
    required this.name,
    required this.type,
    required this.description,
    this.quickTip,
    this.safeSubstitute,
  });

  final String name;
  final String type; // e.g. "Warm Snack", "Cozy Meal", "Sweet Treat", "Soothing Drink"
  final String description;
  final String? quickTip;
  final String? safeSubstitute;
}

class FoodSuggestion {
  const FoodSuggestion({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.keyNutrient,
    required this.benefit,
    required this.whyItHelpsOnRedDays,
    required this.clinicalSource,
    required this.clinicalEvidence,
    required this.scientificReference,
    required this.allergenTags,
    required this.cravingTags,
    required this.dishes,
  });

  final String id;
  final String name;
  final IconData icon;
  final FoodCategory category;
  final String keyNutrient;
  final String benefit;
  final String whyItHelpsOnRedDays;
  final String clinicalSource; // e.g., 'WHO Guideline', 'PubMed / Cochrane Review', 'ACOG'
  final String clinicalEvidence; // Concise summary of published medical findings
  final String scientificReference; // Journal publication citation or official organization report
  final List<String> allergenTags; // 'dairy', 'nuts', 'seafood', 'gluten', 'eggs', 'soy'
  final List<String> cravingTags;  // 'chocolate', 'tea', 'berries', 'oats', 'healthy_fats', 'pasta_rice'
  final List<FoodDish> dishes;

  bool hasAllergen(List<String> userAllergies) {
    if (userAllergies.isEmpty) return false;
    final lowerUser = userAllergies.map((a) => a.toLowerCase().trim()).toSet();
    return allergenTags.any((a) => lowerUser.contains(a.toLowerCase()));
  }

  bool matchesCravings(List<String> userCravings) {
    if (userCravings.isEmpty) return false;
    final lowerUser = userCravings.map((c) => c.toLowerCase().trim()).toSet();
    return cravingTags.any((t) => lowerUser.contains(t.toLowerCase()));
  }
}
