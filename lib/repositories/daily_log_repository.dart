import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../core/utils/date_utils.dart';
import '../models/daily_log.dart';
import '../models/symptom.dart';

class DailyLogRepository {
  DailyLogRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  /// Retrieves the daily log for a specific date (if any).
  Future<DailyLog?> getLogForDate(DateTime date) async {
    final db = await _db;
    final isoDate = AppDateUtils.formatIso(date);

    final maps = await db.query(
      'daily_logs',
      where: 'log_date = ?',
      whereArgs: [isoDate],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final logMap = maps.first;
    final logId = logMap['id'] as int;
    final symptoms = await _getSymptomsForLogId(logId);

    return DailyLog.fromMap(logMap, symptoms: symptoms);
  }

  /// Retrieves all logs between two dates inclusive.
  Future<List<DailyLog>> getLogsBetween(DateTime start, DateTime end) async {
    final db = await _db;
    final startIso = AppDateUtils.formatIso(start);
    final endIso = AppDateUtils.formatIso(end);

    final maps = await db.query(
      'daily_logs',
      where: 'log_date >= ? AND log_date <= ?',
      whereArgs: [startIso, endIso],
      orderBy: 'log_date ASC',
    );

    final results = <DailyLog>[];
    for (final map in maps) {
      final logId = map['id'] as int;
      final symptoms = await _getSymptomsForLogId(logId);
      results.add(DailyLog.fromMap(map, symptoms: symptoms));
    }
    return results;
  }

  /// Retrieves all recorded daily logs.
  Future<List<DailyLog>> getAllLogs() async {
    final db = await _db;
    final maps = await db.query(
      'daily_logs',
      orderBy: 'log_date DESC',
    );

    final results = <DailyLog>[];
    for (final map in maps) {
      final logId = map['id'] as int;
      final symptoms = await _getSymptomsForLogId(logId);
      results.add(DailyLog.fromMap(map, symptoms: symptoms));
    }
    return results;
  }

  Future<List<SymptomEntry>> _getSymptomsForLogId(int logId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT s.id, s.name, dls.severity
      FROM daily_log_symptoms dls
      INNER JOIN symptoms s ON s.id = dls.symptom_id
      WHERE dls.daily_log_id = ?
      ORDER BY s.name ASC
    ''', [logId]);

    return maps.map((row) {
      return SymptomEntry(
        symptom: Symptom(
          id: row['id'] as int,
          name: row['name'] as String,
        ),
        severity: SymptomSeverity.fromValue(row['severity'] as String),
      );
    }).toList();
  }

  /// Saves (inserts or updates) a daily log with all symptom entries in a transaction.
  Future<DailyLog> saveLog(DailyLog log) async {
    final db = await _db;
    final now = DateTime.now();
    final isoDate = AppDateUtils.formatIso(log.logDate);

    return await db.transaction((txn) async {
      // Check if a record already exists for this date
      final existing = await txn.query(
        'daily_logs',
        where: 'log_date = ?',
        whereArgs: [isoDate],
        limit: 1,
      );

      int logId;
      if (existing.isNotEmpty) {
        logId = existing.first['id'] as int;
        await txn.update(
          'daily_logs',
          {
            'flow_intensity': log.flowIntensity?.value,
            'notes': log.notes,
            'updated_at': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [logId],
        );
      } else {
        logId = await txn.insert(
          'daily_logs',
          {
            'log_date': isoDate,
            'flow_intensity': log.flowIntensity?.value,
            'notes': log.notes,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
        );
      }

      // Sync symptoms
      await txn.delete(
        'daily_log_symptoms',
        where: 'daily_log_id = ?',
        whereArgs: [logId],
      );

      for (final entry in log.symptoms) {
        var symptomId = entry.symptom.id;
        if (symptomId == null) {
          final symRows = await txn.query(
            'symptoms',
            where: 'name = ?',
            whereArgs: [entry.symptom.name],
            limit: 1,
          );
          if (symRows.isNotEmpty) {
            symptomId = symRows.first['id'] as int;
          } else {
            symptomId = await txn.insert(
              'symptoms',
              {'name': entry.symptom.name},
            );
          }
        }

        await txn.insert(
          'daily_log_symptoms',
          {
            'daily_log_id': logId,
            'symptom_id': symptomId,
            'severity': entry.severity.value,
          },
        );
      }

      return log.copyWith(
        id: logId,
        updatedAt: now,
      );
    });
  }

  /// Deletes a daily log by ID.
  Future<void> deleteLog(int id) async {
    final db = await _db;
    await db.delete(
      'daily_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a daily log by date.
  Future<void> deleteLogForDate(DateTime date) async {
    final db = await _db;
    final iso = AppDateUtils.formatIso(date);
    await db.delete(
      'daily_logs',
      where: 'log_date = ?',
      whereArgs: [iso],
    );
  }

  /// Retrieves the list of available symptoms in the dictionary.
  Future<List<Symptom>> getAllSymptoms() async {
    final db = await _db;
    final maps = await db.query('symptoms', orderBy: 'name ASC');
    return maps.map(Symptom.fromMap).toList();
  }

  /// Calculates frequency count for recorded symptoms.
  Future<Map<String, int>> getSymptomFrequencies() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT s.name, COUNT(dls.symptom_id) as count
      FROM daily_log_symptoms dls
      INNER JOIN symptoms s ON s.id = dls.symptom_id
      GROUP BY s.name
      ORDER BY count DESC
    ''');

    final results = <String, int>{};
    for (final row in maps) {
      results[row['name'] as String] = row['count'] as int;
    }
    return results;
  }
}
