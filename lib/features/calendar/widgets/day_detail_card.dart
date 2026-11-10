import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/cycle_prediction.dart';
import '../../../models/daily_log.dart';
import '../../../models/period.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class DayDetailCard extends StatelessWidget {
  const DayDetailCard({
    super.key,
    required this.selectedDate,
    required this.period,
    required this.dailyLog,
    required this.prediction,
    required this.onLogPeriodTap,
    required this.onLogSymptomsTap,
  });

  final DateTime selectedDate;
  final Period? period;
  final DailyLog? dailyLog;
  final CyclePrediction prediction;
  final VoidCallback onLogPeriodTap;
  final VoidCallback onLogSymptomsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();

    final isRecordedPeriod = period != null;
    final isPredictedPeriod =
        !isRecordedPeriod && prediction.isDateInPredictedPeriod(selectedDate);
    final isFertile = !isRecordedPeriod &&
        !isPredictedPeriod &&
        prediction.isDateInFertileWindow(selectedDate);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.formatFull(selectedDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildDateSubtitle(isRecordedPeriod, isPredictedPeriod, isFertile),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isRecordedPeriod
                            ? (themeColors?.periodDay ?? colorScheme.primary)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isRecordedPeriod ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRecordedPeriod)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: themeColors?.badgeBackground ?? colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 13,
                        color: themeColors?.badgeText ?? colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Period Day',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: themeColors?.badgeText ?? colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Flow info if present
          if (dailyLog?.flowIntensity != null) ...[
            Row(
              children: [
                Icon(
                  dailyLog!.flowIntensity!.icon,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Flow: ${dailyLog!.flowIntensity!.displayName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Symptoms chips
          if (dailyLog != null && dailyLog!.hasSymptoms) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dailyLog!.symptoms.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline, width: 1.2),
                  ),
                  child: Text(
                    '${s.symptom.name} (${s.severity.displayName})',
                    style: theme.textTheme.labelSmall,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Notes
          if (dailyLog != null && dailyLog!.hasNotes) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dailyLog!.notes!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Empty state if nothing recorded
          if (!isRecordedPeriod &&
              (dailyLog == null || dailyLog!.isEmpty) &&
              !isPredictedPeriod) ...[
            Text(
              'No symptoms or period logged for this date.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: isRecordedPeriod ? 'Edit Period' : 'Log Period',
                  variant: AppButtonVariant.outline,
                  icon: Icons.water_drop_outlined,
                  onPressed: onLogPeriodTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: (dailyLog != null && !dailyLog!.isEmpty)
                      ? 'Edit Log'
                      : 'Log Symptoms',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.mood_rounded,
                  onPressed: onLogSymptomsTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDateSubtitle(
    bool isRecorded,
    bool isPredicted,
    bool isFertile,
  ) {
    if (isRecorded) {
      if (period?.endDate == null) {
        return 'Ongoing recorded period';
      }
      return 'Recorded period (${period!.durationInDays} days)';
    }
    if (isPredicted) {
      return 'Predicted period window (Estimated)';
    }
    if (isFertile) {
      return 'Approximate fertile window (Awareness only)';
    }
    return 'Regular cycle day';
  }
}
