import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/calendar_provider.dart';
import 'providers/daily_log_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/period_provider.dart';
import 'providers/theme_provider.dart';

class RedDayApp extends StatelessWidget {
  const RedDayApp({
    super.key,
    required this.isOnboardingComplete,
  });

  final bool isOnboardingComplete;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PeriodProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()..loadSymptoms()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'RedDay',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: isOnboardingComplete
                ? const AppShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
