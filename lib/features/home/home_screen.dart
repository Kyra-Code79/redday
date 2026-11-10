import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../models/daily_log.dart';
import '../../models/period.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/period_provider.dart';
import '../../shared/widgets/leaf_badge.dart';
import '../navigation/app_shell.dart';
import '../onboarding/first_time_tutorial_dialog.dart';
import '../period_logging/period_log_screen.dart';
import '../settings/settings_screen.dart';
import '../symptom_tracking/symptom_tracking_screen.dart';
import 'widgets/boyfriend_care_card.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/first_time_tutorial_card.dart';
import 'widgets/main_cycle_card.dart';
import 'widgets/period_timeline_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/red_day_nutrition_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateTab});

  final ValueChanged<int>? onNavigateTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyLog? _todayLog;
  bool _showFirstTimeTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayLog();
      _checkFirstTimeTutorial();
    });
  }

  Future<void> _checkFirstTimeTutorial() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final isComplete =
          prefs.getBool(AppConstants.prefKeyTutorialComplete) ?? false;
      if (mounted) {
        setState(() => _showFirstTimeTutorial = !isComplete);
      }
    } catch (_) {}
  }

  Future<void> _openInteractiveTutorial() async {
    await FirstTimeTutorialDialog.show(context);
    if (mounted) {
      setState(() => _showFirstTimeTutorial = false);
    }
  }

  Future<void> _dismissTutorialCard() async {
    await FirstTimeTutorialDialog.markTutorialComplete();
    if (mounted) {
      setState(() => _showFirstTimeTutorial = false);
    }
  }

  Future<void> _loadTodayLog() async {
    if (!mounted) return;
    try {
      final log = await context
          .read<DailyLogProvider>()
          .getLogForDate(AppDateUtils.today);
      if (mounted) setState(() => _todayLog = log);
    } catch (_) {}
  }

  void _openLogPeriod([Period? existingPeriod]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PeriodLogScreen(
          existingPeriod: existingPeriod,
          initialStartDate: AppDateUtils.today,
        ),
      ),
    );
    if (result == true && mounted) {
      await _loadTodayLog();
    }
  }

  void _openSymptomTracking() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SymptomTrackingScreen(
          date: AppDateUtils.today,
        ),
      ),
    );
    if (result == true && mounted) {
      await _loadTodayLog();
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = context.watch<LocaleProvider>().tr;
    final periodProvider = context.watch<PeriodProvider>();
    final prediction = periodProvider.prediction;
    final periods = periodProvider.periods;
    final latestPeriod = periods.isNotEmpty ? periods.first : null;

    return Scaffold(
      body: SafeArea(
        child: periodProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await periodProvider.loadData();
                  await _loadTodayLog();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const LeafBadge(size: 36, iconSize: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  periodProvider.settings.isBoyfriendMode
                                      ? tr(
                                          'Hello, Partner!',
                                          'Halo, Pasangan!',
                                        )
                                      : tr('Hello!', 'Halo!'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  AppDateUtils.formatDisplay(
                                      AppDateUtils.today),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                final nextMode =
                                    !periodProvider.settings.isBoyfriendMode;
                                await periodProvider.updateSettings(
                                  periodProvider.settings.copyWith(
                                    isBoyfriendMode: nextMode,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: periodProvider
                                          .settings.isBoyfriendMode
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      periodProvider.settings.isBoyfriendMode
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 13,
                                      color: periodProvider
                                              .settings.isBoyfriendMode
                                          ? theme.colorScheme.surface
                                          : theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        tr('Boyfriend Mode', 'Mode Pacar'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: periodProvider
                                                  .settings.isBoyfriendMode
                                              ? theme.colorScheme.surface
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.help_outline_rounded, size: 22),
                            tooltip: 'App Tutorial',
                            onPressed: _openInteractiveTutorial,
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.settings_outlined, size: 22),
                            tooltip: 'Settings',
                            onPressed: _openSettings,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // First-Time User Tutorial Card (shown to first-time users only)
                      if (_showFirstTimeTutorial) ...[
                        FirstTimeTutorialCard(
                          onStartTutorial: _openInteractiveTutorial,
                          onDismiss: _dismissTutorialCard,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Main Cycle Summary Card
                      MainCycleCard(
                        prediction: prediction,
                        onLogPeriodTap: () => _openLogPeriod(),
                      ),
                      const SizedBox(height: 16),

                      // Boyfriend Care & Reminder Hub (when Boyfriend Mode is enabled)
                      if (periodProvider.settings.isBoyfriendMode) ...[
                        BoyfriendCareCard(prediction: prediction),
                        const SizedBox(height: 16),
                      ],

                      // Quick Actions
                      QuickActions(
                        onLogPeriod: () => _openLogPeriod(latestPeriod),
                        onLogSymptoms: _openSymptomTracking,
                        onViewCalendar: () {
                          context
                              .read<CalendarProvider>()
                              .selectDate(AppDateUtils.today);
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          } else {
                            AppShell.switchToTab(context, 1);
                          }
                        },
                        onViewInsights: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(2);
                          } else {
                            AppShell.switchToTab(context, 2);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weekly Timeline
                      PeriodTimelineCard(
                        prediction: prediction,
                        latestPeriod: latestPeriod,
                      ),
                      const SizedBox(height: 16),

                      // Daily Summary
                      DailySummaryCard(
                        todayLog: _todayLog,
                        onEditTap: _openSymptomTracking,
                      ),
                      const SizedBox(height: 16),

                      // Red Day Nutrition & Comfort Foods
                      RedDayNutritionCard(
                        prediction: prediction,
                        userAllergies: periodProvider.settings.dietaryAllergies,
                        userCravings: periodProvider.settings.favoriteFoods,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
