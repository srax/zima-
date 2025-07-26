import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../models/onboarding_screen.dart';
import '../providers/onboarding_provider.dart';
import '../../../main_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  Timer? _autoAdvanceTimer;
  bool _isUserInteracting = false;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    if (_isTimerRunning) return; // Prevent multiple timers

    _isTimerRunning = true;
    _progressController.forward();
    _autoAdvanceTimer?.cancel(); // Cancel any existing timer first
    _autoAdvanceTimer = Timer(const Duration(seconds: 5), () {
      _isTimerRunning = false;
      if (mounted &&
          !_isUserInteracting &&
          _currentIndex < OnboardingData.screens.length - 1) {
        // Auto-advance with fade effect
        _nextScreen();
      }
    });
  }

  void _nextScreen() {
    if (_currentIndex < OnboardingData.screens.length - 1) {
      // Fade out current content
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentIndex++;
          });
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // Fade in new content
          _resetProgress();
        }
      });
    } else {
      _completeOnboarding();
    }
  }

  void _resetProgress() {
    _isTimerRunning = false;
    _autoAdvanceTimer?.cancel(); // Cancel existing timer
    _progressController.reset();
    _slideController.reset();
    _fadeController.reset();
    _slideController.forward();
    _fadeController.forward();
    _startAutoAdvance();
  }

  void _completeOnboarding() async {
    _isTimerRunning = false;
    _autoAdvanceTimer?.cancel(); // Cancel timer before navigation

    // Fade out current content
    await _fadeController.reverse();

    if (!mounted) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  void _skipOnboarding() async {
    _isTimerRunning = false;
    _autoAdvanceTimer?.cancel(); // Cancel timer before navigation

    // Fade out current content
    await _fadeController.reverse();

    if (!mounted) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    await provider.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) {
          _isUserInteracting = true;
          _autoAdvanceTimer?.cancel(); // Cancel timer on user interaction
        },
        onTapUp: (_) {
          _isUserInteracting = false;
          // Restart timer after user interaction with a small delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted &&
                !_isUserInteracting &&
                _currentIndex < OnboardingData.screens.length - 1) {
              _startAutoAdvance();
            }
          });
        },
        onTap: () {
          if (!_isUserInteracting) {
            _nextScreen();
          }
        },
        child: Stack(
          children: [
            // Background PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _resetProgress();
              },
              itemCount: OnboardingData.screens.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(OnboardingData.screens[index]);
              },
            ),

            // Progress Indicators
            Positioned(
              top: 62,
              left: 16,
              right: 16,
              child: _buildProgressIndicators(),
            ),

            // Bottom Buttons
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildBottomButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage screen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
            Colors.black,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background Image with enhanced gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[900]!,
                  Colors.purple[900]!,
                  Colors.indigo[900]!,
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Animated background particles
          ...List.generate(20, (index) => _buildParticle(index)),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),

                // Title with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      screen.title,
                      style: const TextStyle(
                        fontFamily: 'Clash Display Variable',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      screen.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.375,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    return Positioned(
      left: (index * 37) % MediaQuery.of(context).size.width,
      top: (index * 73) % MediaQuery.of(context).size.height,
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      children: List.generate(4, (index) {
        final screen = OnboardingData.screens[_currentIndex];
        final status = screen.progressIndicators[index];

        return Expanded(
          child:
              Container(
                    height: 3,
                    margin: EdgeInsets.only(right: index < 3 ? 3 : 0),
                    decoration: BoxDecoration(
                      color: status == 'active'
                          ? Colors.white
                          : status == 'completed'
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: status == 'active'
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: status == 'active'
                        ? AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  )
                  .animate()
                  .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), duration: 400.ms),
        );
      }),
    );
  }

  Widget _buildBottomButtons() {
    final screen = OnboardingData.screens[_currentIndex];

    return Column(
      children: [
        // Privacy Policy Text with enhanced styling
        Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'icons/accept-terms.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Colors.white.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By tapping next, you are agreeing to Zima Protocol Terms of Use & Privacy Policy. See how your data is managed.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.32,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms),

        const SizedBox(height: 32),

        // Buttons with enhanced styling
        Column(
          children: [
            // Get Started Button
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CupertinoButton(
                    onPressed: _nextScreen,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      screen.isLastScreen ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 5),

            // Sign In Button
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CupertinoButton(
                    onPressed: _skipOnboarding,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),
          ],
        ),
      ],
    );
  }
}
