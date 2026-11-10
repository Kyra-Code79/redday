import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:redday/core/errors/app_exception.dart';
import 'package:redday/services/export_service.dart';

void main() {
  final exportService = ExportService();

  group('ExportService Validation Tests', () {
    test('Successfully validates valid RedDay backup JSON', () {
      final validBackup = jsonEncode({
        'app': 'RedDay',
        'schema_version': 1,
        'exported_at': '2026-10-14T10:00:00.000',
        'settings': {
          'average_cycle_length': '28',
          'average_period_duration': '5',
        },
        'periods': [
          {'start_date': '2026-09-01', 'end_date': '2026-09-05'},
        ],
        'daily_logs': [
          {
            'log_date': '2026-09-01',
            'flow_intensity': 'medium',
            'notes': 'Mild cramps',
            'symptoms': [
              {'name': 'Abdominal cramps', 'severity': 'mild'},
            ],
          },
        ],
      });

      final parsed = exportService.validateAndParseJson(validBackup);
      expect(parsed['app'], equals('RedDay'));
      expect(parsed['periods'], isA<List<dynamic>>());
      expect((parsed['periods'] as List<dynamic>).length, equals(1));
    });

    test('Throws ImportExportException when app name is mismatched or missing', () {
      final foreignBackup = jsonEncode({
        'app': 'OtherMenstrualApp',
        'schema_version': 1,
        'periods': [],
      });

      expect(
        () => exportService.validateAndParseJson(foreignBackup),
        throwsA(isA<ImportExportException>()),
      );
    });

    test('Throws ImportExportException when JSON is malformed', () {
      const malformedJson = '{ "app": "RedDay", unclosed string ';

      expect(
        () => exportService.validateAndParseJson(malformedJson),
        throwsA(isA<ImportExportException>()),
      );
    });

    test('Throws ImportExportException when root is not a JSON object', () {
      const arrayJson = '["not", "a", "map"]';

      expect(
        () => exportService.validateAndParseJson(arrayJson),
        throwsA(isA<ImportExportException>()),
      );
    });
  });
}
