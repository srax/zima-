import 'package:flutter/material.dart';
import '../common/text/heading_text.dart';
import '../common/text/body_text.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 200),

          // Title with animation
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: HeadingText(text: title),
            ),
          ),

          const SizedBox(height: 16),

          // Description with animation
          SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: BodyText(
                text: description,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
