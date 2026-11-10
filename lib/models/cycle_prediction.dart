import '../core/utils/date_utils.dart';

enum CyclePhase {
  menstrual(
    'Menstrual Phase',
    'Your period is active.',
    true,
  ),
  follicular(
    'Follicular Phase (Approx.)',
    'Your body prepares for ovulation. Energy levels often rise.',
    true,
  ),
  ovulation(
    'Estimated Ovulation',
    'Approximate midpoint. For cycle awareness only; not contraception.',
    true,
  ),
  luteal(
    'Luteal Phase (Approx.)',
    'Post-ovulation phase leading up to your next period.',
    true,
  ),
  unknown(
    'Cycle Tracking',
    'Record your period to see personalized phase estimates.',
    false,
  );

  const CyclePhase(this.displayName, this.description, this.isApproximate);
  final String displayName;
  final String description;
  final bool isApproximate;
}

class CyclePrediction {
  const CyclePrediction({
    required this.hasData,
    this.cycleDay = 1,
    this.estimatedCycleLength = 28,
    this.estimatedPeriodDuration = 5,
    this.lastPeriodStartDate,
    this.nextPeriodDate,
    this.daysUntilNextPeriod = 0,
    this.phase = CyclePhase.unknown,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.estimatedOvulationDate,
    this.isPeriodOngoing = false,
    this.ongoingDurationDays = 0,
    this.historicalCycleCount = 0,
    this.isUsingHistoricalAverage = false,
  });

  /// True if at least one period or baseline date is available.
  final bool hasData;

  /// Current day in cycle (Day 1 is first day of period).
  final int cycleDay;

  /// Estimated cycle length in days (historical average or configured baseline).
  final int estimatedCycleLength;

  /// Estimated period duration in days.
  final int estimatedPeriodDuration;

  /// Start date of current or most recent period.
  final DateTime? lastPeriodStartDate;

  /// Estimated start date of the next period.
  final DateTime? nextPeriodDate;

  /// Days remaining until the estimated next period. Negative if past due.
  final int daysUntilNextPeriod;

  /// Current estimated phase of cycle.
  final CyclePhase phase;

  /// Approximate start of fertile window (approx. 5 days prior to ovulation).
  final DateTime? fertileWindowStart;

  /// Approximate end of fertile window (approx. 1 day after ovulation).
  final DateTime? fertileWindowEnd;

  /// Approximate ovulation date.
  final DateTime? estimatedOvulationDate;

  /// Whether current period is ongoing.
  final bool isPeriodOngoing;

  /// Duration in days if period is currently ongoing.
  final int ongoingDurationDays;

  /// Number of valid historical cycles used in prediction.
  final int historicalCycleCount;

  /// Whether prediction is based on real user cycle history rather than static defaults.
  final bool isUsingHistoricalAverage;

  /// Empty state when no periods or settings are logged.
  static const empty = CyclePrediction(hasData: false);

  /// Progress through the current cycle as a ratio from 0.0 to 1.0.
  double get cycleProgress {
    if (!hasData || estimatedCycleLength <= 0) return 0.0;
    final progress = cycleDay / estimatedCycleLength;
    return progress.clamp(0.0, 1.0);
  }

  /// Whether a specific date falls within the estimated next period window.
  bool isDateInPredictedPeriod(DateTime date) {
    if (nextPeriodDate == null) return false;
    final d = AppDateUtils.dateOnly(date);
    final end = nextPeriodDate!.add(
      Duration(days: estimatedPeriodDuration - 1),
    );
    return !d.isBefore(nextPeriodDate!) && !d.isAfter(end);
  }

  /// Whether a specific date falls in the approximate fertile window.
  bool isDateInFertileWindow(DateTime date) {
    if (fertileWindowStart == null || fertileWindowEnd == null) return false;
    final d = AppDateUtils.dateOnly(date);
    return !d.isBefore(fertileWindowStart!) && !d.isAfter(fertileWindowEnd!);
  }
}
