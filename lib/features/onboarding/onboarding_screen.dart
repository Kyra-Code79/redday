import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../models/app_settings.dart';
import '../../models/period.dart';
import '../../providers/locale_provider.dart';
import '../../providers/period_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/leaf_badge.dart';
import '../navigation/app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Screen 1 & 2 Boyfriend / Partner Mode data
  bool _isBoyfriendMode = false;
  bool _knowsPeriodDuration = true;

  // Screen 2 data
  DateTime? _lastPeriodStart;
  int _periodDuration = AppConstants.defaultPeriodDurationDays;
  int _cycleLength = AppConstants.defaultCycleLengthDays;

  // Screen 3 data: Diet & Comfort Preferences
  final List<String> _selectedAllergies = [];
  final List<String> _selectedCravings = ['chocolate'];

  // Screen 4 data: Reminders
  bool _periodRemindersEnabled = true;
  int _daysBeforeReminder = 2;
  bool _dailyRemindersEnabled = false;
  bool _boyfriendCareReminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isSaving = false;

  void _nextPage() {
    final localeProvider = context.read<LocaleProvider>();
    if (!localeProvider.hasSelectedLanguage) {
      localeProvider.setLanguage(localeProvider.languageCode);
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    try {
      final periodProvider = context.read<PeriodProvider>();
      final localeProvider = context.read<LocaleProvider>();
      await localeProvider.setLanguage(localeProvider.languageCode);

      // 1. Save settings
      final updatedSettings = AppSettings(
        averageCycleLength: _cycleLength,
        averagePeriodDuration: _periodDuration,
        periodReminderEnabled: _periodRemindersEnabled,
        periodReminderDaysBefore: _daysBeforeReminder,
        dailyReminderEnabled: _dailyRemindersEnabled,
        reminderTimeHour: _reminderTime.hour,
        reminderTimeMinute: _reminderTime.minute,
        lastPeriodStart: _lastPeriodStart,
        dietaryAllergies: _selectedAllergies,
        favoriteFoods: _selectedCravings,
        isBoyfriendMode: _isBoyfriendMode,
        boyfriendCareReminderEnabled: _boyfriendCareReminderEnabled,
        knowsPeriodDuration: _knowsPeriodDuration,
      );
      await periodProvider.updateSettings(updatedSettings);

      // 2. If user picked a last period start date, record it as a period entry
      if (_lastPeriodStart != null) {
        final period = Period(
          startDate: _lastPeriodStart!,
          endDate: _lastPeriodStart!.add(Duration(days: _periodDuration - 1)),
        );
        try {
          await periodProvider.addPeriod(period);
        } catch (_) {
          // If already exists or validation fails, settings hold baseline
        }
      }

      // 3. Mark onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefKeyOnboardingComplete, true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const AppShell(showTutorialOnStart: true),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save setup: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = context.watch<LocaleProvider>();
    final tr = locale.tr;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _previousPage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 24),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
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
                    }),
                  ),
                  const Spacer(),
                  if (_currentPage == 1 || _currentPage == 2)
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(tr('Skip', 'Lewati')),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(context, locale),
                  _buildCycleInfoPage(context, locale),
                  _buildDietPreferencesPage(context, locale),
                  _buildPreferencesPage(context, locale),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AppButton(
                text: _currentPage == 3
                    ? tr('Get Started', 'Mulai Sekarang')
                    : tr('Continue', 'Lanjutkan'),
                isFullWidth: true,
                isLoading: _isSaving,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, LocaleProvider locale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = locale.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const LeafBadge(size: 60, iconSize: 32),
          const SizedBox(height: 12),
          Text(
            AppConstants.appName,
            style: theme.textTheme.displayMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tr('Understand Your Cycle.', 'Pahami Siklus Anda.'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'A private, calm wellness tracker designed to help you follow your menstrual rhythms without accounts or external servers.',
              'Aplikasi pelacak siklus menstruasi yang tenang dan 100% pribadi di perangkat Anda, tanpa akun dan tanpa server eksternal.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // First-Time Language Question Card
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Which language would you like to use?\nBahasa apa yang ingin Anda gunakan?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: 'English',
                        subtitle: 'Default',
                        isSelected: locale.languageCode == 'en',
                        onTap: () => locale.setLanguage('en'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: 'Bahasa Indonesia',
                        subtitle: 'Indonesia',
                        isSelected: locale.languageCode == 'id',
                        onTap: () => locale.setLanguage('id'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Who is using this app? (For Myself vs Boyfriend Mode)
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(
                          'Who is using this app?',
                          'Siapa yang menggunakan aplikasi ini?',
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr('For Myself', 'Untuk Diri Sendiri'),
                        subtitle: tr('Personal tracker', 'Pelacak pribadi'),
                        isSelected: !_isBoyfriendMode,
                        onTap: () {
                          setState(() {
                            _isBoyfriendMode = false;
                            _knowsPeriodDuration = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr('Boyfriend Mode', 'Mode Pacar'),
                        subtitle: tr('Track & care for her', 'Untuk pasangan'),
                        isSelected: _isBoyfriendMode,
                        onTap: () {
                          setState(() {
                            _isBoyfriendMode = true;
                            _knowsPeriodDuration = false;
                            _periodDuration =
                                AppConstants.defaultPeriodDurationDays;
                            _cycleLength =
                                AppConstants.defaultCycleLengthDays;
                            _boyfriendCareReminderEnabled = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Option on First App Start: Today is the first day
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(
                          'Did the period start today?',
                          'Apakah haid dimulai hari ini?',
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr(
                          'Today is the first day',
                          'Hari ini hari pertama',
                        ),
                        subtitle: AppDateUtils.formatDisplay(AppDateUtils.today),
                        isSelected: _lastPeriodStart != null &&
                            AppDateUtils.isSameDay(
                              _lastPeriodStart!,
                              AppDateUtils.today,
                            ),
                        onTap: () {
                          setState(() {
                            _lastPeriodStart = AppDateUtils.today;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr('Other date / Later', 'Tanggal lain / Nanti'),
                        subtitle: tr('Choose on next step', 'Pilih di langkah berikutnya'),
                        isSelected: _lastPeriodStart == null ||
                            !AppDateUtils.isSameDay(
                              _lastPeriodStart!,
                              AppDateUtils.today,
                            ),
                        onTap: () {
                          setState(() {
                            _lastPeriodStart = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildFeatureRow(
            context,
            icon: Icons.shield_outlined,
            title: tr('100% Offline & Private', '100% Offline & Pribadi'),
            subtitle: tr(
              'Your cycle data stays on this device only.',
              'Data siklus Anda hanya tersimpan di perangkat ini.',
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            context,
            icon: Icons.auto_graph_rounded,
            title: tr('Intelligent Predictions', 'Prediksi Cerdas'),
            subtitle: tr(
              'Calculates patterns that adapt to your historical data.',
              'Menghitung pola siklus yang menyesuaikan riwayat Anda.',
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            context,
            icon: Icons.notifications_none_rounded,
            title: tr('Gentle Reminders', 'Pengingat Lembut'),
            subtitle: tr(
              'Timely notifications before your estimated period starts.',
              'Notifikasi tepat waktu sebelum perkiraan haid dimulai.',
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outline,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoPage(BuildContext context, LocaleProvider locale) {
    final theme = Theme.of(context);
    final tr = locale.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            tr('Your Cycle Baseline', 'Dasar Siklus Anda'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Enter your usual patterns. Cycle length is counted from the first day of one period to the first day of the next period.',
              'Masukkan pola siklus Anda biasanya. Panjang siklus dihitung dari hari pertama haid hingga hari pertama haid berikutnya.',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Last period start date picker + "Today is the first day" quick option
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('First day of most recent period', 'Hari pertama haid terakhir'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // 1-tap option: Today is the first day
                InkWell(
                  onTap: () {
                    setState(() {
                      _lastPeriodStart = AppDateUtils.today;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _lastPeriodStart != null &&
                              AppDateUtils.isSameDay(
                                _lastPeriodStart!,
                                AppDateUtils.today,
                              )
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _lastPeriodStart != null &&
                                  AppDateUtils.isSameDay(
                                    _lastPeriodStart!,
                                    AppDateUtils.today,
                                  )
                              ? Icons.check_circle_rounded
                              : Icons.today_rounded,
                          size: 18,
                          color: _lastPeriodStart != null &&
                                  AppDateUtils.isSameDay(
                                    _lastPeriodStart!,
                                    AppDateUtils.today,
                                  )
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tr(
                              'Today is the first day',
                              'Hari ini adalah hari pertama',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _lastPeriodStart != null &&
                                      AppDateUtils.isSameDay(
                                        _lastPeriodStart!,
                                        AppDateUtils.today,
                                      )
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastPeriodStart ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        _lastPeriodStart = AppDateUtils.dateOnly(picked);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _lastPeriodStart != null
                                ? AppDateUtils.formatDisplay(_lastPeriodStart!)
                                : tr('Select date (optional)', 'Pilih tanggal (opsional)'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _lastPeriodStart != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (_lastPeriodStart != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => _lastPeriodStart = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question: Do you know the period duration?
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(
                          'Do you know the period duration?',
                          'Apakah Anda tahu durasi haid?',
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr('Yes, I know', 'Ya, saya tahu'),
                        subtitle: tr('Set exact days', 'Atur jumlah hari'),
                        isSelected: _knowsPeriodDuration,
                        onTap: () {
                          setState(() => _knowsPeriodDuration = true);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        context,
                        label: tr('Not sure', 'Tidak tahu'),
                        subtitle: tr('Use 5-day default', 'Standar 5 hari'),
                        isSelected: !_knowsPeriodDuration,
                        onTap: () {
                          setState(() {
                            _knowsPeriodDuration = false;
                            _periodDuration =
                                AppConstants.defaultPeriodDurationDays;
                            _cycleLength = AppConstants.defaultCycleLengthDays;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (!_knowsPeriodDuration) ...[
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      'No problem! RedDay will automatically use a standard 5-day period duration and 28-day cycle. When logging a period, you can also select "Not Sure" if you don\'t know whether the period blood is a lot or not.',
                      'Tidak masalah! RedDay otomatis menggunakan standar durasi haid 5 hari dan siklus 28 hari. Saat mencatat haid, Anda juga bisa memilih "Not Sure" jika tidak tahu apakah darah haidnya banyak atau sedikit.',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_knowsPeriodDuration) ...[
            // Period duration slider
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('Average Period Duration', 'Rata-rata Durasi Haid'),
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '$_periodDuration ${tr('days', 'hari')}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _periodDuration.toDouble(),
                    min: AppConstants.minPeriodDurationDays.toDouble(),
                    max: AppConstants.maxPeriodDurationDays.toDouble(),
                    divisions: AppConstants.maxPeriodDurationDays -
                        AppConstants.minPeriodDurationDays,
                    onChanged: (val) {
                      setState(() => _periodDuration = val.round());
                    },
                  ),
                  Text(
                    tr(
                      'Number of days bleeding typically lasts (usually 3–7 days).',
                      'Jumlah hari haid biasanya berlangsung (umumnya 3–7 hari).',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cycle length slider
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('Average Cycle Length', 'Rata-rata Panjang Siklus'),
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '$_cycleLength ${tr('days', 'hari')}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _cycleLength.toDouble(),
                    min: AppConstants.minCycleLengthDays.toDouble(),
                    max: AppConstants.maxCycleLengthDays.toDouble(),
                    divisions: AppConstants.maxCycleLengthDays -
                        AppConstants.minCycleLengthDays,
                    onChanged: (val) {
                      setState(() => _cycleLength = val.round());
                    },
                  ),
                  Text(
                    tr(
                      'Days from start of one period to start of the next (usually 21–35 days).',
                      'Jumlah hari dari awal haid ke awal haid berikutnya (umumnya 21–35 hari).',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage(BuildContext context, LocaleProvider locale) {
    final theme = Theme.of(context);
    final tr = locale.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            tr('Reminders & Privacy', 'Pengingat & Privasi'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Choose how you want RedDay to gently notify you.',
              'Pilih bagaimana Anda ingin RedDay memberi pengingat.',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Boyfriend Care Reminder (highlighted for Boyfriend Mode, available to all)
          AppCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                tr('Boyfriend Care Reminder', 'Pengingat Perhatian Pacar'),
              ),
              subtitle: Text(
                tr(
                  'Remind the boyfriend to remember her upcoming period, comfort snacks, and extra care',
                  'Ingatkan pacar tentang jadwal haid pasangan, camilan favorit, dan perhatian ekstra',
                ),
              ),
              value: _boyfriendCareReminderEnabled,
              onChanged: (val) {
                setState(() => _boyfriendCareReminderEnabled = val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Period reminder switch
          AppCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('Period Reminder', 'Pengingat Haid')),
                  subtitle: Text(
                    tr(
                      'Notify before estimated period starts',
                      'Beri tahu sebelum perkiraan haid dimulai',
                    ),
                  ),
                  value: _periodRemindersEnabled,
                  onChanged: (val) {
                    setState(() => _periodRemindersEnabled = val);
                  },
                ),
                if (_periodRemindersEnabled) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tr('Days before', 'Hari sebelumnya'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isDense: true,
                              value: _daysBeforeReminder,
                              items: [0, 1, 2, 3, 5].map((d) {
                                return DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d == 0
                                        ? tr('On the day', 'Pada hari H')
                                        : d == 1
                                            ? tr('1 day before', '1 hari sebelum')
                                            : '$d ${tr('days before', 'hari sebelum')}',
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _daysBeforeReminder = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daily reminder
          AppCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    tr('Daily Check-in Reminder', 'Pengingat Catatan Harian'),
                  ),
                  subtitle: Text(
                    tr(
                      'Friendly reminder to log daily symptoms',
                      'Pengingat ramah untuk mencatat gejala harian',
                    ),
                  ),
                  value: _dailyRemindersEnabled,
                  onChanged: (val) {
                    setState(() => _dailyRemindersEnabled = val);
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('Notification Time', 'Waktu Notifikasi')),
                  trailing: Text(
                    _reminderTime.format(context),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Medical disclaimer note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr(
                      'Predictions are statistical estimates based on your logged history. They are not medical diagnoses or reliable contraception guidance.',
                      'Prediksi adalah perkiraan statistik berdasarkan riwayat catatan Anda. Bukan diagnosis medis atau panduan kontrasepsi.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDietPreferencesPage(BuildContext context, LocaleProvider locale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tr = locale.tr;

    final availableAllergies = [
      {'id': 'dairy', 'label': tr('🥛 Dairy / Lactose', '🥛 Susu / Laktosa')},
      {'id': 'nuts', 'label': tr('🥜 Peanuts & Tree Nuts', '🥜 Kacang-kacangan')},
      {'id': 'gluten', 'label': tr('🌾 Gluten / Wheat', '🌾 Gluten / Gandum')},
      {'id': 'seafood', 'label': tr('🐟 Seafood & Fish', '🐟 Makanan Laut & Ikan')},
      {'id': 'eggs', 'label': tr('🥚 Eggs', '🥚 Telur')},
      {'id': 'soy', 'label': tr('🌱 Soy', '🌱 Kedelai')},
    ];

    final availableCravings = [
      {'id': 'chocolate', 'label': tr('🍫 Chocolate & Sweets', '🍫 Cokelat & Manis')},
      {'id': 'cheese', 'label': tr('🧀 Cheese & Savory Melts', '🧀 Keju & Hidangan Gurih')},
      {'id': 'tea', 'label': tr('🍵 Warm Teas & Soups', '🍵 Teh Hangat & Sup')},
      {'id': 'berries', 'label': tr('🍓 Fresh Berries & Fruits', '🍓 Buah & Beri Segar')},
      {'id': 'oats', 'label': tr('🍪 Warm Oats & Bakes', '🍪 Oat Hangat & Kue')},
      {'id': 'healthy_fats', 'label': tr('🥑 Healthy Fats & Nuts', '🥑 Lemak Sehat & Kacang')},
      {'id': 'pasta_rice', 'label': tr('🍝 Comfort Pasta & Rice', '🍝 Pasta & Nasi Hangat')},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            tr('Diet & Comfort Cravings', 'Diet & Makanan Favorit'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Red days require extra gentle nutrition. Tell us your sensitivities and favorites so we can suggest soothing meals, snacks, and sweet treats tailored to you.',
              'Hari haid membutuhkan nutrisi ekstra lembut. Beri tahu alergi dan makanan favorit Anda agar kami dapat menyarankan hidangan yang menenangkan.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Question 1: Allergies
          Text(
            tr('DO YOU HAVE ANY FOOD ALLERGIES?', 'APAKAH ANDA MEMILIKI ALERGI MAKANAN?'),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'Select any that apply so we safely flag or swap ingredients in dish suggestions.',
              'Pilih yang sesuai agar kami dapat memberi tanda atau saran pengganti bahan yang aman.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableAllergies.map((item) {
              final isSelected = _selectedAllergies.contains(item['id']);
              return FilterChip(
                selected: isSelected,
                label: Text(item['label']!),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedAllergies.add(item['id']!);
                    } else {
                      _selectedAllergies.remove(item['id']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Question 2: Cravings
          Text(
            tr('WHAT COMFORT FOODS DO YOU CRAVE?', 'MAKANAN APA YANG ANDA INGINKAN SAAT HAID?'),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              'We will turn these raw components into healthy cakes, cheese melts, cookies, teas, and soothing meals.',
              'Kami mengolah bahan-bahan ini menjadi kue sehat, olahan keju, teh hangat, dan hidangan penenang.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableCravings.map((item) {
              final isSelected = _selectedCravings.contains(item['id']);
              return FilterChip(
                selected: isSelected,
                label: Text(item['label']!),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedCravings.add(item['id']!);
                    } else {
                      _selectedCravings.remove(item['id']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Example Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(
                      'Example: Dark Chocolate & Ricotta Cheese ➔ Warm Choco Mug Cake & Baked Ricotta Toast to relax cramps.',
                      'Contoh: Cokelat Hitam & Keju Ricotta ➔ Mug Cake Cokelat Hangat & Roti Panggang Keju untuk meredakan kram.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
