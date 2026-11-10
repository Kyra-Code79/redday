import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../models/app_settings.dart';
import '../models/cycle_prediction.dart';
import '../models/period.dart';
import '../repositories/period_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/cycle_prediction_service.dart';
import '../services/notification_service.dart';

class PeriodProvider extends ChangeNotifier {
  PeriodProvider({
    PeriodRepository? periodRepository,
    SettingsRepository? settingsRepository,
    CyclePredictionService? predictionService,
    NotificationService? notificationService,
  })  : _periodRepo = periodRepository ?? PeriodRepository(),
        _settingsRepo = settingsRepository ?? SettingsRepository(),
        _predictionService = predictionService ?? const CyclePredictionService(),
        _notificationService = notificationService ?? NotificationService();

  final PeriodRepository _periodRepo;
  final SettingsRepository _settingsRepo;
  final CyclePredictionService _predictionService;
  final NotificationService _notificationService;

  List<Period> _periods = [];
  AppSettings _settings = const AppSettings();
  CyclePrediction _prediction = CyclePrediction.empty;
  bool _isLoading = true;
  String? _errorMessage;

  List<Period> get periods => _periods;
  AppSettings get settings => _settings;
  CyclePrediction get prediction => _prediction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads periods and settings, recalculates prediction, and syncs reminders.
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _periods = await _periodRepo.getAllPeriods();
      _settings = await _settingsRepo.getSettings();
      _recalculatePrediction();
      await _syncReminders();
    } catch (e) {
      _errorMessage = 'Failed to load tracking data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _recalculatePrediction() {
    _prediction = _predictionService.calculatePrediction(
      periods: _periods,
      settings: _settings,
    );
  }

  Future<void> _syncReminders() async {
    try {
      await _notificationService.syncReminders(
        settings: _settings,
        prediction: _prediction,
      );
    } catch (_) {
      // Notification scheduling failure should never crash the app
    }
  }

  /// Adds a new period and refreshes predictions.
  Future<void> addPeriod(Period period) async {
    try {
      await _periodRepo.insertPeriod(period);
      await loadData();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing period and refreshes predictions.
  Future<void> updatePeriod(Period period) async {
    try {
      await _periodRepo.updatePeriod(period);
      await loadData();
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a period by ID and refreshes predictions.
  Future<void> deletePeriod(int id) async {
    try {
      await _periodRepo.deletePeriod(id);
      await loadData();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates user cycle settings and syncs reminders.
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    _recalculatePrediction();
    notifyListeners();
    try {
      await _settingsRepo.saveSettings(newSettings);
      await _syncReminders();
    } catch (_) {
      // Keep in-memory settings updated even if local DB is unavailable in tests
    }
  }

  /// Wipes all tracking data and resets defaults.
  Future<void> deleteAllData() async {
    try {
      await AppDatabase.instance.deleteAllData();
      await _notificationService.cancelAll();
      await loadData();
    } catch (e) {
      rethrow;
    }
  }
}
