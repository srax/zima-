import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashFooterWidget extends StatelessWidget {
  final String text;
  final Animation<double> fadeAnimation;
  final Color textColor;
  final double fontSize;
  final double letterSpacing;
  final EdgeInsets padding;
  final Duration animationDelay;
  final Duration animationDuration;

  const SplashFooterWidget({
    super.key,
    this.text = 'Zima Protocol, Inc.',
    required this.fadeAnimation,
    this.textColor = const Color(0xFF898989),
    this.fontSize = 13,
    this.letterSpacing = 0.24,
    this.padding = const EdgeInsets.only(bottom: 50),
    this.animationDelay = const Duration(milliseconds: 1000),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child:
          FadeTransition(
                opacity: fadeAnimation,
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: letterSpacing,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: animationDelay, duration: animationDuration)
              .slideY(begin: 0.3, duration: animationDuration),
    );
  }
}
