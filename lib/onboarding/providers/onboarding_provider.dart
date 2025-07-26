import 'package:flutter/material.dart';
import '../application/onboarding_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _service = OnboardingService();

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _hasCompletedOnboarding = await _service.hasCompletedOnboarding();
    } catch (e) {
      _error = 'Failed to load onboarding status';
      print('Error loading onboarding status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.completeOnboarding();
      _hasCompletedOnboarding = true;
    } catch (e) {
      _error = 'Failed to complete onboarding';
      print('Error completing onboarding: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetOnboarding() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.resetOnboarding();
      _hasCompletedOnboarding = false;
    } catch (e) {
      _error = 'Failed to reset onboarding';
      print('Error resetting onboarding: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get progress for current screen
  double getProgress(int currentIndex, int totalScreens) {
    return _service.getProgress(currentIndex, totalScreens);
  }

  /// Check if can proceed to next screen
  bool canProceedToNext(int currentIndex, int totalScreens) {
    return _service.canProceedToNext(currentIndex, totalScreens);
  }

  /// Check if current screen is last
  bool isLastScreen(int currentIndex, int totalScreens) {
    return _service.isLastScreen(currentIndex, totalScreens);
  }
}
