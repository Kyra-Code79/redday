import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/daily_log.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    super.key,
    required this.todayLog,
    required this.onEditTap,
  });

  final DailyLog? todayLog;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = context.watch<LocaleProvider>().tr;
    final log = todayLog;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr("Today's Check-in", 'Catatan Hari Ini'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onEditTap,
                child: Text(
                  log != null && !log.isEmpty
                      ? tr('Edit', 'Ubah')
                      : tr('Log', 'Catat'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (log == null || log.isEmpty) ...[
            Text(
              tr(
                'No symptoms or flow logged today.',
                'Belum ada gejala atau aliran tercatat hari ini.',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                'Recording daily cues helps you observe subtle rhythm changes.',
                'Mencatat sinyal harian membantu Anda memahami perubahan siklus.',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ] else ...[
            // Flow display
            if (log.flowIntensity != null) ...[
              Row(
                children: [
                  Icon(
                    log.flowIntensity!.icon,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Flow: ${log.flowIntensity!.displayName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Symptoms chips
            if (log.hasSymptoms) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: log.symptoms.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline, width: 1.2),
                    ),
                    child: Text(
                      '${entry.symptom.name} (${entry.severity.displayName})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            // Notes
            if (log.hasNotes) ...[
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
                        log.notes!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
