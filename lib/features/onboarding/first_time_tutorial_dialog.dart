import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/app_button.dart';

class TutorialStepData {
  const TutorialStepData({
    required this.icon,
    required this.stepBadgeEn,
    required this.stepBadgeId,
    required this.titleEn,
    required this.titleId,
    required this.descriptionEn,
    required this.descriptionId,
    required this.actionTipEn,
    required this.actionTipId,
  });

  final IconData icon;
  final String stepBadgeEn;
  final String stepBadgeId;
  final String titleEn;
  final String titleId;
  final String descriptionEn;
  final String descriptionId;
  final String actionTipEn;
  final String actionTipId;
}

/// Interactive step-by-step tutorial shown to first-time users only.
/// Persists completion state in SharedPreferences under [AppConstants.prefKeyTutorialComplete].
class FirstTimeTutorialDialog extends StatefulWidget {
  const FirstTimeTutorialDialog({super.key});

  static const List<TutorialStepData> steps = [
    TutorialStepData(
      icon: Icons.donut_large_rounded,
      stepBadgeEn: 'STEP 1 OF 4',
      stepBadgeId: 'LANGKAH 1 DARI 4',
      titleEn: 'Read Your Cycle at a Glance',
      titleId: 'Pantau Siklus Anda Sekilas',
      descriptionEn:
          'The main cycle ring on your Home screen shows your current Cycle Day, active phase, and how many days remain until your next estimated period.',
      descriptionId:
          'Lingkaran siklus utama di layar Beranda menampilkan Hari Siklus saat ini, fase aktif, dan sisa hari menuju perkiraan haid berikutnya.',
      actionTipEn:
          'Tip: Tap "Log Period" or "Record First Period" anytime your period starts or ends.',
      actionTipId:
          'Tips: Ketuk "Log Period" atau "Record First Period" kapan saja saat haid dimulai atau selesai.',
    ),
    TutorialStepData(
      icon: Icons.mood_rounded,
      stepBadgeEn: 'STEP 2 OF 4',
      stepBadgeId: 'LANGKAH 2 DARI 4',
      titleEn: 'One-Tap Daily Check-In',
      titleId: 'Catatan Harian Satu Ketukan',
      descriptionEn:
          'Use the Quick Actions bar to log flow intensity, physical or emotional symptoms (mild, moderate, severe), and personal notes in under 10 seconds.',
      descriptionId:
          'Gunakan tombol Aksi Cepat untuk mencatat intensitas aliran, gejala fisik atau emosi (ringan, sedang, berat), dan catatan pribadi dalam 10 detik.',
      actionTipEn:
          'Tip: Tap "Symptoms" on the Home screen or "Log" on Today\'s Check-in card.',
      actionTipId:
          'Tips: Ketuk "Symptoms" di Beranda atau "Log" pada kartu Catatan Hari Ini.',
    ),
    TutorialStepData(
      icon: Icons.calendar_month_rounded,
      stepBadgeEn: 'STEP 3 OF 4',
      stepBadgeId: 'LANGKAH 3 DARI 4',
      titleEn: 'Understand Your Calendar',
      titleId: 'Pahami Kalender Siklus Anda',
      descriptionEn:
          'Open the Calendar tab to see your full month. Solid filled dates mark Recorded Periods, outlined dates mark Predicted Periods, and leaf icons mark your approximate Fertile Window.',
      descriptionId:
          'Buka tab Kalender untuk melihat bulan penuh. Tanggal penuh menandakan Haid Tercatat, tanggal bergaris tepi menandakan Prediksi Haid, dan ikon daun menandakan Masa Subur.',
      actionTipEn:
          'Tip: Tap any date on the calendar to inspect or edit logs for that specific day.',
      actionTipId:
          'Tips: Ketuk tanggal mana saja di kalender untuk melihat atau mengubah catatan hari tersebut.',
    ),
    TutorialStepData(
      icon: Icons.restaurant_rounded,
      stepBadgeEn: 'STEP 4 OF 4',
      stepBadgeId: 'LANGKAH 4 DARI 4',
      titleEn: 'Nutrition, Insights & 100% Privacy',
      titleId: 'Nutrisi, Wawasan & 100% Privasi',
      descriptionEn:
          'Explore WHO-backed Red Day Comfort Food ideas (including Dark Chocolate, Cheese, Ginger & Greens, filtered for your allergies) and view cycle charts in Insights. Everything stays 100% offline.',
      descriptionId:
          'Temukan rekomendasi makanan nyaman berbasis panduan WHO (termasuk Cokelat Hitam, Keju, Jahe & Sayuran Hijau yang aman untuk alergi Anda) serta grafik di Wawasan. Semua data 100% offline.',
      actionTipEn:
          'Tip: You can change language, theme, or back up your data anytime in Settings.',
      actionTipId:
          'Tips: Anda dapat mengubah bahasa, tema, atau mencadangkan data kapan saja di Pengaturan.',
    ),
  ];

  /// Checks SharedPreferences and shows the tutorial only if the user hasn't completed it yet.
  static Future<bool> showIfFirstTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool(AppConstants.prefKeyTutorialComplete) ?? false;
    if (completed || !context.mounted) return false;

    await show(context);
    return true;
  }

  /// Displays the interactive tutorial dialog and marks it completed when closed.
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FirstTimeTutorialDialog(),
    );
  }

  static Future<void> markTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyTutorialComplete, true);
  }

  @override
  State<FirstTimeTutorialDialog> createState() =>
      _FirstTimeTutorialDialogState();
}

class _FirstTimeTutorialDialogState extends State<FirstTimeTutorialDialog> {
  int _currentStep = 0;

  Future<void> _finishTutorial() async {
    await FirstTimeTutorialDialog.markTutorialComplete();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _nextStep() {
    if (_currentStep < FirstTimeTutorialDialog.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finishTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = context.watch<LocaleProvider>();
    final tr = locale.tr;
    final step = FirstTimeTutorialDialog.steps[_currentStep];
    final isLastStep =
        _currentStep == FirstTimeTutorialDialog.steps.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Badge + Skip button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tr(step.stepBadgeEn, step.stepBadgeId),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _finishTutorial,
                      child: Text(
                        tr('Skip Tutorial', 'Lewati Tutorial'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step Icon
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 28,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Step Title
              Text(
                tr(step.titleEn, step.titleId),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Step Description
              Text(
                tr(step.descriptionEn, step.descriptionId),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Practical Action Tip Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outline, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(step.actionTipEn, step.actionTipId),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Progress Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  FirstTimeTutorialDialog.steps.length,
                  (index) {
                    final isActive = index == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: AppButton(
                        text: tr('Back', 'Kembali'),
                        variant: AppButtonVariant.outline,
                        onPressed: _previousStep,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: isLastStep
                          ? tr('Start Using RedDay', 'Mulai Gunakan RedDay')
                          : tr('Next Tip', 'Selanjutnya'),
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
