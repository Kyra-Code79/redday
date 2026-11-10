import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/cycle_prediction.dart';
import '../../../models/daily_log.dart';
import '../../../models/period.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.periods,
    required this.prediction,
    required this.monthLogs,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTodayPressed,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<Period> periods;
  final CyclePrediction prediction;
  final List<DailyLog> monthLogs;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTodayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Month Navigation Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: onPreviousMonth,
                tooltip: 'Previous Month',
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        AppDateUtils.formatMonthYear(focusedMonth),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onTodayPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Today',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: onNextMonth,
                tooltip: 'Next Month',
              ),
            ],
          ),
        ),

        // Weekday header (Mon to Sun)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 6),

        // Days Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildDaysGrid(context),
        ),
      ],
    );
  }

  Widget _buildDaysGrid(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    // Weekday of firstDay: 1=Mon .. 7=Sun
    final leadingDays = firstDay.weekday - 1;
    final totalCells = ((leadingDays + lastDay.day + 6) ~/ 7) * 7;

    final startDate = firstDay.subtract(Duration(days: leadingDays));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        return _buildDayCell(context, date);
      },
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();

    final isCurrentMonth = date.month == focusedMonth.month;
    final isToday = AppDateUtils.isSameDay(date, AppDateUtils.today);
    final isSelected = AppDateUtils.isSameDay(date, selectedDate);

    // Check if recorded period
    final isRecordedPeriod = periods.any((p) => p.containsDate(date));

    // Check if predicted period
    final isPredictedPeriod =
        !isRecordedPeriod && prediction.isDateInPredictedPeriod(date);

    // Check if fertile window
    final isFertile =
        !isRecordedPeriod && !isPredictedPeriod && prediction.isDateInFertileWindow(date);

    // Check if logged daily log (symptoms, flow, notes)
    final hasDailyLog = monthLogs.any((l) =>
        AppDateUtils.isSameDay(l.logDate, date) && !l.isEmpty);

    // Determine cell styling
    Color? cellBg;
    Color textColor;
    Border? border;

    if (isSelected) {
      cellBg = themeColors?.selectedDay ?? colorScheme.primary;
      textColor = themeColors?.selectedDayText ?? colorScheme.onPrimary;
    } else if (isRecordedPeriod) {
      cellBg = themeColors?.periodDay ?? colorScheme.primary;
      textColor = themeColors?.periodDayText ?? colorScheme.onPrimary;
    } else if (isPredictedPeriod) {
      cellBg = themeColors?.predictedPeriodDay ?? colorScheme.surface;
      textColor = themeColors?.predictedPeriodText ?? colorScheme.onSurface;
      border = Border.all(
        color: themeColors?.predictedPeriodDayBorder ?? colorScheme.primary,
        width: 1.5,
      );
    } else if (isFertile) {
      cellBg = themeColors?.fertileDay ?? colorScheme.surface;
      textColor = themeColors?.fertileDayText ?? colorScheme.onSurface;
      border = Border.all(
        color: colorScheme.outline.withValues(alpha: 0.5),
        width: 1,
      );
    } else {
      cellBg = Colors.transparent;
      textColor = isCurrentMonth
          ? colorScheme.onSurface
          : colorScheme.onSurface.withValues(alpha: 0.45);
    }

    if (isToday && !isSelected) {
      border = Border.all(
        color: themeColors?.todayBorder ?? colorScheme.primary,
        width: 2.2,
      );
    }

    return InkWell(
      onTap: () => onDateSelected(date),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${date.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: (isToday || isSelected || isRecordedPeriod)
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Bottom indicator dot or drop icon
            if (isRecordedPeriod && !isSelected)
              Icon(
                Icons.water_drop_rounded,
                size: 10,
                color: textColor,
              )
            else if (isPredictedPeriod && !isSelected)
              Icon(
                Icons.water_drop_outlined,
                size: 10,
                color: textColor,
              )
            else if (isFertile && !isSelected)
              Icon(
                Icons.eco_rounded,
                size: 10,
                color: textColor,
              )
            else if (hasDailyLog)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected
                      ? textColor
                      : (themeColors?.periodDay ?? colorScheme.primary),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
