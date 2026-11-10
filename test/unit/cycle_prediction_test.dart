import 'package:flutter_test/flutter_test.dart';
import 'package:redday/models/app_settings.dart';
import 'package:redday/models/cycle_prediction.dart';
import 'package:redday/models/period.dart';
import 'package:redday/services/cycle_prediction_service.dart';

void main() {
  const service = CyclePredictionService();

  group('CyclePredictionService Baseline Tests', () {
    test('Returns empty prediction when no periods and no baseline setting exist', () {
      final prediction = service.calculatePrediction(
        periods: [],
        settings: const AppSettings(lastPeriodStart: null),
        referenceDate: DateTime(2026, 10, 14),
      );

      expect(prediction.hasData, isFalse);
      expect(prediction.phase, equals(CyclePhase.unknown));
      expect(prediction.cycleProgress, equals(0.0));
    });

    test('Uses configured cycle length and duration when only 1 period is recorded', () {
      // Last period started Oct 1, 2026. Configured cycle: 28 days, duration: 5 days.
      final periods = [
        Period(
          id: 1,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 5),
        ),
      ];
      const settings = AppSettings(
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );

      // On Oct 12, 2026 -> Cycle Day 12
      final prediction = service.calculatePrediction(
        periods: periods,
        settings: settings,
        referenceDate: DateTime(2026, 10, 12),
      );

      expect(prediction.hasData, isTrue);
      expect(prediction.cycleDay, equals(12));
      expect(prediction.estimatedCycleLength, equals(28));
      expect(prediction.estimatedPeriodDuration, equals(5));
      // Next period: Oct 1 + 28 days = Oct 29
      expect(prediction.nextPeriodDate, equals(DateTime(2026, 10, 29)));
      // Days until next period: Oct 12 to Oct 29 = 17 days
      expect(prediction.daysUntilNextPeriod, equals(17));
      expect(prediction.isUsingHistoricalAverage, isFalse);
    });

    test('Uses setting baseline lastPeriodStart when periods list is empty', () {
      final settings = AppSettings(
        lastPeriodStart: DateTime(2026, 10, 1),
        averageCycleLength: 30,
        averagePeriodDuration: 6,
      );

      final prediction = service.calculatePrediction(
        periods: [],
        settings: settings,
        referenceDate: DateTime(2026, 10, 11),
      );

      expect(prediction.hasData, isTrue);
      expect(prediction.cycleDay, equals(11));
      expect(prediction.estimatedCycleLength, equals(30));
      expect(prediction.nextPeriodDate, equals(DateTime(2026, 10, 31)));
    });
  });

  group('CyclePredictionService Historical Cycle Tests', () {
    test('Calculates historical average from consecutive periods', () {
      // Period 1: Aug 1 -> Aug 5
      // Period 2: Aug 31 -> Sep 4 (Cycle 1 length: 30 days)
      // Period 3: Sep 29 -> Oct 3 (Cycle 2 length: 29 days)
      final periods = [
        Period(
          id: 1,
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 5),
        ),
        Period(
          id: 2,
          startDate: DateTime(2026, 8, 31),
          endDate: DateTime(2026, 9, 4),
        ),
        Period(
          id: 3,
          startDate: DateTime(2026, 9, 29),
          endDate: DateTime(2026, 10, 3),
        ),
      ];

      const settings = AppSettings(averageCycleLength: 28);

      final prediction = service.calculatePrediction(
        periods: periods,
        settings: settings,
        referenceDate: DateTime(2026, 10, 14),
      );

      expect(prediction.hasData, isTrue);
      expect(prediction.isUsingHistoricalAverage, isTrue);
      expect(prediction.historicalCycleCount, equals(2));
      // Average of 30 and 29 is (59 / 2).round() = 30
      expect(prediction.estimatedCycleLength, equals(30));
      // Next period from Sep 29 + 30 days = Oct 29
      expect(prediction.nextPeriodDate, equals(DateTime(2026, 10, 29)));
      // Cycle Day: Sep 29 to Oct 14 is 15 days + 1 = Day 16
      expect(prediction.cycleDay, equals(16));
    });

    test('Excludes invalid cycle lengths (< 15 or > 60 days) and falls back to baseline', () {
      // Period 1: Sep 1
      // Period 2: Sep 5 (Cycle length: 4 days - clinically invalid/duplicate)
      final periods = [
        Period(id: 1, startDate: DateTime(2026, 9, 1), endDate: DateTime(2026, 9, 4)),
        Period(id: 2, startDate: DateTime(2026, 9, 5), endDate: DateTime(2026, 9, 8)),
      ];

      const settings = AppSettings(averageCycleLength: 28);

      final prediction = service.calculatePrediction(
        periods: periods,
        settings: settings,
        referenceDate: DateTime(2026, 9, 15),
      );

      // The 4-day interval should be rejected, so fallback to settings cycle length
      expect(prediction.isUsingHistoricalAverage, isFalse);
      expect(prediction.estimatedCycleLength, equals(28));
    });

    test('Trims extreme outliers when 4 or more valid cycles exist', () {
      // Intervals: 28, 28, 29, 50 (50 is an extreme single illness outlier)
      // With trimmed mean: min (28) and max (50) trimmed -> average of (28, 29) = 29
      final periods = [
        Period(id: 1, startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 1, 5)),
        Period(id: 2, startDate: DateTime(2026, 1, 29), endDate: DateTime(2026, 2, 2)), // 28d
        Period(id: 3, startDate: DateTime(2026, 2, 26), endDate: DateTime(2026, 3, 2)), // 28d
        Period(id: 4, startDate: DateTime(2026, 3, 27), endDate: DateTime(2026, 3, 31)), // 29d
        Period(id: 5, startDate: DateTime(2026, 5, 16), endDate: DateTime(2026, 5, 20)), // 50d
      ];

      final prediction = service.calculatePrediction(
        periods: periods,
        settings: const AppSettings(averageCycleLength: 28),
        referenceDate: DateTime(2026, 5, 25),
      );

      expect(prediction.isUsingHistoricalAverage, isTrue);
      expect(prediction.estimatedCycleLength, equals(29));
    });
  });

  group('CyclePredictionService Ongoing and Phase Tests', () {
    test('Correctly identifies ongoing period', () {
      final periods = [
        Period(
          id: 1,
          startDate: DateTime(2026, 10, 10),
          endDate: null, // ongoing
        ),
      ];

      final prediction = service.calculatePrediction(
        periods: periods,
        settings: const AppSettings(),
        referenceDate: DateTime(2026, 10, 14),
      );

      expect(prediction.isPeriodOngoing, isTrue);
      // Oct 10 to Oct 14 is 5 days inclusive
      expect(prediction.ongoingDurationDays, equals(5));
      expect(prediction.phase, equals(CyclePhase.menstrual));
    });

    test('Calculates approximate fertile window and ovulation', () {
      final periods = [
        Period(
          id: 1,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 5),
        ),
      ];

      final prediction = service.calculatePrediction(
        periods: periods,
        settings: const AppSettings(averageCycleLength: 28),
        referenceDate: DateTime(2026, 10, 10),
      );

      // Next period: Oct 29. Ovulation: Oct 29 - 14d = Oct 15
      expect(prediction.estimatedOvulationDate, equals(DateTime(2026, 10, 15)));
      // Fertile window: Oct 15 - 5d (Oct 10) to Oct 15 + 1d (Oct 16)
      expect(prediction.fertileWindowStart, equals(DateTime(2026, 10, 10)));
      expect(prediction.fertileWindowEnd, equals(DateTime(2026, 10, 16)));

      expect(prediction.isDateInFertileWindow(DateTime(2026, 10, 10)), isTrue);
      expect(prediction.isDateInFertileWindow(DateTime(2026, 10, 15)), isTrue);
      expect(prediction.isDateInFertileWindow(DateTime(2026, 10, 16)), isTrue);
      expect(prediction.isDateInFertileWindow(DateTime(2026, 10, 9)), isFalse);
      expect(prediction.isDateInFertileWindow(DateTime(2026, 10, 17)), isFalse);
    });
  });

  group('CyclePredictionService Stats Aggregation', () {
    test('Calculates cycle stats summary and range correctly', () {
      final periods = [
        Period(id: 1, startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 6, 5)), // dur: 5
        Period(id: 2, startDate: DateTime(2026, 6, 29), endDate: DateTime(2026, 7, 4)), // len: 28, dur: 6
        Period(id: 3, startDate: DateTime(2026, 7, 31), endDate: DateTime(2026, 8, 4)), // len: 32, dur: 5
      ];

      final stats = service.calculateStats(
        periods: periods,
        settings: const AppSettings(),
      );

      expect(stats.totalPeriods, equals(3));
      expect(stats.shortestCycle, equals(28));
      expect(stats.longestCycle, equals(32));
      expect(stats.averageCycleLength, equals(30.0));
      expect(stats.hasEnoughDataForVariation, isTrue);
    });
  });
}
