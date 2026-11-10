import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/cycle_prediction.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  /// Initializes the local notification plugin, timezones, and Android channels.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        // Fallback to UTC if native timezone lookup fails
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // Android initialization settings
      // ic_stat_redday is our custom monochrome vector drawable in res/drawable
      const androidSettings = AndroidInitializationSettings('ic_stat_redday');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
      );

      // Create Android Notification Channel
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          description: AppConstants.notificationChannelDesc,
          importance: Importance.high,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization skipped/failed: $e');
    }
  }

  /// Requests notification permission on Android 13+ (API 33+).
  /// Safe to call on Android 7.0–12 (no-op / returns true).
  Future<bool> requestPermission() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return true;

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Checks if notifications are currently enabled for this app.
  Future<bool> areNotificationsEnabled() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return true;

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Synchronizes scheduled notifications with current settings and predictions.
  Future<void> syncReminders({
    required AppSettings settings,
    required CyclePrediction prediction,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // 1. Period upcoming reminder
      if (settings.periodReminderEnabled &&
          prediction.hasData &&
          prediction.nextPeriodDate != null) {
        await _schedulePeriodReminder(
          nextPeriodDate: prediction.nextPeriodDate!,
          daysBefore: settings.periodReminderDaysBefore,
          hour: settings.reminderTimeHour,
          minute: settings.reminderTimeMinute,
          isBoyfriendMode: settings.isBoyfriendMode,
        );
      } else {
        await cancelReminder(AppConstants.notificationIdPeriodReminder);
      }

      // 2. Daily tracking reminder
      if (settings.dailyReminderEnabled) {
        await _scheduleDailyReminder(
          hour: settings.reminderTimeHour,
          minute: settings.reminderTimeMinute,
          isBoyfriendMode: settings.isBoyfriendMode,
        );
      } else {
        await cancelReminder(AppConstants.notificationIdDailyReminder);
      }

      // 3. Boyfriend care reminder
      if (settings.isBoyfriendMode && settings.boyfriendCareReminderEnabled) {
        await _scheduleBoyfriendCareReminder(
          nextPeriodDate: prediction.nextPeriodDate,
          isOnPeriod: prediction.isPeriodOngoing ||
              prediction.phase == CyclePhase.menstrual,
          hour: settings.reminderTimeHour,
          minute: settings.reminderTimeMinute,
        );
      } else {
        await cancelReminder(AppConstants.notificationIdBoyfriendCareReminder);
      }
    } catch (e) {
      debugPrint('Error syncing reminders: $e');
    }
  }

  Future<void> _schedulePeriodReminder({
    required DateTime nextPeriodDate,
    required int daysBefore,
    required int hour,
    required int minute,
    bool isBoyfriendMode = false,
  }) async {
    try {
      final scheduledDate = nextPeriodDate.subtract(Duration(days: daysBefore));
      final now = DateTime.now();

      final targetDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        hour,
        minute,
      );

      // Do not schedule if in the past
      if (targetDateTime.isBefore(now)) {
        await cancelReminder(AppConstants.notificationIdPeriodReminder);
        return;
      }

      final tzTarget = tz.TZDateTime.from(targetDateTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_redday',
      );

      final title = isBoyfriendMode
          ? 'Boyfriend Reminder: Her Period is Approaching'
          : 'Upcoming Period Reminder';
      final body = isBoyfriendMode
          ? (daysBefore == 0
              ? 'Her period is estimated today! Prepare her favorite comfort snacks, warm drinks, and extra patience.'
              : 'Her period is estimated in $daysBefore days! Time to prepare comfort food and extra care.')
          : (daysBefore == 0
              ? 'Your period is estimated to start today.'
              : 'Your period is estimated to start in $daysBefore days.');

      await _plugin.zonedSchedule(
        id: AppConstants.notificationIdPeriodReminder,
        scheduledDate: tzTarget,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact,
        title: title,
        body: body,
        payload: 'period_reminder',
      );
    } catch (e) {
      debugPrint('Failed to schedule period reminder: $e');
    }
  }

  Future<void> _scheduleDailyReminder({
    required int hour,
    required int minute,
    bool isBoyfriendMode = false,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: 'ic_stat_redday',
      );

      await _plugin.zonedSchedule(
        id: AppConstants.notificationIdDailyReminder,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        title: isBoyfriendMode
            ? 'Boyfriend Daily Check-in'
            : 'Daily Cycle Check-in',
        body: isBoyfriendMode
            ? 'Remember to check in on her comfort and mood today (flow amount is optional!).'
            : 'Take a moment to record your symptoms and mood for today.',
        payload: 'daily_reminder',
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reminder: $e');
    }
  }

  Future<void> _scheduleBoyfriendCareReminder({
    required DateTime? nextPeriodDate,
    required bool isOnPeriod,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_redday',
      );

      final String body;
      if (isOnPeriod) {
        body =
            'She is on her Red Day! Remember warm drinks, dark chocolate or cheese snacks, and extra care.';
      } else if (nextPeriodDate != null) {
        final daysLeft = nextPeriodDate.difference(DateTime.now()).inDays;
        body = daysLeft >= 0 && daysLeft <= 5
            ? 'Her period is coming up in ~$daysLeft days. Stock up on her comfort snacks and be extra supportive!'
            : 'Boyfriend Care Reminder: Check how she is feeling today and keep track of her upcoming cycle.';
      } else {
        body =
            'Boyfriend Care Reminder: Log her last period start date when you know it (duration defaults to 5 days if unsure).';
      }

      await _plugin.zonedSchedule(
        id: AppConstants.notificationIdBoyfriendCareReminder,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        title: 'Boyfriend Care Reminder',
        body: body,
        payload: 'boyfriend_care_reminder',
      );
    } catch (e) {
      debugPrint('Failed to schedule boyfriend care reminder: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel reminder $id: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }
}
