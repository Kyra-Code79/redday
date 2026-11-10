import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../models/app_settings.dart';
import '../models/cycle_prediction.dart';
import '../models/period.dart';

class CycleStats {
  const CycleStats({
    required this.averageCycleLength,
    required this.averagePeriodDuration,
    required this.totalPeriods,
    required this.shortestCycle,
    required this.longestCycle,
    required this.cycleHistory,
    required this.durationHistory,
    required this.hasEnoughDataForVariation,
  });

  final double averageCycleLength;
  final double averagePeriodDuration;
  final int totalPeriods;
  final int? shortestCycle;
  final int? longestCycle;
  final List<CycleHistoryItem> cycleHistory;
  final List<DurationHistoryItem> durationHistory;
  final bool hasEnoughDataForVariation;

  static const empty = CycleStats(
    averageCycleLength: 28,
    averagePeriodDuration: 5,
    totalPeriods: 0,
    shortestCycle: null,
    longestCycle: null,
    cycleHistory: [],
    durationHistory: [],
    hasEnoughDataForVariation: false,
  );
}

class CycleHistoryItem {
  const CycleHistoryItem({
    required this.startDate,
    required this.cycleLengthDays,
  });

  final DateTime startDate;
  final int cycleLengthDays;
}

class DurationHistoryItem {
  const DurationHistoryItem({
    required this.startDate,
    required this.durationDays,
  });

  final DateTime startDate;
  final int durationDays;
}

/// Pure Dart cycle calculation and prediction engine.
///
/// Definitions:
/// - Cycle day 1 is the first day of menstrual bleeding.
/// - Cycle length is the calendar days between the first day of consecutive periods.
/// - Period duration is the inclusive number of days in the recorded menstrual interval.
class CyclePredictionService {
  const CyclePredictionService();

  /// Calculates the cycle prediction based on recorded periods and fallback settings.
  CyclePrediction calculatePrediction({
    required List<Period> periods,
    required AppSettings settings,
    DateTime? referenceDate,
  }) {
    final today = AppDateUtils.dateOnly(referenceDate ?? DateTime.now());

    // Sort periods ascending for chronological analysis
    final sorted = List<Period>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Determine baseline period start date
    DateTime? baselineStart;
    Period? latestPeriod;
    bool isOngoing = false;
    int ongoingDays = 0;

    if (sorted.isNotEmpty) {
      latestPeriod = sorted.last;
      baselineStart = latestPeriod.startDate;
      if (latestPeriod.isOngoing) {
        isOngoing = true;
        ongoingDays = AppDateUtils.inclusiveDaysBetween(
          latestPeriod.startDate,
          today,
        );
      }
    } else if (settings.lastPeriodStart != null) {
      baselineStart = AppDateUtils.dateOnly(settings.lastPeriodStart!);
    }

    if (baselineStart == null) {
      return CyclePrediction.empty;
    }

    // Calculate historical cycle lengths between consecutive period start dates
    final validCycleLengths = <int>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final currentStart = sorted[i].startDate;
      final nextStart = sorted[i + 1].startDate;
      final length = AppDateUtils.daysBetween(currentStart, nextStart);

      // Exclude invalid or duplicate cycles (clinically outside normal physiological range)
      if (length >= AppConstants.minCycleLengthDays &&
          length <= AppConstants.maxCycleLengthDays) {
        validCycleLengths.add(length);
      }
    }

    // Determine estimated cycle length
    final int estimatedCycleLength;
    final bool isUsingHistoricalAverage;
    if (validCycleLengths.isNotEmpty) {
      estimatedCycleLength = _calculateRobustAverage(validCycleLengths);
      isUsingHistoricalAverage = true;
    } else {
      estimatedCycleLength = settings.averageCycleLength;
      isUsingHistoricalAverage = false;
    }

    // Calculate historical period durations
    final validDurations = <int>[];
    for (final p in sorted) {
      if (p.endDate != null) {
        final dur = p.durationInDays;
        if (dur >= AppConstants.minPeriodDurationDays &&
            dur <= AppConstants.maxPeriodDurationDays) {
          validDurations.add(dur);
        }
      }
    }

    final int estimatedPeriodDuration;
    if (validDurations.isNotEmpty) {
      estimatedPeriodDuration =
          (validDurations.reduce((a, b) => a + b) / validDurations.length)
              .round();
    } else {
      estimatedPeriodDuration = settings.averagePeriodDuration;
    }

    // Cycle day calculation (Day 1 = first day of period)
    final daysSinceStart = AppDateUtils.daysBetween(baselineStart, today);
    final int cycleDay;
    if (daysSinceStart >= 0) {
      cycleDay = daysSinceStart + 1;
    } else {
      cycleDay = 1;
    }

    // Predict next period date
    final nextPeriodDate = baselineStart.add(
      Duration(days: estimatedCycleLength),
    );
    final daysUntilNext = AppDateUtils.daysBetween(today, nextPeriodDate);

    // Approximate ovulation and fertile window calculations
    // Clinically, luteal phase is relatively consistent (~14 days before next period)
    final approxOvulationDate = nextPeriodDate.subtract(
      const Duration(days: AppConstants.standardLutealPhaseDays),
    );
    // Fertile window spans approx 5 days before ovulation up to 1 day post-ovulation
    final fertileWindowStart = approxOvulationDate.subtract(
      const Duration(days: 5),
    );
    final fertileWindowEnd = approxOvulationDate.add(
      const Duration(days: 1),
    );

