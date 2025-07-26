import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/buttons/primary_button.dart';
import '../common/buttons/secondary_button.dart';
import '../common/forms/privacy_policy_card.dart';

class OnboardingBottomButtons extends StatelessWidget {
  final bool isLastScreen;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool showPrivacyPolicy;

  const OnboardingBottomButtons({
    super.key,
    required this.isLastScreen,
    required this.onNext,
    required this.onSkip,
    this.showPrivacyPolicy = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Privacy Policy Text
        if (showPrivacyPolicy) ...[
          const PrivacyPolicyCard(),
          const SizedBox(height: 32),
        ],

        // Buttons
        Column(
          children: [
            // Get Started/Next Button
            PrimaryButton(
                  text: isLastScreen ? 'Get Started' : 'Next',
                  onPressed: onNext,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 5),

            // Sign In Button
            SecondaryButton(text: 'Sign in', onPressed: onSkip)
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),
          ],
        ),
      ],
    );
  }
}
