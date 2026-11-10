import '../core/utils/date_utils.dart';

class Period {
  const Period({
    this.id,
    required this.startDate,
    this.endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? startDate,
        updatedAt = updatedAt ?? startDate;

  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether this period is currently ongoing (no end date recorded).
  bool get isOngoing => endDate == null;

  /// Duration in days. If ongoing, calculates days elapsed up to today or at least 1 day.
  int get durationInDays {
    if (endDate != null) {
      return AppDateUtils.inclusiveDaysBetween(startDate, endDate!);
    }
    final today = AppDateUtils.today;
    if (today.isBefore(startDate)) return 1;
    return AppDateUtils.inclusiveDaysBetween(startDate, today);
  }

  /// Checks if [date] falls within this period's recorded range.
  bool containsDate(DateTime date) {
    final d = AppDateUtils.dateOnly(date);
    if (d.isBefore(startDate)) return false;
    if (endDate != null) {
      return !d.isAfter(endDate!);
    }
    // If ongoing, check if date is between start and today
    return !d.isAfter(AppDateUtils.today);
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'start_date': AppDateUtils.formatIso(startDate),
      'end_date': endDate != null ? AppDateUtils.formatIso(endDate!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Period.fromMap(Map<String, dynamic> map) {
    return Period(
      id: map['id'] as int?,
      startDate: AppDateUtils.parseIso(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? AppDateUtils.parseIso(map['end_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Period copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Period(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Period &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          AppDateUtils.isSameDay(startDate, other.startDate) &&
          AppDateUtils.isSameDay(endDate, other.endDate);

  @override
  int get hashCode => id.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}
