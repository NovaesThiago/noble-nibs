import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

/// Splash de bootstrap: anima a marca e decide a rota inicial.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.onReady});

  final VoidCallback? onReady;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 2600));
      if (!mounted) return;
      widget.onReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          // Fundo gradiente quente.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.cream, AppColors.creamSoft],
              ),
            ),
            child: SizedBox.expand(),
          ),
          const Positioned.fill(
            child: BeanPatternBackground(opacity: 0.08, density: 28),
          ),
          // Grãos flutuando (acentos animados).
          const _FloatingBean(top: 90, left: 36, size: 30, delayMs: 0),
          const _FloatingBean(top: 160, right: 44, size: 22, delayMs: 400),
          const _FloatingBean(bottom: 180, left: 54, size: 26, delayMs: 800),
          const _FloatingBean(bottom: 120, right: 48, size: 18, delayMs: 1200),

          // Conteúdo central.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glow + logo grande, com entrada e respiração contínua.
                _LogoBlock()
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      curve: Curves.easeOutBack,
                      duration: 800.ms,
                    ),
                const SizedBox(height: AppSpacing.lg),
                Text('café em grãos · torra artesanal', style: AppTypography.overline)
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.4, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.xxl),
                const _LoadingDots()
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo grande com um halo radial atrás e pulsação suave contínua.
class _LogoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo / glow.
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.caramel.withValues(alpha: 0.28),
                  AppColors.caramel.withValues(alpha: 0),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 0.9, end: 1.08, duration: 1800.ms, curve: Curves.easeInOut),
          // Logo.
          Image.asset('assets/images/NobleNibs-logo.png', height: 210, fit: BoxFit.contain)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.04, duration: 1800.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

/// Grão de café que flutua suavemente, em loop.
class _FloatingBean extends StatelessWidget {
  const _FloatingBean({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.delayMs,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(Icons.eco_rounded, size: size, color: AppColors.caramelDeep.withValues(alpha: 0.5))
          .animate(onPlay: (c) => c.repeat(reverse: true), delay: delayMs.ms)
          .moveY(begin: -10, end: 10, duration: 2600.ms, curve: Curves.easeInOut)
          .rotate(begin: -0.05, end: 0.05, duration: 2600.ms, curve: Curves.easeInOut),
    );
  }
}

/// Três pontinhos pulsando (indicador de carregamento).
class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(color: AppColors.caramel, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 500.ms, delay: (i * 180).ms)
              .scaleXY(begin: 0.6, end: 1, duration: 500.ms, delay: (i * 180).ms),
      ],
    );
  }
}
