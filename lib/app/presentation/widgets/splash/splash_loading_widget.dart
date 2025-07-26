import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashLoadingWidget extends StatelessWidget {
  final AnimationController rotationController;
  final Animation<double> fadeAnimation;
  final List<String> loadingTexts;
  final int repeatCount;
  final Color spinnerColor;
  final Color textColor;
  final double spinnerSize;
  final double textSize;
  final Duration textDuration;

  const SplashLoadingWidget({
    super.key,
    required this.rotationController,
    required this.fadeAnimation,
    this.loadingTexts = const ['Loading...', 'Preparing your experience...'],
    this.repeatCount = 3,
    this.spinnerColor = Colors.white,
    this.textColor = Colors.white,
    this.spinnerSize = 23,
    this.textSize = 14,
    this.textDuration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Loading Spinner with enhanced animations
        RotationTransition(
              turns: rotationController,
              child: Container(
                width: spinnerSize,
                height: spinnerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(spinnerSize / 2),
                  border: Border.all(
                    color: spinnerColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: spinnerColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: spinnerSize - 8,
                    height: spinnerSize - 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5), duration: 800.ms),

        const SizedBox(height: 20),

        // Loading text with animation
        AnimatedTextKit(
          animatedTexts: loadingTexts
              .map(
                (text) => FadeAnimatedText(
                  text,
                  textStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: textSize,
                    fontWeight: FontWeight.w400,
                  ),
                  duration: textDuration,
                ),
              )
              .toList(),
          totalRepeatCount: repeatCount,
        ),
      ],
    );
  }
}
