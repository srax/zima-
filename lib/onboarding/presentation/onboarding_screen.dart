import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/onboarding_screen.dart';
import '../providers/onboarding_provider.dart';
import '../application/onboarding_controller_provider.dart';
import '../application/onboarding_controller.dart';
import '../../../app/presentation/widgets/widgets.dart';
import '../../../main_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late OnboardingControllerProvider _controllerProvider;

  @override
  void initState() {
    super.initState();
    _controllerProvider = OnboardingControllerProvider();
    _controllerProvider.initialize(
      this,
      totalScreens: OnboardingData.screens.length,
    );
  }

  @override
  void dispose() {
    _controllerProvider.dispose();
    super.dispose();
  }

  void _skipOnboarding() {
    Provider.of<OnboardingProvider>(
      context,
      listen: false,
    ).completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controllerProvider,
        builder: (context, child) {
          final controller = _controllerProvider.controller;
          if (controller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // PageView with onboarding content
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.goToScreen(index);
                },
                itemCount: OnboardingData.screens.length,
                itemBuilder: (context, index) {
                  final screen = OnboardingData.screens[index];
                  return _buildOnboardingPage(screen, controller);
                },
              ),

              // Progress Indicators
              Positioned(
                top: 62,
                left: 16,
                right: 16,
                child: ProgressIndicators(
                  currentIndex: controller.currentIndex,
                  totalSteps: OnboardingData.screens.length,
                  progressAnimation: controller.progressAnimation,
                ),
              ),

              // Bottom Buttons
              Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: OnboardingBottomButtons(
                  isLastScreen:
                      controller.currentIndex ==
                      OnboardingData.screens.length - 1,
                  onNext: controller.nextScreen,
                  onSkip: _skipOnboarding,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOnboardingPage(
    OnboardingPage screen,
    OnboardingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
            Colors.black,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: AnimatedBackground(
        child: OnboardingPageContent(
          title: screen.title,
          description: screen.description,
          slideAnimation: controller.slideAnimation,
          fadeAnimation: controller.fadeAnimation,
        ),
      ),
    );
  }
}
