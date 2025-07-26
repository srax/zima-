import 'package:flutter/material.dart';

class ProgressIndicators extends StatefulWidget {
  final int currentIndex;
  final int totalSteps;
  final double height;
  final double spacing;
  final Color activeColor;
  final Color completedColor;
  final Color inactiveColor;
  final double borderRadius;
  final Duration animationDuration;
  final Animation<double>? progressAnimation;

  const ProgressIndicators({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    this.height = 3,
    this.spacing = 3,
    this.activeColor = Colors.white,
    this.completedColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.borderRadius = 1.5,
    this.animationDuration = const Duration(milliseconds: 300),
    this.progressAnimation,
  });

  @override
  State<ProgressIndicators> createState() => _ProgressIndicatorsState();
}

class _ProgressIndicatorsState extends State<ProgressIndicators>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ProgressIndicators oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        final isActive = index == widget.currentIndex;
        final isCompleted = index < widget.currentIndex;
        final isInactive = index > widget.currentIndex;

        Color indicatorColor;
        if (isActive) {
          indicatorColor = widget.activeColor;
        } else if (isCompleted) {
          indicatorColor = widget.completedColor;
        } else {
          indicatorColor = widget.inactiveColor.withValues(alpha: 0.3);
        }

        Widget indicator = Container(
          height: widget.height,
          margin: EdgeInsets.only(
            right: index < widget.totalSteps - 1 ? widget.spacing : 0,
          ),
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );

        // Add progressive filling for active indicator
        if (isActive && widget.progressAnimation != null) {
          return Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _glowAnimation,
                _scaleAnimation,
                widget.progressAnimation!,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius + 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withValues(
                            alpha: 0.6 * _glowAnimation.value,
                          ),
                          blurRadius: 8 + (4 * _glowAnimation.value),
                          spreadRadius: 2 + (2 * _glowAnimation.value),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background (inactive color)
                        Container(
                          height: widget.height,
                          decoration: BoxDecoration(
                            color: widget.inactiveColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                          ),
                        ),
                        // Progressive fill
                        FractionallySizedBox(
                          widthFactor: widget.progressAnimation!.value,
                          child: Container(
                            height: widget.height,
                            decoration: BoxDecoration(
                              color: widget.activeColor,
                              borderRadius: BorderRadius.circular(
                                widget.borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Add glowing effect and animation for active indicator (without progress)
        if (isActive) {
          return Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([_glowAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius + 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withValues(
                            alpha: 0.6 * _glowAnimation.value,
                          ),
                          blurRadius: 8 + (4 * _glowAnimation.value),
                          spreadRadius: 2 + (2 * _glowAnimation.value),
                        ),
                      ],
                    ),
                    child: indicator,
                  ),
                );
              },
            ),
          );
        }

        return Expanded(child: indicator);
      }),
    );
  }
}
