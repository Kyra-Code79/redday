import 'package:flutter/material.dart';

/// Centralized strict 2-color palette for RedDay:
/// - Charcoal Ink: #1E1E1C (Color(0xFF1E1E1C))
/// - Warm Sand:    #D8CBB3 (Color(0xFFD8CBB3))
/// Provides a 10.41:1 WCAG AAA contrast ratio across both Light and Dark themes.
abstract final class AppColors {
  // --- Core 2-Color Palette ---
  static const Color charcoal = Color(0xFF1E1E1C); // #1e1e1c
  static const Color sand = Color(0xFFD8CBB3); // #d8cbb3

  // --- Light Theme Palette (Warm Sand canvas #d8cbb3, Charcoal Ink #1e1e1c) ---
  static const Color lightPrimary = charcoal;
  static const Color lightDarkForest = charcoal;
  static const Color lightDeepGreen = charcoal;
  static const Color lightSage = charcoal;
  static const Color lightSoftMint = charcoal;
  static const Color lightPaleBackground = sand;
  static const Color lightBackground = sand;
  static const Color lightSurface = sand;
  static const Color lightSurfaceVariant = sand;
  static const Color lightPrimaryText = charcoal;
  static const Color lightSecondaryText = charcoal;
  static const Color lightBorder = charcoal;
  static const Color lightSuccess = charcoal;
  static const Color lightWarning = charcoal;
  static const Color lightError = charcoal;

  // --- Dark Theme Palette (Charcoal Ink canvas #1e1e1c, Warm Sand #d8cbb3) ---
  static const Color darkPrimary = sand;
  static const Color darkSecondary = sand;
  static const Color darkDeepAccent = sand;
  static const Color darkForestSurface = charcoal;
  static const Color darkBackground = charcoal;
  static const Color darkElevatedSurface = charcoal;
  static const Color darkSecondarySurface = charcoal;
  static const Color darkPrimaryText = sand;
  static const Color darkSecondaryText = sand;
  static const Color darkBorder = sand;
  static const Color darkSuccess = sand;
  static const Color darkWarning = sand;
  static const Color darkError = sand;

  // --- Flow Intensity Indicators (Strict 2-Color Tones) ---
  static const Color flowSpotting = charcoal;
  static const Color flowLight = charcoal;
  static const Color flowMedium = charcoal;
  static const Color flowHeavy = charcoal;
}

/// Custom theme extension for domain-specific cycle visualization tokens.
class RedDayThemeColors extends ThemeExtension<RedDayThemeColors> {
  const RedDayThemeColors({
    required this.periodDay,
    required this.periodDayText,
    required this.predictedPeriodDay,
    required this.predictedPeriodDayBorder,
    required this.predictedPeriodText,
    required this.fertileDay,
    required this.fertileDayText,
    required this.todayBorder,
    required this.selectedDay,
    required this.selectedDayText,
    required this.otherMonthText,
    required this.cardBorder,
    required this.badgeBackground,
    required this.badgeText,
    required this.chartPrimary,
    required this.chartSecondary,
    required this.chartGrid,
  });

  final Color periodDay;
  final Color periodDayText;
  final Color predictedPeriodDay;
  final Color predictedPeriodDayBorder;
  final Color predictedPeriodText;
  final Color fertileDay;
  final Color fertileDayText;
  final Color todayBorder;
  final Color selectedDay;
  final Color selectedDayText;
  final Color otherMonthText;
  final Color cardBorder;
  final Color badgeBackground;
  final Color badgeText;
  final Color chartPrimary;
  final Color chartSecondary;
  final Color chartGrid;

  static const light = RedDayThemeColors(
    periodDay: AppColors.charcoal,
    periodDayText: AppColors.sand,
    predictedPeriodDay: AppColors.sand,
    predictedPeriodDayBorder: AppColors.charcoal,
    predictedPeriodText: AppColors.charcoal,
    fertileDay: AppColors.sand,
    fertileDayText: AppColors.charcoal,
    todayBorder: AppColors.charcoal,
    selectedDay: AppColors.charcoal,
    selectedDayText: AppColors.sand,
    otherMonthText: AppColors.charcoal,
    cardBorder: AppColors.charcoal,
    badgeBackground: AppColors.charcoal,
    badgeText: AppColors.sand,
    chartPrimary: AppColors.charcoal,
    chartSecondary: AppColors.charcoal,
    chartGrid: AppColors.charcoal,
  );

