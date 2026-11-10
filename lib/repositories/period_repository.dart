import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/date_utils.dart';
import '../models/period.dart';

class PeriodRepository {
  PeriodRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  /// Retrieves all recorded periods sorted chronologically descending (newest first).
  Future<List<Period>> getAllPeriods() async {
    final db = await _db;
    final maps = await db.query(
      'periods',
      orderBy: 'start_date DESC',
    );
    return maps.map(Period.fromMap).toList();
  }

  /// Retrieves a single period by ID.
  Future<Period?> getPeriodById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Period.fromMap(maps.first);
  }

  /// Finds any recorded period that covers [date].
  Future<Period?> getPeriodForDate(DateTime date) async {
    final periods = await getAllPeriods();
    final d = AppDateUtils.dateOnly(date);
    for (final p in periods) {
      if (p.containsDate(d)) return p;
    }
    return null;
  }

  /// Returns the most recently started period.
  Future<Period?> getLatestPeriod() async {
    final db = await _db;
    final maps = await db.query(
      'periods',
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Period.fromMap(maps.first);
  }

  /// Returns any currently ongoing period (where end_date is null).
  Future<Period?> getOngoingPeriod() async {
    final db = await _db;
    final maps = await db.query(
      'periods',
      where: 'end_date IS NULL',
      orderBy: 'start_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Period.fromMap(maps.first);
  }

  /// Validates a period record against logical rules and existing records.
  Future<void> validatePeriod(Period period, {int? excludeId}) async {
    final start = AppDateUtils.dateOnly(period.startDate);
    final end = period.endDate != null
        ? AppDateUtils.dateOnly(period.endDate!)
        : null;

    if (end != null && end.isBefore(start)) {
      throw ValidationException('Period end date cannot be earlier than start date.');
    }

    final allPeriods = await getAllPeriods();
    for (final existing in allPeriods) {
      if (excludeId != null && existing.id == excludeId) continue;

      final exStart = existing.startDate;
      final exEnd = existing.endDate ?? AppDateUtils.today;

      final effEnd = end ?? AppDateUtils.today;

      // Overlap occurs if start <= exEnd and effEnd >= exStart
      final overlaps = !start.isAfter(exEnd) && !effEnd.isBefore(exStart);
      if (overlaps) {
        throw ValidationException(
          'Dates overlap with an existing period (${AppDateUtils.formatShort(existing.startDate)} - '
          '${existing.endDate != null ? AppDateUtils.formatShort(existing.endDate!) : 'Ongoing'}).',
        );
      }
    }
  }

  /// Creates a new period record after validation.
  Future<Period> insertPeriod(Period period) async {
    await validatePeriod(period);

    final db = await _db;
    final now = DateTime.now();
    final toInsert = period.copyWith(
      startDate: AppDateUtils.dateOnly(period.startDate),
      endDate: period.endDate != null
          ? AppDateUtils.dateOnly(period.endDate!)
          : null,
      createdAt: now,
      updatedAt: now,
    );

    final id = await db.insert('periods', toInsert.toMap());
    return toInsert.copyWith(id: id);
  }

  /// Updates an existing period record after validation.
  Future<Period> updatePeriod(Period period) async {
    if (period.id == null) {
      throw ValidationException('Period ID is required for update.');
    }

    await validatePeriod(period, excludeId: period.id);

    final db = await _db;
    final now = DateTime.now();
    final toUpdate = period.copyWith(
      startDate: AppDateUtils.dateOnly(period.startDate),
      endDate: period.endDate != null
          ? AppDateUtils.dateOnly(period.endDate!)
          : null,
      updatedAt: now,
    );

    await db.update(
      'periods',
      toUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );

    return toUpdate;
  }

  /// Deletes a period by ID.
  Future<void> deletePeriod(int id) async {
    final db = await _db;
    await db.delete(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
