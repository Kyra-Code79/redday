import 'package:flutter/material.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../onboarding/first_time_tutorial_dialog.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialIndex = 0,
    this.showTutorialOnStart = false,
  });

  final int initialIndex;
  final bool showTutorialOnStart;

  static void switchToTab(BuildContext context, int index) {
    final scope = AppNavigationScope.maybeOf(context);
    scope?.switchToTab(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    super.key,
    required this.currentIndex,
    required this.switchToTab,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> switchToTab;

  static AppNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();
  }

  static AppNavigationScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AppNavigationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const CalendarScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    if (widget.showTutorialOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FirstTimeTutorialDialog.showIfFirstTime(context);
        }
      });
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigationScope(
      currentIndex: _currentIndex,
      switchToTab: _onTabSelected,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.spa_outlined),
              selectedIcon: Icon(Icons.spa_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
