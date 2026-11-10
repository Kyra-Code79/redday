/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'RedDay';
  static const String databaseName = 'redday.db';
  static const int databaseVersion = 1;

  // Cycle default values (clinical baseline)
  static const int defaultPeriodDurationDays = 5;
  static const int defaultCycleLengthDays = 28;
  static const int minCycleLengthDays = 15;
  static const int maxCycleLengthDays = 60;
  static const int minPeriodDurationDays = 1;
  static const int maxPeriodDurationDays = 15;

  // Luteal phase standard assumption (for approximate ovulation calculation)
  static const int standardLutealPhaseDays = 14;

  // Reminders
  static const String notificationChannelId = 'redday_cycle_reminders';
  static const String notificationChannelName = 'Cycle Reminders';
  static const String notificationChannelDesc =
      'Notifications for upcoming estimated periods and daily tracking reminders.';
  static const int notificationIdPeriodReminder = 1001;
  static const int notificationIdDailyReminder = 1002;
  static const int notificationIdBoyfriendCareReminder = 1003;

  // Preferences Keys (SharedPreferences)
  static const String prefKeyThemeMode = 'app_theme_mode';
  static const String prefKeyOnboardingComplete = 'app_onboarding_complete';
  static const String prefKeyTutorialComplete = 'app_tutorial_complete';
  static const String prefKeyLanguageCode = 'app_language_code';
  static const String prefKeyLanguageSelected = 'app_language_selected';

  // Database Settings Keys
  static const String settingCycleLength = 'average_cycle_length';
  static const String settingPeriodDuration = 'average_period_duration';
  static const String settingPeriodReminderEnabled = 'period_reminder_enabled';
  static const String settingPeriodReminderDaysBefore =
      'period_reminder_days_before';
  static const String settingDailyReminderEnabled = 'daily_reminder_enabled';
  static const String settingReminderTimeHour = 'reminder_time_hour';
  static const String settingReminderTimeMinute = 'reminder_time_minute';
  static const String settingLastPeriodStart = 'last_period_start';
  static const String settingDietaryAllergies = 'dietary_allergies';
  static const String settingFavoriteFoods = 'favorite_foods';
  static const String settingBookmarkedFoods = 'bookmarked_foods';
  static const String settingIsBoyfriendMode = 'is_boyfriend_mode';
  static const String settingBoyfriendCareReminderEnabled =
      'boyfriend_care_reminder_enabled';
  static const String settingKnowsPeriodDuration = 'knows_period_duration';
}
