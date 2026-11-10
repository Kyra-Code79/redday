import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class FirstTimeTutorialCard extends StatelessWidget {
  const FirstTimeTutorialCard({
    super.key,
    required this.onStartTutorial,
    required this.onDismiss,
  });

  final VoidCallback onStartTutorial;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = context.watch<LocaleProvider>().tr;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tr('FIRST-TIME GUIDE', 'PANDUAN PENGGUNA BARU'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: tr('Dismiss Tutorial', 'Tutup Panduan'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              'Welcome to RedDay! Here is how to get started:',
              'Selamat datang di RedDay! Berikut cara memulai:',
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _buildBullet(
            context,
            number: '1',
            text: tr(
              'Tap "Log Period" to record your start & end dates.',
              'Ketuk "Log Period" untuk mencatat tanggal mulai & selesai haid.',
            ),
          ),
          const SizedBox(height: 6),
          _buildBullet(
            context,
            number: '2',
            text: tr(
              'Tap "Symptoms" to log daily flow, cramps, or mood.',
              'Ketuk "Symptoms" untuk mencatat aliran harian, kram, atau suasana hati.',
            ),
          ),
          const SizedBox(height: 6),
          _buildBullet(
            context,
            number: '3',
            text: tr(
              'Use "Calendar" & "Insights" to track predictions.',
              'Gunakan "Calendar" & "Insights" untuk memantau prediksi siklus.',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton(
                  text: tr('Interactive Tutorial', 'Tutorial Interaktif'),
                  icon: Icons.play_circle_outline_rounded,
                  onPressed: onStartTutorial,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: tr('Got It', 'Mengerti'),
                  variant: AppButtonVariant.outline,
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(
    BuildContext context, {
    required String number,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
