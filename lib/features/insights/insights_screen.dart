import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/period_provider.dart';
import 'widgets/cycle_trend_chart.dart';
import 'widgets/duration_chart.dart';
import 'widgets/stat_summary_card.dart';
import 'widgets/symptom_frequency_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsights();
    });
  }

  Future<void> _loadInsights() async {
    final periodProvider = context.read<PeriodProvider>();
    await context.read<InsightsProvider>().loadInsights(
          periods: periodProvider.periods,
          settings: periodProvider.settings,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final insightsProvider = context.watch<InsightsProvider>();
    final stats = insightsProvider.stats;
    final freqs = insightsProvider.symptomFrequencies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Insights'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<PeriodProvider>().loadData();
            await _loadInsights();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Metrics
                StatSummaryCard(stats: stats),
                const SizedBox(height: 16),

                // Cycle Length Trend Chart
                CycleTrendChart(stats: stats),
                const SizedBox(height: 16),

                // Period Duration Chart
                DurationChart(stats: stats),
                const SizedBox(height: 16),

                // Symptom Frequency
                SymptomFrequencyChart(frequencies: freqs),
                const SizedBox(height: 16),

                // Medical Disclaimer Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cycle variations naturally occur from stress, sleep, activity, and life events. These statistics are descriptive rather than diagnostic. Always consult a qualified medical professional for clinical concerns.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
          ),
        ),
      ),
    );
  }
}
