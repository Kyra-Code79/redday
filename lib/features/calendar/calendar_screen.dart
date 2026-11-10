import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../models/daily_log.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/period_provider.dart';
import '../period_logging/period_log_screen.dart';
import '../symptom_tracking/symptom_tracking_screen.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/calendar_legend.dart';
import 'widgets/day_detail_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DailyLog> _monthLogs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthLogs();
    });
  }

  Future<void> _loadMonthLogs() async {
    final calendarProvider = context.read<CalendarProvider>();
    final focused = calendarProvider.focusedMonth;
    final start = DateTime(focused.year, focused.month - 1, 20);
    final end = DateTime(focused.year, focused.month + 2, 10);

    try {
      final logs = await context
          .read<DailyLogProvider>()
          .getLogsBetween(start, end);
      if (mounted) {
        setState(() {
          _monthLogs = logs;
        });
      }
    } catch (_) {}
  }

  void _openLogPeriod() async {
    final calendarProvider = context.read<CalendarProvider>();
    final selectedDate = calendarProvider.selectedDate;
    final period = calendarProvider.selectedDatePeriod;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PeriodLogScreen(
          existingPeriod: period,
          initialStartDate: selectedDate,
        ),
      ),
    );

    if (result == true && mounted) {
      await context.read<PeriodProvider>().loadData();
      await calendarProvider.loadSelectedDateData();
    }
  }

  void _openLogSymptoms() async {
    final calendarProvider = context.read<CalendarProvider>();
    final selectedDate = calendarProvider.selectedDate;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SymptomTrackingScreen(
          date: selectedDate,
        ),
      ),
    );

    if (result == true && mounted) {
      await calendarProvider.loadSelectedDateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final periodProvider = context.watch<PeriodProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menstrual Calendar'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // Monthly interactive calendar grid
              CalendarGrid(
                focusedMonth: calendarProvider.focusedMonth,
                selectedDate: calendarProvider.selectedDate,
                periods: periodProvider.periods,
                prediction: periodProvider.prediction,
                monthLogs: _monthLogs,
                onDateSelected: (date) {
                  calendarProvider.selectDate(date);
                },
                onPreviousMonth: () {
                  calendarProvider.previousMonth();
                },
                onNextMonth: () {
                  calendarProvider.nextMonth();
                },
                onTodayPressed: () {
                  calendarProvider.selectDate(AppDateUtils.today);
                },
              ),
              const SizedBox(height: 8),

              // Legend
              const CalendarLegend(),
              const SizedBox(height: 12),

              // Selected Date Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DayDetailCard(
                  selectedDate: calendarProvider.selectedDate,
                  period: calendarProvider.selectedDatePeriod,
                  dailyLog: calendarProvider.selectedDateLog,
                  prediction: periodProvider.prediction,
                  onLogPeriodTap: _openLogPeriod,
                  onLogSymptomsTap: _openLogSymptoms,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
