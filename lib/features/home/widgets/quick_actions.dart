import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onLogPeriod,
    required this.onLogSymptoms,
    required this.onViewCalendar,
    required this.onViewInsights,
  });

  final VoidCallback onLogPeriod;
  final VoidCallback onLogSymptoms;
  final VoidCallback onViewCalendar;
  final VoidCallback onViewInsights;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.water_drop_rounded,
            label: 'Log Period',
            onTap: onLogPeriod,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.mood_rounded,
            label: 'Symptoms',
            onTap: onLogSymptoms,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Calendar',
            onTap: onViewCalendar,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionItem(
            context,
            icon: Icons.insights_rounded,
            label: 'Insights',
            onTap: onViewInsights,
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
