import 'package:flutter/material.dart';
import '../application/splash_controller_provider.dart';
import '../../../app/presentation/widgets/widgets.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashControllerProvider _controllerProvider;

  @override
  void initState() {
    super.initState();
    _controllerProvider = SplashControllerProvider();
    _controllerProvider.initialize(this, _navigateToOnboarding);
  }

  @override
  void dispose() {
    _controllerProvider.dispose();
    super.dispose();
  }

  void _navigateToOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF1a1a1a), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _controllerProvider,
            builder: (context, child) {
              final controller = _controllerProvider.controller;
              if (controller == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Status bar space
                  const SizedBox(height: 54),

                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Zima Logo with animations
                        SplashLogoWidget(
                          fadeAnimation: controller.fadeAnimation,
                          scaleAnimation: controller.scaleAnimation,
                        ),

                        const SizedBox(height: 200),

                        // Loading Spinner and text
                        SplashLoadingWidget(
                          rotationController: controller.rotationController,
                          fadeAnimation: controller.fadeAnimation,
                        ),
                      ],
                    ),
                  ),

                  // Footer text with animation
                  SplashFooterWidget(fadeAnimation: controller.fadeAnimation),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