  static const dark = RedDayThemeColors(
    periodDay: AppColors.sand,
    periodDayText: AppColors.charcoal,
    predictedPeriodDay: AppColors.charcoal,
    predictedPeriodDayBorder: AppColors.sand,
    predictedPeriodText: AppColors.sand,
    fertileDay: AppColors.charcoal,
    fertileDayText: AppColors.sand,
    todayBorder: AppColors.sand,
    selectedDay: AppColors.sand,
    selectedDayText: AppColors.charcoal,
    otherMonthText: AppColors.sand,
    cardBorder: AppColors.sand,
    badgeBackground: AppColors.sand,
    badgeText: AppColors.charcoal,
    chartPrimary: AppColors.sand,
    chartSecondary: AppColors.sand,
    chartGrid: AppColors.sand,
  );

  @override
  ThemeExtension<RedDayThemeColors> copyWith({
    Color? periodDay,
    Color? periodDayText,
    Color? predictedPeriodDay,
    Color? predictedPeriodDayBorder,
    Color? predictedPeriodText,
    Color? fertileDay,
    Color? fertileDayText,
    Color? todayBorder,
    Color? selectedDay,
    Color? selectedDayText,
    Color? otherMonthText,
    Color? cardBorder,
    Color? badgeBackground,
    Color? badgeText,
    Color? chartPrimary,
    Color? chartSecondary,
    Color? chartGrid,
  }) {
    return RedDayThemeColors(
      periodDay: periodDay ?? this.periodDay,
      periodDayText: periodDayText ?? this.periodDayText,
      predictedPeriodDay: predictedPeriodDay ?? this.predictedPeriodDay,
      predictedPeriodDayBorder:
          predictedPeriodDayBorder ?? this.predictedPeriodDayBorder,
      predictedPeriodText: predictedPeriodText ?? this.predictedPeriodText,
      fertileDay: fertileDay ?? this.fertileDay,
      fertileDayText: fertileDayText ?? this.fertileDayText,
      todayBorder: todayBorder ?? this.todayBorder,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedDayText: selectedDayText ?? this.selectedDayText,
      otherMonthText: otherMonthText ?? this.otherMonthText,
      cardBorder: cardBorder ?? this.cardBorder,
      badgeBackground: badgeBackground ?? this.badgeBackground,
      badgeText: badgeText ?? this.badgeText,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartSecondary: chartSecondary ?? this.chartSecondary,
      chartGrid: chartGrid ?? this.chartGrid,
    );
  }

  @override
  ThemeExtension<RedDayThemeColors> lerp(
    covariant ThemeExtension<RedDayThemeColors>? other,
    double t,
  ) {
    if (other is! RedDayThemeColors) return this;
    return RedDayThemeColors(
      periodDay: Color.lerp(periodDay, other.periodDay, t)!,
      periodDayText: Color.lerp(periodDayText, other.periodDayText, t)!,
      predictedPeriodDay:
          Color.lerp(predictedPeriodDay, other.predictedPeriodDay, t)!,
      predictedPeriodDayBorder: Color.lerp(
        predictedPeriodDayBorder,
        other.predictedPeriodDayBorder,
        t,
      )!,
      predictedPeriodText:
          Color.lerp(predictedPeriodText, other.predictedPeriodText, t)!,
      fertileDay: Color.lerp(fertileDay, other.fertileDay, t)!,
      fertileDayText: Color.lerp(fertileDayText, other.fertileDayText, t)!,
      todayBorder: Color.lerp(todayBorder, other.todayBorder, t)!,
      selectedDay: Color.lerp(selectedDay, other.selectedDay, t)!,
      selectedDayText: Color.lerp(selectedDayText, other.selectedDayText, t)!,
      otherMonthText: Color.lerp(otherMonthText, other.otherMonthText, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      badgeBackground:
          Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeText: Color.lerp(badgeText, other.badgeText, t)!,
      chartPrimary: Color.lerp(chartPrimary, other.chartPrimary, t)!,
      chartSecondary: Color.lerp(chartSecondary, other.chartSecondary, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
    );
  }
}
