import 'package:flutter/material.dart';
import '../models/daily_log.dart';
import '../models/symptom.dart';
import '../repositories/daily_log_repository.dart';

class DailyLogProvider extends ChangeNotifier {
  DailyLogProvider({DailyLogRepository? dailyLogRepository})
      : _dailyLogRepo = dailyLogRepository ?? DailyLogRepository();

  final DailyLogRepository _dailyLogRepo;

  List<Symptom> _allSymptoms = [];
  bool _isLoading = false;

  List<Symptom> get allSymptoms => _allSymptoms;
  bool get isLoading => _isLoading;

  /// Loads available symptoms dictionary from local database.
  Future<void> loadSymptoms() async {
    if (_allSymptoms.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      _allSymptoms = await _dailyLogRepo.getAllSymptoms();
    } catch (_) {
      // Retain defaults
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retrieves log for a date.
  Future<DailyLog?> getLogForDate(DateTime date) async {
    return await _dailyLogRepo.getLogForDate(date);
  }

  /// Retrieves logs between two dates.
  Future<List<DailyLog>> getLogsBetween(DateTime start, DateTime end) async {
    return await _dailyLogRepo.getLogsBetween(start, end);
  }

  /// Saves or updates a daily log.
  Future<DailyLog> saveLog(DailyLog log) async {
    final saved = await _dailyLogRepo.saveLog(log);
    notifyListeners();
    return saved;
  }

  /// Deletes a daily log for a specific date.
  Future<void> deleteLogForDate(DateTime date) async {
    await _dailyLogRepo.deleteLogForDate(date);
    notifyListeners();
  }
}
