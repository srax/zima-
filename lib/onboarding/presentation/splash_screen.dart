import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _fadeController.forward();

    // Simulate loading time
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF000000), Color(0xFF1a1a1a), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar space
              const SizedBox(height: 54),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Zima Logo with animations
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 174.57,
                              height: 51.75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'ZIMA',
                                  style: const TextStyle(
                                    fontFamily: 'Clash Display Variable',
                                    color: Colors.black,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 200),

                    // Loading Spinner with enhanced animations
                    RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
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
                      animatedTexts: [
                        FadeAnimatedText(
                          'Loading...',
                          textStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                        FadeAnimatedText(
                          'Preparing your experience...',
                          textStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      ],
                      totalRepeatCount: 3,
                    ),
                  ],
                ),
              ),

              // Footer text with animation
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child:
                    FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Zima Protocol, Inc.',
                            style: TextStyle(
                              color: const Color(
                                0xFF898989,
                              ).withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.24,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 800.ms)
                        .slideY(begin: 0.3, duration: 800.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
