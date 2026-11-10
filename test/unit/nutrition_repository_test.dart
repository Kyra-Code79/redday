import 'package:flutter_test/flutter_test.dart';
import 'package:redday/models/food_suggestion.dart';
import 'package:redday/repositories/nutrition_repository.dart';

void main() {
  group('NutritionRepository Tests', () {
    test('Contains curated list of nutrition recommendations with dishes', () {
      const all = NutritionRepository.allSuggestions;
      expect(all.length, greaterThanOrEqualTo(10));

      for (final item in all) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.name.isNotEmpty, isTrue);
        expect(item.keyNutrient.isNotEmpty, isTrue);
        expect(item.benefit.isNotEmpty, isTrue);
        expect(item.whyItHelpsOnRedDays.isNotEmpty, isTrue);
        expect(item.clinicalSource.isNotEmpty, isTrue);
        expect(item.clinicalEvidence.isNotEmpty, isTrue);
        expect(item.scientificReference.isNotEmpty, isTrue);
        expect(item.dishes.isNotEmpty, isTrue);

        for (final dish in item.dishes) {
          expect(dish.name.isNotEmpty, isTrue);
          expect(dish.type.isNotEmpty, isTrue);
          expect(dish.description.isNotEmpty, isTrue);
        }
      }
    });

    test('Contains trusted health authority references (WHO, PubMed, ACOG, Mayo Clinic)', () {
      const all = NutritionRepository.allSuggestions;

      final whoItems = all.where((i) => i.clinicalSource.contains('WHO'));
      expect(whoItems.isNotEmpty, isTrue, reason: 'Must contain WHO-backed recommendations');

      final pubmedItems = all.where((i) => i.clinicalSource.contains('PubMed'));
      expect(pubmedItems.isNotEmpty, isTrue, reason: 'Must contain peer-reviewed PubMed citations');

      final acogItems = all.where((i) => i.clinicalSource.contains('ACOG'));
      expect(acogItems.isNotEmpty, isTrue, reason: 'Must contain ACOG clinical consensus');

      // Verify WHO-approved Cheese entry exists with calcium & low-sodium clinical guidance
      final cheeseItem = all.where((i) => i.id == 'cheese_calcium');
      expect(cheeseItem.isNotEmpty, isTrue, reason: 'Must contain WHO-approved Cheese food');
      expect(cheeseItem.first.clinicalSource.contains('WHO'), isTrue);
      expect(cheeseItem.first.allergenTags.contains('dairy'), isTrue);
    });

    test('Filters by Category correctly', () {
      final crampItems = NutritionRepository.getFilteredSuggestions(
        category: FoodCategory.crampRelief,
      );
      expect(crampItems.isNotEmpty, isTrue);
      expect(crampItems.every((i) => i.category == FoodCategory.crampRelief), isTrue);
    });

    test('Searches by raw component name and dish name', () {
      // Search by component
      final chocolateResults = NutritionRepository.getFilteredSuggestions(
        searchQuery: 'chocolate',
      );
      expect(chocolateResults.isNotEmpty, isTrue);
      expect(chocolateResults.first.id, equals('dark_chocolate'));

      // Search by dish
      final cakeResults = NutritionRepository.getFilteredSuggestions(
        searchQuery: 'Mug Cake',
      );
      expect(cakeResults.isNotEmpty, isTrue);
      expect(cakeResults.first.id, equals('dark_chocolate'));

      final gingerResults = NutritionRepository.getFilteredSuggestions(
        searchQuery: 'ginger',
      );
      expect(gingerResults.isNotEmpty, isTrue);
      expect(gingerResults.first.id, equals('fresh_ginger'));
    });

    test('Filters allergens when safeOnly is true', () {
      // Dark chocolate contains dairy
      final withAllergyUnfiltered = NutritionRepository.getFilteredSuggestions(
        userAllergies: ['dairy'],
        safeOnly: false,
      );
      expect(withAllergyUnfiltered.any((i) => i.id == 'dark_chocolate'), isTrue);

      final withAllergySafeOnly = NutritionRepository.getFilteredSuggestions(
        userAllergies: ['dairy'],
        safeOnly: true,
      );
      expect(withAllergySafeOnly.any((i) => i.id == 'dark_chocolate'), isFalse);
    });

    test('Prioritizes craved comfort food to top of list', () {
      final cravedChocolate = NutritionRepository.getFilteredSuggestions(
        userCravings: ['chocolate'],
      );
      expect(cravedChocolate.first.id, equals('dark_chocolate'));

      final cravedTea = NutritionRepository.getFilteredSuggestions(
        userCravings: ['tea'],
      );
      expect(cravedTea.first.cravingTags.contains('tea'), isTrue);
    });
  });
}
