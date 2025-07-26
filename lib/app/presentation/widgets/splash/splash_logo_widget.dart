import 'package:flutter/material.dart';

class SplashLogoWidget extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double fontSize;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double letterSpacing;

  const SplashLogoWidget({
    super.key,
    this.text = 'ZIMA',
    this.width = 174.57,
    this.height = 51.75,
    this.fontSize = 32,
    required this.fadeAnimation,
    required this.scaleAnimation,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderRadius = 8,
    this.letterSpacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Clash Display Variable',
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: letterSpacing,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
