class OnboardingPage {
  final String title;
  final String description;
  final String backgroundImage;
  final List<String> progressIndicators;
  final bool isLastScreen;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.backgroundImage,
    required this.progressIndicators,
    this.isLastScreen = false,
  });
}

class OnboardingData {
  static const List<OnboardingPage> screens = [
    OnboardingPage(
      title: 'YOUR DIGITAL TWIN IS BEING CREATED',
      description:
          'This is the first spark of your ghost, capturing the essence of who you are.',
      backgroundImage: 'assets/images/onboarding_1.jpg',
      progressIndicators: ['active', 'inactive', 'inactive', 'inactive'],
    ),
    OnboardingPage(
      title: 'UPLOAD YOUR INTELLIGENCE',
      description:
          'Your thoughts and patterns are securely transferred to shape your unique ghost.',
      backgroundImage: 'assets/images/onboarding_2.jpg',
      progressIndicators: ['completed', 'active', 'inactive', 'inactive'],
    ),
    OnboardingPage(
      title: 'YOUR IDENTITY ARE ENCODED',
      description:
          'Every fragment of your data is encrypted and linked to form your ghost\'s DNA.',
      backgroundImage: 'assets/images/onboarding_3.jpg',
      progressIndicators: ['completed', 'completed', 'active', 'inactive'],
    ),
    OnboardingPage(
      title: 'YOUR DIGITAL SOUL COMES ALIVE',
      description:
          'Your ghost awakens, ready to learn, evolve, and live beyond you.',
      backgroundImage: 'assets/images/onboarding_4.jpg',
      progressIndicators: ['completed', 'completed', 'completed', 'active'],
      isLastScreen: true,
    ),
  ];
}
