import 'package:flutter_test/flutter_test.dart';
import 'package:redday/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('dateOnly strips hours, minutes, seconds and milliseconds', () {
      final dt = DateTime(2026, 10, 14, 15, 30, 45, 123);
      final normalized = AppDateUtils.dateOnly(dt);

      expect(normalized.year, 2026);
      expect(normalized.month, 10);
      expect(normalized.day, 14);
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
      expect(normalized.millisecond, 0);
    });

    test('formatIso and parseIso round-trip accurately', () {
      final original = DateTime(2026, 3, 5);
      final iso = AppDateUtils.formatIso(original);
      expect(iso, '2026-03-05');

      final parsed = AppDateUtils.parseIso(iso);
      expect(parsed, equals(original));
    });

    test('inclusiveDaysBetween calculates correct inclusive days', () {
      // Oct 1 to Oct 5 is 5 days inclusive (1, 2, 3, 4, 5)
      final start = DateTime(2026, 10, 1);
      final end = DateTime(2026, 10, 5);
      expect(AppDateUtils.inclusiveDaysBetween(start, end), 5);

      // Same day is 1 day
      expect(AppDateUtils.inclusiveDaysBetween(start, start), 1);
    });

    test('daysBetween calculates interval between dates', () {
      // Oct 1 to Oct 29 is 28 days
      final start = DateTime(2026, 10, 1);
      final next = DateTime(2026, 10, 29);
      expect(AppDateUtils.daysBetween(start, next), 28);
    });

    test('handles month and year boundaries correctly', () {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      expect(AppDateUtils.daysBetween(dec31, jan1), 1);
      expect(AppDateUtils.inclusiveDaysBetween(dec31, jan1), 2);
    });

    test('handles leap year correctly', () {
      // 2028 is a leap year (Feb 29 exists)
      final feb28 = DateTime(2028, 2, 28);
      final mar1 = DateTime(2028, 3, 1);
      expect(AppDateUtils.daysBetween(feb28, mar1), 2);

      final feb29 = DateTime(2028, 2, 29);
      expect(AppDateUtils.formatIso(feb29), '2028-02-29');
    });

    test('isDateInRange works for inclusive boundaries and interior dates', () {
      final start = DateTime(2026, 5, 10);
      final end = DateTime(2026, 5, 15);

      expect(AppDateUtils.isDateInRange(DateTime(2026, 5, 10), start, end), isTrue);
      expect(AppDateUtils.isDateInRange(DateTime(2026, 5, 12), start, end), isTrue);
      expect(AppDateUtils.isDateInRange(DateTime(2026, 5, 15), start, end), isTrue);
      expect(AppDateUtils.isDateInRange(DateTime(2026, 5, 9), start, end), isFalse);
      expect(AppDateUtils.isDateInRange(DateTime(2026, 5, 16), start, end), isFalse);
    });
  });
}
