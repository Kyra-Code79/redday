import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';

class AppSettings {
  const AppSettings({
    this.averageCycleLength = AppConstants.defaultCycleLengthDays,
    this.averagePeriodDuration = AppConstants.defaultPeriodDurationDays,
    this.periodReminderEnabled = true,
    this.periodReminderDaysBefore = 2,
    this.dailyReminderEnabled = false,
    this.reminderTimeHour = 20,
    this.reminderTimeMinute = 0,
    this.lastPeriodStart,
    this.dietaryAllergies = const [],
    this.favoriteFoods = const [],
    this.bookmarkedFoodIds = const [],
    this.isBoyfriendMode = false,
    this.boyfriendCareReminderEnabled = true,
    this.knowsPeriodDuration = true,
  });

  final int averageCycleLength;
  final int averagePeriodDuration;
  final bool periodReminderEnabled;
  final int periodReminderDaysBefore;
  final bool dailyReminderEnabled;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final DateTime? lastPeriodStart;
  final List<String> dietaryAllergies;
  final List<String> favoriteFoods;
  final List<String> bookmarkedFoodIds;
  final bool isBoyfriendMode;
  final bool boyfriendCareReminderEnabled;
  final bool knowsPeriodDuration;

  AppSettings copyWith({
    int? averageCycleLength,
    int? averagePeriodDuration,
    bool? periodReminderEnabled,
    int? periodReminderDaysBefore,
    bool? dailyReminderEnabled,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    DateTime? lastPeriodStart,
    bool clearLastPeriodStart = false,
    List<String>? dietaryAllergies,
    List<String>? favoriteFoods,
    List<String>? bookmarkedFoodIds,
    bool? isBoyfriendMode,
    bool? boyfriendCareReminderEnabled,
    bool? knowsPeriodDuration,
  }) {
    return AppSettings(
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodDuration:
          averagePeriodDuration ?? this.averagePeriodDuration,
      periodReminderEnabled:
          periodReminderEnabled ?? this.periodReminderEnabled,
      periodReminderDaysBefore:
          periodReminderDaysBefore ?? this.periodReminderDaysBefore,
      dailyReminderEnabled:
          dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      lastPeriodStart: clearLastPeriodStart
          ? null
          : (lastPeriodStart ?? this.lastPeriodStart),
      dietaryAllergies: dietaryAllergies ?? this.dietaryAllergies,
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      bookmarkedFoodIds: bookmarkedFoodIds ?? this.bookmarkedFoodIds,
      isBoyfriendMode: isBoyfriendMode ?? this.isBoyfriendMode,
      boyfriendCareReminderEnabled:
          boyfriendCareReminderEnabled ?? this.boyfriendCareReminderEnabled,
      knowsPeriodDuration: knowsPeriodDuration ?? this.knowsPeriodDuration,
    );
  }

  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      averageCycleLength: int.tryParse(
            map[AppConstants.settingCycleLength] ?? '',
          ) ??
          AppConstants.defaultCycleLengthDays,
      averagePeriodDuration: int.tryParse(
            map[AppConstants.settingPeriodDuration] ?? '',
          ) ??
          AppConstants.defaultPeriodDurationDays,
      periodReminderEnabled:
          map[AppConstants.settingPeriodReminderEnabled] != 'false',
      periodReminderDaysBefore: int.tryParse(
            map[AppConstants.settingPeriodReminderDaysBefore] ?? '',
          ) ??
          2,
      dailyReminderEnabled:
          map[AppConstants.settingDailyReminderEnabled] == 'true',
      reminderTimeHour: int.tryParse(
            map[AppConstants.settingReminderTimeHour] ?? '',
          ) ??
          20,
      reminderTimeMinute: int.tryParse(
            map[AppConstants.settingReminderTimeMinute] ?? '',
          ) ??
          0,
      lastPeriodStart: map[AppConstants.settingLastPeriodStart] != null &&
              map[AppConstants.settingLastPeriodStart]!.isNotEmpty
          ? AppDateUtils.parseIso(map[AppConstants.settingLastPeriodStart]!)
          : null,
      dietaryAllergies: map[AppConstants.settingDietaryAllergies] != null &&
              map[AppConstants.settingDietaryAllergies]!.isNotEmpty
          ? map[AppConstants.settingDietaryAllergies]!
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : const [],
      favoriteFoods: map[AppConstants.settingFavoriteFoods] != null &&
              map[AppConstants.settingFavoriteFoods]!.isNotEmpty
          ? map[AppConstants.settingFavoriteFoods]!
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : const [],
      bookmarkedFoodIds: map[AppConstants.settingBookmarkedFoods] != null &&
              map[AppConstants.settingBookmarkedFoods]!.isNotEmpty
          ? map[AppConstants.settingBookmarkedFoods]!
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : const [],
      isBoyfriendMode: map[AppConstants.settingIsBoyfriendMode] == 'true',
      boyfriendCareReminderEnabled:
          map[AppConstants.settingBoyfriendCareReminderEnabled] != 'false',
      knowsPeriodDuration:
          map[AppConstants.settingKnowsPeriodDuration] != 'false',
    );
  }

  Map<String, String> toMap() {
    return {
      AppConstants.settingCycleLength: averageCycleLength.toString(),
      AppConstants.settingPeriodDuration: averagePeriodDuration.toString(),
      AppConstants.settingPeriodReminderEnabled:
          periodReminderEnabled.toString(),
      AppConstants.settingPeriodReminderDaysBefore:
          periodReminderDaysBefore.toString(),
      AppConstants.settingDailyReminderEnabled: dailyReminderEnabled.toString(),
      AppConstants.settingReminderTimeHour: reminderTimeHour.toString(),
      AppConstants.settingReminderTimeMinute: reminderTimeMinute.toString(),
      if (lastPeriodStart != null)
        AppConstants.settingLastPeriodStart:
            AppDateUtils.formatIso(lastPeriodStart!),
      AppConstants.settingDietaryAllergies: dietaryAllergies.join(','),
      AppConstants.settingFavoriteFoods: favoriteFoods.join(','),
      AppConstants.settingBookmarkedFoods: bookmarkedFoodIds.join(','),
      AppConstants.settingIsBoyfriendMode: isBoyfriendMode.toString(),
      AppConstants.settingBoyfriendCareReminderEnabled:
          boyfriendCareReminderEnabled.toString(),
      AppConstants.settingKnowsPeriodDuration: knowsPeriodDuration.toString(),
    };
  }
}
