import 'package:flutter/material.dart';
import 'splash_controller.dart';

class SplashControllerProvider extends ChangeNotifier {
  SplashController? _controller;

  SplashController? get controller => _controller;

  void initialize(TickerProvider vsync, VoidCallback onNavigation) {
    _controller = SplashController();
    _controller!.initialize(vsync, onNavigation);
    notifyListeners();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    notifyListeners();
  }
}
