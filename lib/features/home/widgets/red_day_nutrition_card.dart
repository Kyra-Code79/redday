import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cycle_prediction.dart';
import '../../../providers/locale_provider.dart';
import '../../../repositories/nutrition_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../nutrition/nutrition_screen.dart';

class RedDayNutritionCard extends StatelessWidget {
  const RedDayNutritionCard({
    super.key,
    required this.prediction,
    required this.userAllergies,
    required this.userCravings,
  });

  final CyclePrediction prediction;
  final List<String> userAllergies;
  final List<String> userCravings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = context.watch<LocaleProvider>().tr;

    // Pick top recommendation matching cravings & safe for allergies
    final suggestions = NutritionRepository.getFilteredSuggestions(
      userAllergies: userAllergies,
      userCravings: userCravings,
      safeOnly: false,
    );

    if (suggestions.isEmpty) return const SizedBox.shrink();

    final topItem = suggestions.first;
    final topDish = topItem.dishes.first;

    final isMenstrual =
        prediction.phase == CyclePhase.menstrual || prediction.isPeriodOngoing;
    final isLuteal = prediction.phase == CyclePhase.luteal;

    String cardHeader;
    String tipSubtitle;

    if (isMenstrual) {
      cardHeader = tr('Red Day Comfort Food', 'Makanan Nyaman Saat Haid');
      tipSubtitle = tr(
        'Nourish your body & soothe uterine cramps today',
        'Nutrisi tubuh & redakan kram rahim hari ini',
      );
    } else if (isLuteal) {
      cardHeader = tr('Pre-Period Nutrient Support', 'Dukungan Nutrisi Pra-Haid');
      tipSubtitle = tr(
        'Magnesium, calcium & slow carbs to balance PMS cravings',
        'Magnesium, kalsium & karbohidrat kompleks penyeimbang PMS',
      );
    } else {
      cardHeader = tr('Cycle Nutrition & Snacks', 'Nutrisi & Camilan Siklus');
      tipSubtitle = tr(
        'Whole foods tailored for hormonal balance',
        'Makanan utuh untuk keseimbangan hormon',
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cardHeader,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const NutritionScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tipSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Featured Dish Preview Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outline, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    topItem.icon,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topDish.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topItem.name} ➔ ${topDish.type}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topDish.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const NutritionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Explore all food & treat suggestions'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
