import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../application/providers/auth_provider.dart';
import '../../../home/presentation/home_page.dart';
import '../../../onboarding/providers/onboarding_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordView = false;

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void _nextToPassword() {
    if (_usernameController.text.trim().isEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      return;
    }
    setState(() {
      _isPasswordView = true;
    });
    // Clear any previous errors
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
  }

  void _backToUsername() {
    setState(() {
      _isPasswordView = false;
    });
    // Clear any previous errors
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
  }

  Future<void> _resetOnboarding() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.resetOnboarding();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),

                  // Header Section
                  Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPasswordView
                                ? 'ENTER YOUR PASSWORD'
                                : 'ENTER YOUR USERNAME',
                            style: TextStyle(
                              fontFamily: 'Clash Display Variable',
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                              height: 1.0,
                              letterSpacing: 0.2,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.color ??
                                  Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                                'We do not share your personal details.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  height: 1.375,
                                  color:
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.8) ??
                                      Colors.black.withValues(alpha: 0.8),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 600.ms)
                              .slideY(begin: 0.3, duration: 600.ms),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Input Field
                  Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            if (!_isPasswordView) ...[
                              // Username icon
                              Icon(
                                CupertinoIcons.person,
                                color: Colors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: TextField(
                                controller: _isPasswordView
                                    ? _passwordController
                                    : _usernameController,
                                obscureText: _isPasswordView,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  height: 1.193,
                                  letterSpacing: -0.02,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: _isPasswordView
                                      ? 'Password'
                                      : 'Username',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                    color: Color(0xFFAFB6BA),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                              ),
                            ),
                            if (_isPasswordView) ...[
                              IconButton(
                                icon: Icon(
                                  CupertinoIcons.eye_slash,
                                  color: const Color(0xFFAFB6BA),
                                  size: 17.32,
                                ),
                                onPressed: () {
                                  // Toggle password visibility
                                },
                              ),
                            ],
                            const SizedBox(width: 16),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  // Error Message
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle,
                                color: Colors.red.withValues(alpha: 0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.2, duration: 300.ms),
                  ],

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CupertinoButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : (_isPasswordView ? _login : _nextToPassword),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: authProvider.isLoading
                              ? const CupertinoActivityIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    height: 1.193,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Back Button (only in password view)
                  if (_isPasswordView) ...[
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: CupertinoButton(
                            onPressed: _backToUsername,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                height: 1.193,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color ??
                                    Colors.black,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideY(begin: 0.3, duration: 600.ms),

                    const SizedBox(height: 16),
                  ],

                  // Debug Section (only in debug mode)
                  if (const bool.fromEnvironment('dart.vm.product') ==
                      false) ...[
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Tools',
                                style: TextStyle(
                                  color: Colors.grey.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoButton(
                                      onPressed: _resetOnboarding,
                                      color: Colors.blue.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Text(
                                        'Reset Onboarding',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CupertinoButton(
                                    onPressed: () {
                                      _usernameController.text = 'testuser';
                                      _passwordController.text = 'testpass';
                                    },
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Text(
                                      'Fill Test',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(begin: 0.3, duration: 600.ms),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