    // Estimate current phase
    final CyclePhase phase;
    if (isOngoing || (latestPeriod != null && latestPeriod.containsDate(today))) {
      phase = CyclePhase.menstrual;
    } else if (cycleDay <= estimatedPeriodDuration) {
      phase = CyclePhase.menstrual;
    } else if (today.isBefore(fertileWindowStart)) {
      phase = CyclePhase.follicular;
    } else if (!today.isBefore(fertileWindowStart) &&
        !today.isAfter(fertileWindowEnd)) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    return CyclePrediction(
      hasData: true,
      cycleDay: cycleDay,
      estimatedCycleLength: estimatedCycleLength,
      estimatedPeriodDuration: estimatedPeriodDuration,
      lastPeriodStartDate: baselineStart,
      nextPeriodDate: nextPeriodDate,
      daysUntilNextPeriod: daysUntilNext,
      phase: phase,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      estimatedOvulationDate: approxOvulationDate,
      isPeriodOngoing: isOngoing,
      ongoingDurationDays: ongoingDays,
      historicalCycleCount: validCycleLengths.length,
      isUsingHistoricalAverage: isUsingHistoricalAverage,
    );
  }

  /// Robust average of recent cycles (up to last 6 cycles).
  /// If 4 or more cycles are available, uses a trimmed mean to drop extreme single anomalies.
  int _calculateRobustAverage(List<int> lengths) {
    if (lengths.isEmpty) return AppConstants.defaultCycleLengthDays;
    if (lengths.length == 1) return lengths.first;

    // Take up to the most recent 6 cycles
    final recent = lengths.length > 6
        ? lengths.sublist(lengths.length - 6)
        : List<int>.from(lengths);

    if (recent.length >= 4) {
      recent.sort();
      // Drop lowest and highest outlier
      final trimmed = recent.sublist(1, recent.length - 1);
      final sum = trimmed.reduce((a, b) => a + b);
      return (sum / trimmed.length).round();
    }

    final sum = recent.reduce((a, b) => a + b);
    return (sum / recent.length).round();
  }

  /// Calculates statistical aggregates and historical series for Insights.
  CycleStats calculateStats({
    required List<Period> periods,
    required AppSettings settings,
  }) {
    final sorted = List<Period>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (sorted.isEmpty) {
      return CycleStats.empty.copyWith(
        averageCycleLength: settings.averageCycleLength.toDouble(),
        averagePeriodDuration: settings.averagePeriodDuration.toDouble(),
      );
    }

    final cycleHistory = <CycleHistoryItem>[];
    final durationHistory = <DurationHistoryItem>[];
    final validLengths = <int>[];
    final validDurations = <int>[];

    // Compute cycle lengths
    for (var i = 0; i < sorted.length - 1; i++) {
      final currentStart = sorted[i].startDate;
      final nextStart = sorted[i + 1].startDate;
      final len = AppDateUtils.daysBetween(currentStart, nextStart);

      if (len >= AppConstants.minCycleLengthDays &&
          len <= AppConstants.maxCycleLengthDays) {
        validLengths.add(len);
        cycleHistory.add(
          CycleHistoryItem(startDate: currentStart, cycleLengthDays: len),
        );
      }
    }

    // Compute period durations
    for (final p in sorted) {
      if (p.endDate != null) {
        final dur = p.durationInDays;
        if (dur >= AppConstants.minPeriodDurationDays &&
            dur <= AppConstants.maxPeriodDurationDays) {
          validDurations.add(dur);
          durationHistory.add(
            DurationHistoryItem(startDate: p.startDate, durationDays: dur),
          );
        }
      }
    }

    final double avgCycle = validLengths.isNotEmpty
        ? validLengths.reduce((a, b) => a + b) / validLengths.length
        : settings.averageCycleLength.toDouble();

    final double avgDuration = validDurations.isNotEmpty
        ? validDurations.reduce((a, b) => a + b) / validDurations.length
        : settings.averagePeriodDuration.toDouble();

    int? shortest;
    int? longest;
    if (validLengths.isNotEmpty) {
      shortest = validLengths.reduce((a, b) => a < b ? a : b);
      longest = validLengths.reduce((a, b) => a > b ? a : b);
    }

    return CycleStats(
      averageCycleLength: avgCycle,
      averagePeriodDuration: avgDuration,
      totalPeriods: sorted.length,
      shortestCycle: shortest,
      longestCycle: longest,
      cycleHistory: cycleHistory,
      durationHistory: durationHistory,
      hasEnoughDataForVariation: validLengths.length >= 2,
    );
  }
}

extension CycleStatsExtension on CycleStats {
  CycleStats copyWith({
    double? averageCycleLength,
    double? averagePeriodDuration,
    int? totalPeriods,
    int? shortestCycle,
    int? longestCycle,
    List<CycleHistoryItem>? cycleHistory,
    List<DurationHistoryItem>? durationHistory,
    bool? hasEnoughDataForVariation,
  }) {
    return CycleStats(
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration:
          averagePeriodDuration ?? this.averagePeriodDuration,
      totalPeriods: totalPeriods ?? this.totalPeriods,
      shortestCycle: shortestCycle ?? this.shortestCycle,
      longestCycle: longestCycle ?? this.longestCycle,
      cycleHistory: cycleHistory ?? this.cycleHistory,
      durationHistory: durationHistory ?? this.durationHistory,
      hasEnoughDataForVariation:
          hasEnoughDataForVariation ?? this.hasEnoughDataForVariation,
    );
  }
}
