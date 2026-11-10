import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildItem(
            context,
            color: themeColors?.periodDay ?? colorScheme.primary,
            icon: Icons.water_drop_rounded,
            iconColor: themeColors?.periodDayText ?? colorScheme.onPrimary,
            label: 'Recorded Period',
          ),
          _buildItem(
            context,
            color: themeColors?.predictedPeriodDay ?? colorScheme.surface,
            borderColor: themeColors?.predictedPeriodDayBorder ?? colorScheme.primary,
            borderWidth: 1.5,
            icon: Icons.water_drop_outlined,
            iconColor: themeColors?.predictedPeriodText ?? colorScheme.primary,
            label: 'Predicted',
          ),
          _buildItem(
            context,
            borderColor: themeColors?.todayBorder ?? colorScheme.primary,
            borderWidth: 2,
            label: 'Today',
          ),
          _buildItem(
            context,
            color: themeColors?.selectedDay ?? colorScheme.primary,
            label: 'Selected',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    Color? color,
    Color? borderColor,
    double borderWidth = 1,
    IconData? icon,
    Color? iconColor,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color ?? Colors.transparent,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(
                  icon,
                  size: 12,
                  color: iconColor ?? theme.colorScheme.primary,
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
