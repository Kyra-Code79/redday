import 'package:flutter/material.dart';
import '../core/utils/date_utils.dart';
import '../models/daily_log.dart';
import '../models/period.dart';
import '../repositories/daily_log_repository.dart';
import '../repositories/period_repository.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({
    DailyLogRepository? dailyLogRepository,
    PeriodRepository? periodRepository,
  })  : _dailyLogRepo = dailyLogRepository ?? DailyLogRepository(),
        _periodRepo = periodRepository ?? PeriodRepository() {
    _focusedMonth = AppDateUtils.firstDayOfMonth(AppDateUtils.today);
    _selectedDate = AppDateUtils.today;
    loadSelectedDateData();
  }

  final DailyLogRepository _dailyLogRepo;
  final PeriodRepository _periodRepo;

  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  DailyLog? _selectedDateLog;
  Period? _selectedDatePeriod;
  bool _isLoadingSelectedDay = false;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  DailyLog? get selectedDateLog => _selectedDateLog;
  Period? get selectedDatePeriod => _selectedDatePeriod;
  bool get isLoadingSelectedDay => _isLoadingSelectedDay;

  /// Changes the selected date and loads its log/period info.
  Future<void> selectDate(DateTime date) async {
    _selectedDate = AppDateUtils.dateOnly(date);
    // If the selected date is in another month, auto-focus that month
    if (_selectedDate.year != _focusedMonth.year ||
        _selectedDate.month != _focusedMonth.month) {
      _focusedMonth = AppDateUtils.firstDayOfMonth(_selectedDate);
    }
    notifyListeners();
    await loadSelectedDateData();
  }

  /// Navigates to the next calendar month.
  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    notifyListeners();
  }

  /// Navigates to the previous calendar month.
  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    notifyListeners();
  }

  /// Sets the focused month directly.
  void setFocusedMonth(DateTime month) {
    _focusedMonth = AppDateUtils.firstDayOfMonth(month);
    notifyListeners();
  }

  /// Reloads data for the current selected date.
  Future<void> loadSelectedDateData() async {
    _isLoadingSelectedDay = true;
    notifyListeners();

    try {
      _selectedDateLog = await _dailyLogRepo.getLogForDate(_selectedDate);
      _selectedDatePeriod = await _periodRepo.getPeriodForDate(_selectedDate);
    } catch (_) {
      // Keep existing on failure
    } finally {
      _isLoadingSelectedDay = false;
      notifyListeners();
    }
  }
}
