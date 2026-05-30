import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

/// Splash de bootstrap: anima a marca e decide a rota inicial.
///
/// A decisão (onboarding vs welcome) fica no roteador via [onReady] — aqui só
/// cuidamos da animação e do tempo mínimo de exibição.
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
      await Future<void>.delayed(const Duration(milliseconds: 1600));
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
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.06)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/NobleNibs-logo.png',
                  height: 160,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack, duration: 700.ms)
                    .fadeIn(),
                const SizedBox(height: AppSpacing.lg),
                Text('café em grãos', style: AppTypography.overline)
                    .animate()
                    .fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
