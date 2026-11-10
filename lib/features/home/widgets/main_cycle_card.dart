import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/cycle_prediction.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';

class MainCycleCard extends StatelessWidget {
  const MainCycleCard({
    super.key,
    required this.prediction,
    required this.onLogPeriodTap,
  });

  final CyclePrediction prediction;
  final VoidCallback onLogPeriodTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();
    final tr = context.watch<LocaleProvider>().tr;

    if (!prediction.hasData) {
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_rounded,
                size: 32,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('Start your cycle journey.', 'Mulai perjalanan siklus Anda.'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'Track your period in one tap and discover your personal cycle patterns over time.',
                'Catat haid Anda dalam satu ketukan dan kenali pola siklus pribadi Anda.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onLogPeriodTap,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(tr('Record First Period', 'Catat Haid Pertama')),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  tr('YOUR CYCLE', 'SIKLUS ANDA'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColors?.badgeBackground ?? colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        prediction.isPeriodOngoing
                            ? Icons.water_drop_rounded
                            : Icons.eco_rounded,
                        size: 14,
                        color: themeColors?.badgeText ?? colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          prediction.phase.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: themeColors?.badgeText ?? colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Circular progress ring with cycle day
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 164,
                height: 164,
                child: CircularProgressIndicator(
                  value: prediction.cycleProgress,
                  strokeWidth: 11,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Day',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${prediction.cycleDay}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    'of ${prediction.estimatedCycleLength}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Estimated status sentence
          Text(
            _buildStatusText(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          if (prediction.nextPeriodDate != null)
            Text(
              'Estimated next period: ${AppDateUtils.formatDisplay(prediction.nextPeriodDate!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 14),

          // Historical confidence note
          if (!prediction.isUsingHistoricalAverage)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Using configured baseline. Predictions improve as you track more cycles.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _buildStatusText() {
    if (prediction.isPeriodOngoing) {
      return 'Period in progress (Day ${prediction.ongoingDurationDays})';
    }
    if (prediction.daysUntilNextPeriod > 1) {
      return 'Your next period is estimated in ${prediction.daysUntilNextPeriod} days.';
    }
    if (prediction.daysUntilNextPeriod == 1) {
      return 'Your next period is estimated tomorrow.';
    }
    if (prediction.daysUntilNextPeriod == 0) {
      return 'Your period is estimated to start today.';
    }
    return 'Your period is ${prediction.daysUntilNextPeriod.abs()} days past the estimated date.';
  }
}
