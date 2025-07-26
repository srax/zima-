import 'package:flutter/material.dart';
import 'dart:async';

class SplashController extends ChangeNotifier {
  late AnimationController rotationController;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  Timer? navigationTimer;

  bool isInitialized = false;

  void initialize(TickerProvider vsync, VoidCallback onNavigation) {
    if (isInitialized) return;

    rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    )..repeat();

    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut));

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.elasticOut),
    );

    fadeController.forward();

    // Simulate loading time
    navigationTimer = Timer(const Duration(seconds: 3), onNavigation);

    isInitialized = true;
    notifyListeners();
  }

  void dispose() {
    rotationController.dispose();
    fadeController.dispose();
    navigationTimer?.cancel();
    super.dispose();
  }
}
