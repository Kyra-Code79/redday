import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../core/utils/date_utils.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  /// Loads current user cycle settings and reminder preferences.
  Future<AppSettings> getSettings() async {
    final db = await _db;
    final maps = await db.query('app_settings');

    final map = <String, String>{};
    for (final row in maps) {
      map[row['key'] as String] = row['value'] as String;
    }

    return AppSettings.fromMap(map);
  }

  /// Saves updated settings.
  Future<void> saveSettings(AppSettings settings) async {
    final db = await _db;
    final map = settings.toMap();

    await db.transaction((txn) async {
      for (final entry in map.entries) {
        await txn.insert(
          'app_settings',
          {'key': entry.key, 'value': entry.value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Updates a single key in the settings table.
  Future<void> updateSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Sets the baseline last period start date from onboarding or settings.
  Future<void> setLastPeriodStart(DateTime? date) async {
    if (date == null) {
      final db = await _db;
      await db.delete(
        'app_settings',
        where: 'key = ?',
        whereArgs: [AppConstants.settingLastPeriodStart],
      );
    } else {
      await updateSetting(
        AppConstants.settingLastPeriodStart,
        AppDateUtils.formatIso(date),
      );
    }
  }
}
