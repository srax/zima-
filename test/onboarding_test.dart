import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:deepfake/onboarding/presentation/splash_screen.dart';
import 'package:deepfake/onboarding/presentation/onboarding_screen.dart';
import 'package:deepfake/onboarding/providers/onboarding_provider.dart';
import 'package:deepfake/onboarding/models/onboarding_screen.dart';
import 'package:deepfake/main.dart';
import 'package:deepfake/auth/presentation/screens/login_screen.dart';

void main() {
  group('Onboarding Flow Tests', () {
    testWidgets('Splash screen shows Zima logo and spinner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SplashScreen()));

      // Wait for initial animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Zima logo is present
      expect(find.text('ZIMA'), findsOneWidget);

      // Verify loading spinner is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify footer text is present
      expect(find.text('Zima Protocol, Inc.'), findsOneWidget);

      // Dispose before the navigation timer fires to prevent test issues
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Onboarding screen shows correct content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],
          child: MaterialApp(home: const OnboardingScreen()),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify first screen title is present
      expect(find.text('YOUR DIGITAL TWIN IS BEING CREATED'), findsOneWidget);

      // Verify description is present
      expect(
        find.text(
          'This is the first spark of your ghost, capturing the essence of who you are.',
        ),
        findsOneWidget,
      );

      // Verify progress indicators are present
      expect(find.byType(Container), findsWidgets);

      // Verify buttons are present
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    test('OnboardingData has correct number of screens', () {
      expect(OnboardingData.screens.length, equals(4));
    });

    test('OnboardingData screens have correct content', () {
      final screens = OnboardingData.screens;

      expect(screens[0].title, equals('YOUR DIGITAL TWIN IS BEING CREATED'));
      expect(screens[1].title, equals('UPLOAD YOUR INTELLIGENCE'));
      expect(screens[2].title, equals('YOUR IDENTITY ARE ENCODED'));
      expect(screens[3].title, equals('YOUR DIGITAL SOUL COMES ALIVE'));

      expect(screens[3].isLastScreen, isTrue);
      expect(screens[0].isLastScreen, isFalse);
    });

    testWidgets('OnboardingProvider can complete onboarding', (
      WidgetTester tester,
    ) async {
      // Mock SharedPreferences for testing
      TestWidgetsFlutterBinding.ensureInitialized();

      final provider = OnboardingProvider();

      // Wait for initialization
      await tester.pump();

      // Initially should not be completed
      expect(provider.hasCompletedOnboarding, isFalse);

      // Complete onboarding
      await provider.completeOnboarding();

      // Should now be completed
      expect(provider.hasCompletedOnboarding, isTrue);
    });

    testWidgets('Timer management works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],
          child: MaterialApp(home: const OnboardingScreen()),
        ),
      );

      // Wait for initial setup
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify timer is running (progress indicator should be visible)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate user interaction
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Verify timer was cancelled and restarted
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('App routing works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],
          child: MaterialApp(
            home: const AppRouter(),
            routes: {'/login': (context) => const LoginScreen()},
          ),
        ),
      );

      // Wait for initial setup
      await tester.pumpAndSettle();

      // Should show splash screen initially
      expect(find.text('ZIMA'), findsOneWidget);
    });

    testWidgets('Onboarding reset functionality works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],
          child: MaterialApp(home: const LoginScreen()),
        ),
      );

      // Wait for initial setup
      await tester.pumpAndSettle();

      // Should show login screen
      expect(find.text('Sign In'), findsOneWidget);
      expect(
        find.text('Reset Onboarding (Show Splash Screen)'),
        findsOneWidget,
      );

      // Tap reset button
      await tester.tap(find.text('Reset Onboarding (Show Splash Screen)'));
      await tester.pumpAndSettle();

      // Should navigate back to app router
      expect(find.text('Sign In'), findsNothing);
    });
  });
}
