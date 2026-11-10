import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';
import '../core/database/app_database.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/date_utils.dart';
import '../models/app_settings.dart';
import '../repositories/daily_log_repository.dart';
import '../repositories/period_repository.dart';
import '../repositories/settings_repository.dart';

class ImportResult {
  const ImportResult({
    required this.periodsImported,
    required this.periodsSkipped,
    required this.logsImported,
    required this.logsSkipped,
  });

  final int periodsImported;
  final int periodsSkipped;
  final int logsImported;
  final int logsSkipped;
}

class ExportService {
  ExportService({
    PeriodRepository? periodRepository,
    DailyLogRepository? dailyLogRepository,
    SettingsRepository? settingsRepository,
  })  : _periodRepo = periodRepository ?? PeriodRepository(),
        _dailyLogRepo = dailyLogRepository ?? DailyLogRepository(),
        _settingsRepo = settingsRepository ?? SettingsRepository();

  final PeriodRepository _periodRepo;
  final DailyLogRepository _dailyLogRepo;
  final SettingsRepository _settingsRepo;

  /// Generates complete JSON representation of user data.
  Future<String> generateExportJson() async {
    final periods = await _periodRepo.getAllPeriods();
    final logs = await _dailyLogRepo.getAllLogs();
    final settings = await _settingsRepo.getSettings();

    final data = {
      'app': AppConstants.appName,
      'schema_version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'settings': settings.toMap(),
      'periods': periods
          .map((p) => {
                'start_date': AppDateUtils.formatIso(p.startDate),
                'end_date': p.endDate != null
                    ? AppDateUtils.formatIso(p.endDate!)
                    : null,
                'created_at': p.createdAt.toIso8601String(),
              })
          .toList(),
      'daily_logs': logs
          .map((l) => {
                'log_date': AppDateUtils.formatIso(l.logDate),
                'flow_intensity': l.flowIntensity?.value,
                'notes': l.notes,
                'symptoms': l.symptoms
                    .map((s) => {
                          'name': s.symptom.name,
                          'severity': s.severity.value,
                        })
                    .toList(),
                'created_at': l.createdAt.toIso8601String(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Exports data to device storage via SAF (Storage Access Framework).
  Future<String?> exportToFile() async {
    final jsonString = await generateExportJson();
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    final filename =
        'redday_backup_${AppDateUtils.formatIso(DateTime.now())}.json';

    final uri = await FilePicker.saveFile(
      dialogTitle: 'Export RedDay Tracking Data',
      fileName: filename,
      bytes: bytes,
      mimeType: 'application/json',
    );

    return uri?.toString();
  }

  /// Parses and validates JSON backup content.
  Map<String, dynamic> validateAndParseJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw ImportExportException('Invalid backup file format: Root is not a JSON object.');
      }

      if (decoded['app'] != AppConstants.appName && decoded['app'] != 'RedDay') {
        throw ImportExportException(
          'Incompatible backup file. Expected ${AppConstants.appName} data.',
        );
      }

      return decoded;
    } on FormatException catch (e) {
      throw ImportExportException('Invalid JSON formatting: ${e.message}');
    }
  }

  /// Imports validated backup into SQLite database, deduplicating records.
  Future<ImportResult> importFromJson(String jsonString) async {
    final data = validateAndParseJson(jsonString);

    final rawPeriods = data['periods'] as List<dynamic>? ?? [];
    final rawLogs = data['daily_logs'] as List<dynamic>? ?? [];
    final rawSettings = data['settings'] as Map<String, dynamic>?;

    var periodsImported = 0;
    var periodsSkipped = 0;
    var logsImported = 0;
    var logsSkipped = 0;

    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      // 1. Import settings if present
      if (rawSettings != null) {
        final stringMap = rawSettings.map(
          (k, v) => MapEntry(k, v.toString()),
        );
        final importedSettings = AppSettings.fromMap(stringMap);
        for (final entry in importedSettings.toMap().entries) {
          await txn.insert(
            'app_settings',
            {'key': entry.key, 'value': entry.value},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      // 2. Import periods
      final existingPeriods = await _periodRepo.getAllPeriods();
      for (final raw in rawPeriods) {
        if (raw is! Map<String, dynamic>) continue;
        try {
          final startDateStr = raw['start_date'] as String?;
          if (startDateStr == null) continue;
          final start = AppDateUtils.parseIso(startDateStr);
          final endDateStr = raw['end_date'] as String?;
          final end =
              endDateStr != null ? AppDateUtils.parseIso(endDateStr) : null;

          // Check for duplicate start date
          final isDuplicate = existingPeriods.any(
            (p) => AppDateUtils.isSameDay(p.startDate, start),
          );

          if (isDuplicate) {
            periodsSkipped++;
            continue;
          }

          final now = DateTime.now();
          await txn.insert('periods', {
            'start_date': AppDateUtils.formatIso(start),
            'end_date': end != null ? AppDateUtils.formatIso(end) : null,
            'created_at': raw['created_at'] ?? now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
          periodsImported++;
        } catch (_) {
          periodsSkipped++;
        }
      }

      // 3. Import daily logs
      for (final raw in rawLogs) {
        if (raw is! Map<String, dynamic>) continue;
        try {
          final logDateStr = raw['log_date'] as String?;
          if (logDateStr == null) continue;
          final logDate = AppDateUtils.parseIso(logDateStr);
          final isoDate = AppDateUtils.formatIso(logDate);

          // Check if log already exists for this date
          final existing = await txn.query(
            'daily_logs',
            where: 'log_date = ?',
            whereArgs: [isoDate],
          );

          if (existing.isNotEmpty) {
            logsSkipped++;
            continue;
          }

          final now = DateTime.now();
          final logId = await txn.insert('daily_logs', {
            'log_date': isoDate,
            'flow_intensity': raw['flow_intensity'],
            'notes': raw['notes'],
            'created_at': raw['created_at'] ?? now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });

          // Symptoms
          final rawSymptoms = raw['symptoms'] as List<dynamic>? ?? [];
          for (final rawSym in rawSymptoms) {
            if (rawSym is! Map<String, dynamic>) continue;
            final symName = rawSym['name'] as String?;
            final severityStr = rawSym['severity'] as String? ?? 'mild';
            if (symName == null) continue;

            // Find or insert symptom ID
            final symRows = await txn.query(
              'symptoms',
              where: 'name = ?',
              whereArgs: [symName],
              limit: 1,
            );

            int symId;
            if (symRows.isNotEmpty) {
              symId = symRows.first['id'] as int;
            } else {
              symId = await txn.insert('symptoms', {'name': symName});
            }

            await txn.insert('daily_log_symptoms', {
              'daily_log_id': logId,
              'symptom_id': symId,
              'severity': severityStr,
            });
          }
          logsImported++;
        } catch (_) {
          logsSkipped++;
        }
      }
    });

    return ImportResult(
      periodsImported: periodsImported,
      periodsSkipped: periodsSkipped,
      logsImported: logsImported,
      logsSkipped: logsSkipped,
    );
  }

  /// Picks and imports a file from user's storage.
  Future<ImportResult> importFromFile() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Select RedDay Backup File',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (file == null) {
      throw ImportExportException('No file was selected.');
    }

    final bytes = await file.readAsBytes();
    final content = utf8.decode(bytes);
    return await importFromJson(content);
  }
}
