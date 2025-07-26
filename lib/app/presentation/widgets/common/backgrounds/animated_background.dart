import 'package:flutter/material.dart';

class AnimatedBackground extends StatelessWidget {
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final int particleCount;
  final Color particleColor;
  final double particleSize;
  final Widget? child;

  const AnimatedBackground({
    super.key,
    this.gradientColors = const [
      Colors.blue,
      Colors.purple,
      Colors.indigo,
      Colors.black,
    ],
    this.gradientStops = const [0.0, 0.3, 0.7, 1.0],
    this.particleCount = 20,
    this.particleColor = Colors.white,
    this.particleSize = 2,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: gradientStops,
        ),
      ),
      child: Stack(
        children: [
          // Animated background particles
          ...List.generate(particleCount, (index) => _buildParticle(index)),
          // Content
          if (child != null) child!,
        ],
      ),
    );
  }

  Widget _buildParticle(int index) {
    return Positioned(
      left: (index * 37) % 400, // Use fixed width for consistency
      top: (index * 73) % 800, // Use fixed height for consistency
      child: Container(
        width: particleSize,
        height: particleSize,
        decoration: BoxDecoration(
          color: particleColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
