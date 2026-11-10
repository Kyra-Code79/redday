import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cycle_prediction.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/period_provider.dart';
import '../../../shared/widgets/app_card.dart';

class BoyfriendCareCard extends StatefulWidget {
  const BoyfriendCareCard({
    super.key,
    required this.prediction,
  });

  final CyclePrediction prediction;

  @override
  State<BoyfriendCareCard> createState() => _BoyfriendCareCardState();
}

class _BoyfriendCareCardState extends State<BoyfriendCareCard> {
  final Set<int> _checkedItems = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;
    final bg = theme.colorScheme.surface;
    final locale = context.watch<LocaleProvider>();
    final periodProvider = context.watch<PeriodProvider>();
    final settings = periodProvider.settings;

    final String statusHeadline;
    final String statusSubtext;

    if (!widget.prediction.hasData) {
      statusHeadline = locale.tr(
        'Ready to track her cycle',
        'Siap memantau siklus pasangan',
      );
      statusSubtext = locale.tr(
        'Tap "Log Period" when her period starts. Don\'t know her period duration or if the blood is a lot? No problem — RedDay uses a 5-day default and lets you choose "Not Sure" for blood flow.',
        'Ketuk "Log Period" saat haidnya mulai. Tidak tahu durasi haid atau apakah darahnya banyak? Tidak masalah — RedDay otomatis memakai standar 5 hari dan menyediakan opsi "Not Sure" untuk aliran darah.',
      );
    } else if (widget.prediction.isPeriodOngoing ||
        widget.prediction.phase == CyclePhase.menstrual) {
      statusHeadline = locale.tr(
        'She is on her Red Day right now',
        'Dia sedang dalam masa Haid (Red Day)',
      );
      statusSubtext = locale.tr(
        'Extra warmth, patience, and iron/calcium comfort foods help a lot today. You do not need to know if her flow is heavy or light.',
        'Perhatian ekstra, kesabaran, dan makanan kaya zat besi/kalsium sangat membantu hari ini. Anda tidak perlu tahu apakah darah haidnya banyak atau sedikit.',
      );
    } else if (widget.prediction.daysUntilNextPeriod >= 0 &&
        widget.prediction.daysUntilNextPeriod <= 5) {
      final days = widget.prediction.daysUntilNextPeriod;
      statusHeadline = locale.tr(
        days == 0
            ? 'Her period is expected today!'
            : 'Her period is coming in ~$days days',
        days == 0
            ? 'Haidnya diperkirakan mulai hari ini!'
            : 'Haidnya diperkirakan dalam ~$days hari',
      );
      statusSubtext = locale.tr(
        'PMS or luteal fatigue may appear soon. Stock up on her favorite snacks and keep reminders active!',
        'Kelelahan PMS mungkin mulai terasa. Siapkan camilan favoritnya dan pastikan pengingat aktif!',
      );
    } else {
      statusHeadline = locale.tr(
        'Current Phase: ${widget.prediction.phase.displayName}',
        'Fase Saat Ini: ${widget.prediction.phase.displayName}',
      );
      statusSubtext = !settings.knowsPeriodDuration
          ? locale.tr(
              'Using standard ${settings.averagePeriodDuration}-day duration & ${settings.averageCycleLength}-day cycle automatically since exact duration is unknown.',
              'Menggunakan durasi standar ${settings.averagePeriodDuration} hari & siklus ${settings.averageCycleLength} hari secara otomatis karena durasi pasti tidak diketahui.',
            )
          : locale.tr(
              'Tracking with ${settings.averagePeriodDuration}-day duration. Keep checking in with kindness!',
              'Memantau dengan durasi ${settings.averagePeriodDuration} hari. Terus beri perhatian hangat!',
            );
    }

    final checklistItems = [
      locale.tr(
        'Prepare comfort snacks (Dark Chocolate, Spinach, or WHO-approved Cheese)',
        'Siapkan camilan nyaman (Cokelat Hitam, Bayam, atau Keju sesuai standar WHO)',
      ),
      locale.tr(
        'Offer warm water, ginger tea, or a warm compress for cramps',
        'Tawarkan air hangat, teh jahe, atau kompres hangat untuk kram perut',
      ),
      locale.tr(
        'Be extra patient & supportive — no need to ask if period blood is heavy or light',
        'Lebih sabar & pengertian — tidak perlu menanyakan apakah darah haid banyak atau sedikit',
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: bg,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.tr(
                        'Boyfriend Care & Reminder Hub',
                        'Pusat Perhatian & Pengingat Pacar',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      locale.tr(
                        'Designed for partners — easy even when you don\'t know all cycle details',
                        'Dirancang untuk pasangan — mudah walau tidak tahu detail siklus',
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fg.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusHeadline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusSubtext,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Reminder Toggle for the Boyfriend
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fg, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, size: 20, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.tr(
                          'Boyfriend Care Reminder',
                          'Pengingat Perhatian Pacar',
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        locale.tr(
                          'Remind me before her period & on Red Days',
                          'Ingatkan saya sebelum haid & saat Red Day',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: fg.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: settings.boyfriendCareReminderEnabled,
                  onChanged: (value) async {
                    await periodProvider.updateSettings(
                      settings.copyWith(
                        boyfriendCareReminderEnabled: value,
                        periodReminderEnabled: value
                            ? true
                            : settings.periodReminderEnabled,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            locale.tr(
              'Today\'s Boyfriend Checklist:',
              'Checklist Perhatian Pacar Hari Ini:',
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(checklistItems.length, (index) {
            final isChecked = _checkedItems.contains(index);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _checkedItems.remove(index);
                  } else {
                    _checkedItems.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isChecked
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color: fg,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        checklistItems[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          fontWeight:
                              isChecked ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
