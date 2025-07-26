import 'package:flutter/material.dart';
import 'dart:async';

class OnboardingController extends ChangeNotifier {
  late PageController pageController;
  late AnimationController progressController;
  late Animation<double> progressAnimation;
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  int currentIndex = 0;
  int totalScreens = 4; // Default, can be overridden
  Timer? autoAdvanceTimer;
  bool isUserInteracting = false;
  bool isTimerRunning = false;
  bool isTransitioning = false;

  void initialize(TickerProvider vsync, {int? totalScreens}) {
    if (totalScreens != null) {
      this.totalScreens = totalScreens;
    }
    pageController = PageController();
    progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: progressController, curve: Curves.linear),
    );

    // Add listener to progress animation to advance to next screen when complete
    progressAnimation.addListener(() {
      final maxIndex = totalScreens! - 1;
      if (progressAnimation.value >= 1.0 &&
          !isUserInteracting &&
          !isTransitioning &&
          currentIndex < maxIndex) {
        nextScreen();
      }
    });

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic),
        );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    slideController.forward();
    fadeController.forward();
    startAutoAdvance();
  }

  void startAutoAdvance() {
    if (isTimerRunning) return;

    isTimerRunning = true;
    progressController.forward(); // This starts the progress animation
  }

  void nextScreen() {
    if (currentIndex < totalScreens - 1 && !isTransitioning) {
      isTransitioning = true;
      fadeController.reverse().then((_) {
        currentIndex++;
        notifyListeners();
        pageController
            .animateToPage(
              currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              isTransitioning = false;
              resetProgress();
            });
      });
    }
  }

  void previousScreen() {
    if (currentIndex > 0 && !isTransitioning) {
      isTransitioning = true;
      fadeController.reverse().then((_) {
        currentIndex--;
        notifyListeners();
        pageController
            .animateToPage(
              currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              isTransitioning = false;
              resetProgress();
            });
      });
    }
  }

  void goToScreen(int index) {
    if (index >= 0 &&
        index < totalScreens &&
        index != currentIndex &&
        !isTransitioning) {
      // Stop current progress animation
      progressController.stop();
      autoAdvanceTimer?.cancel();
      isTimerRunning = false;
      isTransitioning = true;

      fadeController.reverse().then((_) {
        currentIndex = index;
        notifyListeners();
        pageController
            .animateToPage(
              currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
              isTransitioning = false;
              resetProgress();
            });
      });
    }
  }

  void resetProgress() {
    progressController.reset();
    slideController.reset();
    fadeController.reset();
    slideController.forward();
    fadeController.forward();
    startAutoAdvance(); // This will restart the progress animation
  }

  void setUserInteracting(bool interacting) {
    isUserInteracting = interacting;
    if (interacting) {
      autoAdvanceTimer?.cancel();
      isTimerRunning = false;
    } else {
      startAutoAdvance();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    progressController.dispose();
    slideController.dispose();
    fadeController.dispose();
    autoAdvanceTimer?.cancel();
    super.dispose();
  }
}
