import 'package:flutter/material.dart';
import 'onboarding_controller.dart';

class OnboardingControllerProvider extends ChangeNotifier {
  OnboardingController? _controller;

  OnboardingController? get controller => _controller;

  void initialize(TickerProvider vsync, {int? totalScreens}) {
    _controller = OnboardingController();
    _controller!.initialize(vsync, totalScreens: totalScreens);
    notifyListeners();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    notifyListeners();
  }
}
