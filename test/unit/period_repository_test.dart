import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:redday/core/database/app_database.dart';
import 'package:redday/core/errors/app_exception.dart';
import 'package:redday/models/period.dart';
import 'package:redday/repositories/period_repository.dart';

void main() {
  late Database db;
  late AppDatabase appDatabase;
  late PeriodRepository periodRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    appDatabase = AppDatabase.instance;
    appDatabase.setDatabaseForTesting(db);

    // Run schema creation
    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    periodRepo = PeriodRepository(database: appDatabase);
  });

  tearDown(() async {
    await db.close();
  });

  group('PeriodRepository Database & Validation Tests', () {
    test('Inserts and retrieves periods sorted by start_date DESC', () async {
      final p1 = Period(
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 5),
      );
      final p2 = Period(
        startDate: DateTime(2026, 8, 29),
        endDate: DateTime(2026, 9, 2),
      );

      await periodRepo.insertPeriod(p1);
      await periodRepo.insertPeriod(p2);

      final periods = await periodRepo.getAllPeriods();
      expect(periods.length, equals(2));
      // First item is newest
      expect(periods.first.startDate, equals(DateTime(2026, 8, 29)));
      expect(periods.last.startDate, equals(DateTime(2026, 8, 1)));
    });

    test('Prevents period where end_date is before start_date', () async {
      final invalid = Period(
        startDate: DateTime(2026, 9, 10),
        endDate: DateTime(2026, 9, 8),
      );

      expect(
        () => periodRepo.insertPeriod(invalid),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Prevents overlapping periods', () async {
      // Existing period: Sep 1 to Sep 5
      await periodRepo.insertPeriod(
        Period(
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2026, 9, 5),
        ),
      );

      // Overlapping period: Sep 4 to Sep 8
      final overlapping = Period(
        startDate: DateTime(2026, 9, 4),
        endDate: DateTime(2026, 9, 8),
      );

      expect(
        () => periodRepo.insertPeriod(overlapping),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Updates and deletes period successfully', () async {
      final inserted = await periodRepo.insertPeriod(
        Period(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 4),
        ),
      );

      expect(inserted.id, isNotNull);

      // Update end date
      final updated = await periodRepo.updatePeriod(
        inserted.copyWith(endDate: DateTime(2026, 7, 6)),
      );
      expect(updated.endDate, equals(DateTime(2026, 7, 6)));

      // Delete
      await periodRepo.deletePeriod(inserted.id!);
      final afterDelete = await periodRepo.getAllPeriods();
      expect(afterDelete, isEmpty);
    });
  });
}
