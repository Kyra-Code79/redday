import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/period_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../nutrition/dietary_preferences_dialog.dart';
import '../nutrition/nutrition_screen.dart';
import '../onboarding/first_time_tutorial_dialog.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ExportService _exportService = ExportService();
  final NotificationService _notificationService = NotificationService();
  bool _isProcessingData = false;

  Future<void> _updateCycleLength(int current) async {
    int tempVal = current;
    final updated = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Average Cycle Length'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempVal days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: tempVal.toDouble(),
                    min: AppConstants.minCycleLengthDays.toDouble(),
                    max: AppConstants.maxCycleLengthDays.toDouble(),
                    divisions: AppConstants.maxCycleLengthDays -
                        AppConstants.minCycleLengthDays,
                    onChanged: (val) {
                      setDialogState(() => tempVal = val.round());
                    },
                  ),
                  Text(
                    'Counted from first day of one period to first day of the next.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(tempVal),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated != null && mounted) {
      final periodProvider = context.read<PeriodProvider>();
      final newSettings =
          periodProvider.settings.copyWith(averageCycleLength: updated);
      await periodProvider.updateSettings(newSettings);
    }
  }

  Future<void> _updatePeriodDuration(int current) async {
    int tempVal = current;
    final updated = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Average Period Duration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempVal days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: tempVal.toDouble(),
                    min: AppConstants.minPeriodDurationDays.toDouble(),
                    max: AppConstants.maxPeriodDurationDays.toDouble(),
                    divisions: AppConstants.maxPeriodDurationDays -
                        AppConstants.minPeriodDurationDays,
                    onChanged: (val) {
                      setDialogState(() => tempVal = val.round());
                    },
                  ),
                  Text(
                    'Typical number of bleeding days (usually 3–7 days).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(tempVal),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated != null && mounted) {
      final periodProvider = context.read<PeriodProvider>();
      final newSettings =
          periodProvider.settings.copyWith(averagePeriodDuration: updated);
      await periodProvider.updateSettings(newSettings);
    }
  }

  Future<void> _exportData() async {
    setState(() => _isProcessingData = true);
    try {
      final resultUri = await _exportService.exportToFile();
      if (!mounted) return;
      if (resultUri != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessingData = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isProcessingData = true);
    try {
      final result = await _exportService.importFromFile();
      if (!mounted) return;
      await context.read<PeriodProvider>().loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Import complete: ${result.periodsImported} periods added (${result.periodsSkipped} skipped), '
            '${result.logsImported} daily logs added.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessingData = false);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete All Tracking Data',
      message:
          'This will permanently erase all recorded periods, daily logs, symptoms, and settings from this device. This action cannot be undone.',
      confirmLabel: 'Erase Everything',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      setState(() => _isProcessingData = true);
      try {
        await context.read<PeriodProvider>().deleteAllData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data was successfully deleted.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      } finally {
        if (mounted) setState(() => _isProcessingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final periodProvider = context.watch<PeriodProvider>();
    final settings = periodProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              Text(
                'APPEARANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Mode',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.wb_sunny_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.nightlight_outlined),
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_brightness_outlined),
                          label: Text('System'),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (set) {
                        themeProvider.setThemeMode(set.first);
                      },
                    ),
                    const Divider(),
                    Text(
                      localeProvider.tr('Language / Bahasa', 'Bahasa / Language'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'en',
                          icon: Icon(Icons.language_rounded),
                          label: Text('English'),
                        ),
                        ButtonSegment(
                          value: 'id',
                          icon: Icon(Icons.translate_rounded),
                          label: Text('Bahasa Indonesia'),
                        ),
                      ],
                      selected: {localeProvider.languageCode},
                      onSelectionChanged: (set) {
                        localeProvider.setLanguage(set.first);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boyfriend / Partner Mode Section
              Text(
                localeProvider.tr('BOYFRIEND / PARTNER MODE', 'MODE PACAR / PASANGAN'),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localeProvider.tr('Boyfriend Mode', 'Mode Pacar'),
                      ),
                      subtitle: Text(
                        localeProvider.tr(
                          'Show Boyfriend Care Hub, checklists & partner-friendly options',
                          'Tampilkan Pusat Perhatian Pacar, checklist & opsi ramah pasangan',
                        ),
                      ),
                      value: settings.isBoyfriendMode,
                      onChanged: (val) async {
                        await periodProvider.updateSettings(
                          settings.copyWith(isBoyfriendMode: val),
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localeProvider.tr(
                          'Do you know the period duration?',
                          'Apakah Anda tahu durasi haid?',
                        ),
                      ),
                      subtitle: Text(
                        settings.knowsPeriodDuration
                            ? localeProvider.tr(
                                'Yes — using ${settings.averagePeriodDuration} days',
                                'Ya — menggunakan ${settings.averagePeriodDuration} hari',
                              )
                            : localeProvider.tr(
                                'Not sure — automatically using 5-day default',
                                'Tidak tahu — otomatis menggunakan standar 5 hari',
                              ),
                      ),
                      value: settings.knowsPeriodDuration,
                      onChanged: (val) async {
                        await periodProvider.updateSettings(
                          settings.copyWith(
                            knowsPeriodDuration: val,
                            averagePeriodDuration: val
                                ? settings.averagePeriodDuration
                                : AppConstants.defaultPeriodDurationDays,
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localeProvider.tr(
                          'Boyfriend Care Reminder',
                          'Pengingat Perhatian Pacar',
                        ),
                      ),
                      subtitle: Text(
                        localeProvider.tr(
                          'Remind the boyfriend about upcoming periods & Red-Day care',
                          'Ingatkan pacar tentang jadwal haid & perhatian saat Red Day',
                        ),
                      ),
                      value: settings.boyfriendCareReminderEnabled,
                      onChanged: (val) async {
                        await periodProvider.updateSettings(
                          settings.copyWith(boyfriendCareReminderEnabled: val),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cycle Preferences Section
              Text(
                'CYCLE PREFERENCES',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.cached_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Average Cycle Length'),
                      subtitle: const Text('Default baseline interval'),
                      trailing: Text(
                        '${settings.averageCycleLength} days',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => _updateCycleLength(settings.averageCycleLength),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.water_drop_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Average Period Duration'),
                      subtitle: const Text('Typical days of flow'),
                      trailing: Text(
                        '${settings.averagePeriodDuration} days',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => _updatePeriodDuration(settings.averagePeriodDuration),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Diet & Nutrition Section
              Text(
                'DIET & NUTRITION',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.health_and_safety_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Allergies & Cravings'),
                      subtitle: Text(
                        settings.dietaryAllergies.isEmpty
                            ? 'No allergy restrictions set'
                            : 'Allergies: ${settings.dietaryAllergies.join(", ")}',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => DietaryPreferencesDialog.show(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.restaurant_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Red Day Nutrition Guide'),
                      subtitle: const Text('Browse soothing food & snack ideas'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const NutritionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications & Reminders Section
              Text(
                'NOTIFICATIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Period Reminder'),
                      subtitle: const Text('Alert before estimated start'),
                      value: settings.periodReminderEnabled,
                      onChanged: (val) async {
                        await _notificationService.requestPermission();
                        await periodProvider.updateSettings(
                          settings.copyWith(periodReminderEnabled: val),
                        );
                      },
                    ),
                    if (settings.periodReminderEnabled) ...[
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
                                localeProvider.tr(
                                  'Days before',
                                  'Hari sebelumnya',
                                ),
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
                                  value: settings.periodReminderDaysBefore,
                                  items: [0, 1, 2, 3, 5].map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d == 0
                                            ? localeProvider.tr(
                                                'On the day',
                                                'Pada hari H',
                                              )
                                            : d == 1
                                                ? localeProvider.tr(
                                                    '1 day before',
                                                    '1 hari sebelum',
                                                  )
                                                : '$d ${localeProvider.tr('days before', 'hari sebelum')}',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) async {
                                    if (val != null) {
                                      await periodProvider.updateSettings(
                                        settings.copyWith(
                                          periodReminderDaysBefore: val,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daily Check-in Reminder'),
                      subtitle: const Text('Daily prompt to log symptoms'),
                      value: settings.dailyReminderEnabled,
                      onChanged: (val) async {
                        await _notificationService.requestPermission();
                        await periodProvider.updateSettings(
                          settings.copyWith(dailyReminderEnabled: val),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.access_time_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Reminder Time'),
                      trailing: Text(
                        TimeOfDay(
                          hour: settings.reminderTimeHour,
                          minute: settings.reminderTimeMinute,
                        ).format(context),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: settings.reminderTimeHour,
                            minute: settings.reminderTimeMinute,
                          ),
                        );
                        if (picked != null) {
                          await periodProvider.updateSettings(
                            settings.copyWith(
                              reminderTimeHour: picked.hour,
                              reminderTimeMinute: picked.minute,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              Text(
                'DATA MANAGEMENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.file_download_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Export Backup Data'),
                      subtitle: const Text('Save tracking records to device'),
                      onTap: _isProcessingData ? null : _exportData,
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.file_upload_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Import Backup Data'),
                      subtitle: const Text('Restore from previously exported JSON'),
                      onTap: _isProcessingData ? null : _importData,
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_forever_rounded,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        'Delete All Data',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text('Erase all cycle records on device'),
                      onTap: _isProcessingData ? null : _deleteAllData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Privacy & About Section
              Text(
                'PRIVACY & ABOUT',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.school_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('App Tutorial & User Guide'),
                      subtitle: const Text('Replay the step-by-step walkthrough'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => FirstTimeTutorialDialog.show(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.shield_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Privacy & Security Policy'),
                      subtitle: const Text('Learn how your data is protected'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text('App Version'),
                      trailing: Text(
                        '1.0.0',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
