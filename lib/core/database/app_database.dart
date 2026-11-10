import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Allows injecting a database (useful for in-memory testing with sqflite_common_ffi).
  void setDatabaseForTesting(Database db) {
    _database = db;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.databaseName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize local database', e);
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // 1. Periods table
      await txn.execute('''
        CREATE TABLE periods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_date TEXT NOT NULL,
          end_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await txn.execute(
        'CREATE INDEX idx_periods_start_date ON periods(start_date)',
      );

      // 2. Daily logs table
      await txn.execute('''
        CREATE TABLE daily_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          log_date TEXT NOT NULL UNIQUE,
          flow_intensity TEXT,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await txn.execute(
        'CREATE INDEX idx_daily_logs_log_date ON daily_logs(log_date)',
      );

      // 3. Symptoms dictionary table
      await txn.execute('''
        CREATE TABLE symptoms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE
        )
      ''');

      // 4. Daily log symptoms bridge table
      await txn.execute('''
        CREATE TABLE daily_log_symptoms (
          daily_log_id INTEGER NOT NULL,
          symptom_id INTEGER NOT NULL,
          severity TEXT NOT NULL,
          PRIMARY KEY (daily_log_id, symptom_id),
          FOREIGN KEY (daily_log_id) REFERENCES daily_logs(id) ON DELETE CASCADE,
          FOREIGN KEY (symptom_id) REFERENCES symptoms(id) ON DELETE CASCADE
        )
      ''');
      await txn.execute(
        'CREATE INDEX idx_daily_log_symptoms_log_id ON daily_log_symptoms(daily_log_id)',
      );

      // 5. App settings table
      await txn.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      // Seed default symptoms
      final defaultSymptoms = [
        'Abdominal cramps',
        'Headache',
        'Back pain',
        'Bloating',
        'Fatigue',
        'Acne',
        'Breast tenderness',
        'Nausea',
        'Mood changes',
        'Irritability',
        'Anxiety',
        'Food cravings',
        'Sleep difficulties',
        'Other',
      ];

      for (final symptom in defaultSymptoms) {
        await txn.insert(
          'symptoms',
          {'name': symptom},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Seed default settings
      await txn.insert('app_settings', {
        'key': AppConstants.settingCycleLength,
        'value': AppConstants.defaultCycleLengthDays.toString(),
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodDuration,
        'value': AppConstants.defaultPeriodDurationDays.toString(),
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodReminderEnabled,
        'value': 'true',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodReminderDaysBefore,
        'value': '2',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingDailyReminderEnabled,
        'value': 'false',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingReminderTimeHour,
        'value': '20',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingReminderTimeMinute,
        'value': '0',
      });
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Database migrations for future versions
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Clears all tracking tables and resets default settings.
  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('daily_log_symptoms');
      await txn.delete('daily_logs');
      await txn.delete('periods');
      await txn.delete('app_settings');

      // Re-seed defaults
      await txn.insert('app_settings', {
        'key': AppConstants.settingCycleLength,
        'value': AppConstants.defaultCycleLengthDays.toString(),
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodDuration,
        'value': AppConstants.defaultPeriodDurationDays.toString(),
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodReminderEnabled,
        'value': 'true',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingPeriodReminderDaysBefore,
        'value': '2',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingDailyReminderEnabled,
        'value': 'false',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingReminderTimeHour,
        'value': '20',
      });
      await txn.insert('app_settings', {
        'key': AppConstants.settingReminderTimeMinute,
        'value': '0',
      });
    });
  }
}
