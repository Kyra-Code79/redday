import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications gracefully
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Notification initialization: $e');
  }

  // Check if user has already completed onboarding
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete =
      prefs.getBool(AppConstants.prefKeyOnboardingComplete) ?? false;

  runApp(RedDayApp(isOnboardingComplete: isOnboardingComplete));
}
