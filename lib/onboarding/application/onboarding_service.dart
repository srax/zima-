import 'package:shared_preferences/shared_preferences.dart';

/// Business logic service for onboarding flow
/// Handles onboarding state management and business rules
class OnboardingService {
  static const String _onboardingKey = 'has_completed_onboarding';

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      // If we can't read preferences, assume onboarding is not complete
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      // Log error but don't throw - onboarding can still proceed
      print('Error saving onboarding state: $e');
    }
  }

  /// Reset onboarding state (for testing/debugging)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
    } catch (e) {
      print('Error resetting onboarding state: $e');
    }
  }

  /// Get onboarding progress (0.0 to 1.0)
  double getProgress(int currentIndex, int totalScreens) {
    if (totalScreens <= 0) return 0.0;
    return (currentIndex + 1) / totalScreens;
  }

  /// Validate if user can proceed to next screen
  bool canProceedToNext(int currentIndex, int totalScreens) {
    return currentIndex < totalScreens - 1;
  }

  /// Check if current screen is the last one
  bool isLastScreen(int currentIndex, int totalScreens) {
    return currentIndex == totalScreens - 1;
  }
}
