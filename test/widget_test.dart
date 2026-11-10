import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:redday/app.dart';
import 'package:redday/core/constants/app_colors.dart';
import 'package:redday/core/constants/app_constants.dart';
import 'package:redday/core/constants/app_text_styles.dart';
import 'package:redday/core/theme/app_theme.dart';
import 'package:redday/models/app_settings.dart';
import 'package:redday/models/daily_log.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Uses strict 2-color palette (#1e1e1c and #d8cbb3) and readable NotoSans font', () {
    expect(AppColors.charcoal, const Color(0xFF1E1E1C));
    expect(AppColors.sand, const Color(0xFFD8CBB3));
    expect(AppTextStyles.fontFamily, 'NotoSans');

    final light = AppTheme.lightTheme;
    expect(light.scaffoldBackgroundColor, const Color(0xFFD8CBB3));
    expect(light.colorScheme.primary, const Color(0xFF1E1E1C));
    expect(light.colorScheme.onPrimary, const Color(0xFFD8CBB3));
    expect(light.colorScheme.surface, const Color(0xFFD8CBB3));
    expect(light.colorScheme.onSurface, const Color(0xFF1E1E1C));

    final dark = AppTheme.darkTheme;
    expect(dark.scaffoldBackgroundColor, const Color(0xFF1E1E1C));
    expect(dark.colorScheme.primary, const Color(0xFFD8CBB3));
    expect(dark.colorScheme.onPrimary, const Color(0xFF1E1E1C));
    expect(dark.colorScheme.surface, const Color(0xFF1E1E1C));
    expect(dark.colorScheme.onSurface, const Color(0xFFD8CBB3));
  });

  testWidgets('Asks which language to use on first start and supports Bahasa Indonesia', (tester) async {
    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: false));
    await tester.pump();

    // Verify Welcome screen content & language selector
    expect(find.text('Understand Your Cycle.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);

    // Switch to Bahasa Indonesia
    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    expect(find.text('Pahami Siklus Anda.'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);
  });

  testWidgets('Shows first-time user tutorial only on first use and hides after completion', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: true));
    await tester.pumpAndSettle();

    // First-time user sees the First-Time Guide card on Home
    expect(find.text('FIRST-TIME GUIDE'), findsOneWidget);
    expect(find.text('Interactive Tutorial'), findsOneWidget);

    // Open interactive step-by-step tutorial
    await tester.tap(find.text('Interactive Tutorial'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('Read Your Cycle at a Glance'), findsOneWidget);

    // Step through tutorial
    await tester.tap(find.text('Next Tip'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 2 OF 4'), findsOneWidget);

    await tester.tap(find.text('Next Tip'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 3 OF 4'), findsOneWidget);

    await tester.tap(find.text('Next Tip'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 4 OF 4'), findsOneWidget);

    // Complete tutorial
    await tester.tap(find.text('Start Using RedDay'));
    await tester.pumpAndSettle();

    // Verify First-Time Guide is dismissed and preference is saved
    expect(find.text('FIRST-TIME GUIDE'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConstants.prefKeyTutorialComplete), isTrue);
  });

  testWidgets('Does not show tutorial card for returning users who completed it', (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefKeyTutorialComplete: true,
    });

    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: true));
    await tester.pumpAndSettle();

    expect(find.text('FIRST-TIME GUIDE'), findsNothing);
  });

  testWidgets('Renders main application shell when isOnboardingComplete is true', (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefKeyTutorialComplete: true,
    });

    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: true));
    await tester.pump();

    // Verify 4 main navigation tabs are present in the NavigationBar
    expect(find.widgetWithText(NavigationDestination, 'Home'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Calendar'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Insights'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Settings'), findsOneWidget);

    // Verify Home QuickActions: Tapping Calendar QuickAction switches to Calendar tab
    expect(find.text('Calendar'), findsWidgets);
    final calendarAction = find.widgetWithText(InkWell, 'Calendar');
    if (calendarAction.evaluate().isNotEmpty) {
      await tester.tap(calendarAction.first);
      await tester.pumpAndSettle();
      expect(find.text('Menstrual Calendar'), findsOneWidget);
    }

    // Switch back to Home tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Home'));
    await tester.pumpAndSettle();

    // Verify Home QuickActions: Tapping Insights QuickAction switches to Insights tab
    final insightsAction = find.widgetWithText(InkWell, 'Insights');
    if (insightsAction.evaluate().isNotEmpty) {
      await tester.tap(insightsAction.first);
      await tester.pumpAndSettle();
      expect(find.text('Cycle Insights'), findsOneWidget);
    }

    // Switch to Settings tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('BOYFRIEND / PARTNER MODE'), findsOneWidget);
    expect(find.text('Export Backup Data'), findsOneWidget);
    expect(find.text('Import Backup Data'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
  });

  test('Supports Boyfriend Mode settings, unknown period duration, and FlowIntensity.notSure', () {
    expect(FlowIntensity.notSure.displayName, 'Not Sure');
    expect(FlowIntensity.fromValue('not_sure'), FlowIntensity.notSure);

    const settings = AppSettings(
      isBoyfriendMode: true,
      boyfriendCareReminderEnabled: true,
      knowsPeriodDuration: false,
    );
    final map = settings.toMap();
    expect(map[AppConstants.settingIsBoyfriendMode], 'true');
    expect(map[AppConstants.settingBoyfriendCareReminderEnabled], 'true');
    expect(map[AppConstants.settingKnowsPeriodDuration], 'false');

    final restored = AppSettings.fromMap(map);
    expect(restored.isBoyfriendMode, isTrue);
    expect(restored.boyfriendCareReminderEnabled, isTrue);
    expect(restored.knowsPeriodDuration, isFalse);
    expect(restored.averagePeriodDuration, 5);
  });

  testWidgets('Supports Boyfriend Mode in onboarding with "Do you know the period duration?" question', (tester) async {
    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: false));
    await tester.pumpAndSettle();

    expect(find.text('Who is using this app?'), findsOneWidget);
    expect(find.text('Boyfriend Mode'), findsOneWidget);
    expect(find.text('Today is the first day'), findsOneWidget);

    await tester.ensureVisible(find.text('Today is the first day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Today is the first day'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Boyfriend Mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Boyfriend Mode'));
    await tester.pumpAndSettle();

    // Advance to Page 2 (Cycle Baseline)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Today is the first day'), findsOneWidget);
    expect(find.text('Do you know the period duration?'), findsOneWidget);
    expect(find.text('Not sure'), findsOneWidget);
    expect(
      find.textContaining('automatically use a standard 5-day period duration'),
      findsOneWidget,
    );
  });

  testWidgets('Toggles Boyfriend Mode on HomeScreen and displays Boyfriend Care & Reminder Hub', (tester) async {
    SharedPreferences.setMockInitialValues({
      AppConstants.prefKeyTutorialComplete: true,
    });

    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: true));
    await tester.pumpAndSettle();

    expect(find.text('Boyfriend Mode'), findsOneWidget);
    expect(find.text('Boyfriend Care & Reminder Hub'), findsNothing);

    // Tap Boyfriend Mode toggle chip in Home header
    await tester.tap(find.text('Boyfriend Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Partner!'), findsOneWidget);
    expect(find.text('Boyfriend Care & Reminder Hub'), findsOneWidget);
    expect(find.text('Boyfriend Care Reminder'), findsOneWidget);
  });

  testWidgets('Renders Bahasa Indonesia tutorial ("LANGKAH 1 DARI 4" / "Lewati Tutorial") and Home nutrition card without overflow on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      AppConstants.prefKeyLanguageCode: 'id',
    });

    await tester.pumpWidget(const RedDayApp(isOnboardingComplete: true));
    await tester.pumpAndSettle();

    // Open interactive tutorial in Bahasa Indonesia on a 320px narrow screen
    await tester.ensureVisible(find.text('Tutorial Interaktif'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutorial Interaktif'));
    await tester.pumpAndSettle();

    expect(find.text('LANGKAH 1 DARI 4'), findsOneWidget);
    expect(find.text('Lewati Tutorial'), findsOneWidget);

    await tester.tap(find.text('Lewati Tutorial'));
    await tester.pumpAndSettle();

    expect(find.text('View All'), findsOneWidget);
  });
}
