import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_page.dart';
import 'onboarding/presentation/splash_screen.dart';
import 'onboarding/providers/onboarding_provider.dart';
import 'auth/application/providers/auth_provider.dart';
import 'auth/presentation/screens/login_screen.dart';
import 'wallet/providers/wallet_provider.dart';
import 'wallet/presentation/wallet_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => WalletProvider()),
    ],
    child: MaterialApp(
      title: 'D-ID Agent',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const AppRouter(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/wallet': (context) => const WalletPage(),
      },
    ),
  );
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        // Show loading while checking onboarding status
        if (onboardingProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if there's an issue loading onboarding status
        if (onboardingProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${onboardingProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => onboardingProvider.resetOnboarding(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Route based on onboarding status
        if (!onboardingProvider.hasCompletedOnboarding) {
          return const SplashScreen();
        }
        return const MainPage();
      },
    );
  }
}
