import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated SENTRIFI wordmark with staggered letter reveal and shimmer.
class SentrifLogoAnimation extends StatefulWidget {
  const SentrifLogoAnimation({super.key, this.fontSize = 42});

  final double fontSize;

  @override
  State<SentrifLogoAnimation> createState() => _SentrifLogoAnimationState();
}

class _SentrifLogoAnimationState extends State<SentrifLogoAnimation>
    with TickerProviderStateMixin {
  static const _letters = 'SENTRIFI';

  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;
  late final AnimationController _glowController;
  late final List<Animation<double>> _letterAnimations;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _letterAnimations = List.generate(_letters.length, (index) {
      final start = index * 0.08;
      final end = math.min(start + 0.45, 1.0);

      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _entranceController.forward().then((_) {
      if (!mounted) return;
      _shimmerController.repeat();
      _glowController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _shimmerController,
        _glowController,
      ]),
      builder: (context, child) {
        final glowOpacity = 0.15 + (_glowController.value * 0.2);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glowOpacity),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.accent.withValues(
                      alpha: glowOpacity * 0.5,
                    ),
                    blurRadius: 60,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  final shimmerProgress = _shimmerController.value;
                  final shimmerStart = -1.0 + (shimmerProgress * 2.5);
                  final shimmerEnd = shimmerStart + 0.6;

                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      AppColors.primary,
                      AppColors.textPrimary,
                      AppColors.accent,
                      AppColors.primaryDark,
                      AppColors.textPrimary,
                    ],
                    stops: [
                      (shimmerStart).clamp(0.0, 1.0),
                      (shimmerStart + 0.15).clamp(0.0, 1.0),
                      (shimmerStart + 0.3).clamp(0.0, 1.0),
                      (shimmerEnd - 0.1).clamp(0.0, 1.0),
                      (shimmerEnd).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_letters.length, (index) {
                    final letter = _letters[index];
                    final animation = _letterAnimations[index];
                    final isFiAccent = index >= 6;

                    return _AnimatedLetter(
                      letter: letter,
                      progress: animation.value,
                      fontSize: widget.fontSize,
                      accent: isFiAccent,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: Curves.easeOut.transform(
                ((_entranceController.value - 0.6) / 0.4).clamp(0.0, 1.0),
              ),
              child: Text(
                'Secure. Smart. SentriFi.',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: widget.fontSize * 0.32,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.letter,
    required this.progress,
    required this.fontSize,
    required this.accent,
  });

  final String letter;
  final double progress;
  final double fontSize;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final opacity = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final slideY = (1 - progress) * 28;
    final scale = 0.4 + (progress * 0.6);
    final rotation = (1 - progress) * (accent ? -0.15 : 0.12);

    return Transform.translate(
      offset: Offset(0, slideY),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: accent ? 1 : 2,
                height: 1,
                color: accent ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
