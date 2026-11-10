import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/period.dart';
import '../repositories/daily_log_repository.dart';
import '../services/cycle_prediction_service.dart';

class InsightsProvider extends ChangeNotifier {
  InsightsProvider({
    DailyLogRepository? dailyLogRepository,
    CyclePredictionService? predictionService,
  })  : _dailyLogRepo = dailyLogRepository ?? DailyLogRepository(),
        _predictionService = predictionService ?? const CyclePredictionService();

  final DailyLogRepository _dailyLogRepo;
  final CyclePredictionService _predictionService;

  CycleStats _stats = CycleStats.empty;
  Map<String, int> _symptomFrequencies = {};
  bool _isLoading = false;

  CycleStats get stats => _stats;
  Map<String, int> get symptomFrequencies => _symptomFrequencies;
  bool get isLoading => _isLoading;

  /// Recomputes insights from recorded periods, settings, and symptom logs.
  Future<void> loadInsights({
    required List<Period> periods,
    required AppSettings settings,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = _predictionService.calculateStats(
        periods: periods,
        settings: settings,
      );
      _symptomFrequencies = await _dailyLogRepo.getSymptomFrequencies();
    } catch (_) {
      // Keep existing stats
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
