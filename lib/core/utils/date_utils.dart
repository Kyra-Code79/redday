import 'package:intl/intl.dart';

/// Date utility methods strictly handling date-only operations.
/// Prevents timezone or DST shifts from shifting calendar day calculations.
abstract final class AppDateUtils {
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _fullDateFormat = DateFormat('EEE, MMM d, yyyy');
  static final DateFormat _displayDateFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _weekdayShortFormat = DateFormat('E');

  /// Normalizes a DateTime to date-only (year, month, day) in local time.
  static DateTime dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Today normalized to midnight local time.
  static DateTime get today => dateOnly(DateTime.now());

  /// Formats date to ISO 8601 YYYY-MM-DD.
  static String formatIso(DateTime dt) => _isoFormat.format(dt);

  /// Parses ISO 8601 YYYY-MM-DD string to normalized DateTime.
  static DateTime parseIso(String isoString) {
    final parsed = _isoFormat.parseStrict(isoString);
    return dateOnly(parsed);
  }

  /// Formats for calendar month headers, e.g. "October 2026".
  static String formatMonthYear(DateTime dt) => _monthYearFormat.format(dt);

  /// Formats short date, e.g. "Oct 14".
  static String formatShort(DateTime dt) => _shortDateFormat.format(dt);

  /// Formats full date, e.g. "Wed, Oct 14, 2026".
  static String formatFull(DateTime dt) => _fullDateFormat.format(dt);

  /// Formats display date, e.g. "October 14, 2026".
  static String formatDisplay(DateTime dt) => _displayDateFormat.format(dt);

  /// Weekday abbreviation, e.g. "M", "T", "W".
  static String formatWeekdayShort(DateTime dt) =>
      _weekdayShortFormat.format(dt);

  /// Checks if two dates have the same calendar year, month, and day.
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculates number of calendar days between two dates inclusive of endpoints.
  /// E.g. Oct 1 to Oct 5 is 5 days.
  static int inclusiveDaysBetween(DateTime start, DateTime end) {
    final s = dateOnly(start);
    final e = dateOnly(end);
    return e.difference(s).inDays + 1;
  }

  /// Calculates calendar days difference from [from] to [to].
  /// E.g. Oct 1 to Oct 29 is 28 days.
  static int daysBetween(DateTime from, DateTime to) {
    final f = dateOnly(from);
    final t = dateOnly(to);
    return t.difference(f).inDays;
  }

  /// Checks if [target] falls within [start] and [end] inclusive.
  static bool isDateInRange(DateTime target, DateTime start, DateTime end) {
    final t = dateOnly(target);
    final s = dateOnly(start);
    final e = dateOnly(end);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  /// Returns the first day of the month for [dt].
  static DateTime firstDayOfMonth(DateTime dt) {
    return DateTime(dt.year, dt.month, 1);
  }

  /// Returns the last day of the month for [dt].
  static DateTime lastDayOfMonth(DateTime dt) {
    return DateTime(dt.year, dt.month + 1, 0);
  }
}
