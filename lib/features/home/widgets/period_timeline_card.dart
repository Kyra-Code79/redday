import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/cycle_prediction.dart';
import '../../../models/period.dart';
import '../../../shared/widgets/app_card.dart';

class PeriodTimelineCard extends StatelessWidget {
  const PeriodTimelineCard({
    super.key,
    required this.prediction,
    required this.latestPeriod,
  });

  final CyclePrediction prediction;
  final Period? latestPeriod;

  @override
  Widget build(BuildContext context) {
    if (!prediction.hasData) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();

    // Generate 7 days centered on today (-2 to +4)
    final today = AppDateUtils.today;
    final days = List.generate(7, (i) => today.add(Duration(days: i - 2)));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Timeline',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '7-Day Glance',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal row of day cells
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = AppDateUtils.isSameDay(day, today);
              final isRecorded =
                  latestPeriod != null && latestPeriod!.containsDate(day);
              final isPredicted = prediction.isDateInPredictedPeriod(day);
              final isFertile = prediction.isDateInFertileWindow(day);

              Color bgColor;
              Color textColor;
              Border? border;
              IconData? icon;

              if (isRecorded) {
                bgColor = themeColors?.periodDay ?? colorScheme.primary;
                textColor = themeColors?.periodDayText ?? colorScheme.onPrimary;
                icon = Icons.water_drop_rounded;
              } else if (isPredicted) {
                bgColor = themeColors?.predictedPeriodDay ?? colorScheme.surface;
                textColor = themeColors?.predictedPeriodText ?? colorScheme.onSurface;
                border = Border.all(
                  color: themeColors?.predictedPeriodDayBorder ??
                      colorScheme.primary,
                  width: 1.5,
                );
                icon = Icons.water_drop_outlined;
              } else if (isFertile) {
                bgColor = themeColors?.fertileDay ?? colorScheme.surface;
                textColor = themeColors?.fertileDayText ?? colorScheme.onSurface;
                border = Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                );
                icon = Icons.eco_rounded;
              } else {
                bgColor = theme.cardColor;
                textColor = colorScheme.onSurface;
              }

              if (isToday) {
                border = Border.all(
                  color: themeColors?.todayBorder ?? colorScheme.primary,
                  width: 2.2,
                );
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppDateUtils.formatWeekdayShort(day),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w600,
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (icon != null)
                        Icon(icon, size: 13, color: textColor)
                      else
                        const SizedBox(height: 13),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Accessible legend row
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _buildLegendTag(
                context,
                icon: Icons.water_drop_rounded,
                label: 'Recorded Period',
                color: themeColors?.periodDay ?? colorScheme.primary,
              ),
              _buildLegendTag(
                context,
                icon: Icons.water_drop_outlined,
                label: 'Predicted',
                color: themeColors?.predictedPeriodDayBorder ??
                    colorScheme.primary,
              ),
              _buildLegendTag(
                context,
                icon: Icons.eco_rounded,
                label: 'Fertile Window (Approx.)',
                color: themeColors?.fertileDayText ?? colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendTag(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
