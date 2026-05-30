import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

/// Tela de boas-vindas — vitrine da direção estética "Specialty Coffee".
///
/// Composição: padrão de grãos ao fundo + gradiente quente, hero de discos
/// sobrepostos (assimétrico, grid-breaking), tipografia editorial Fraunces,
/// e uma entrada de página orquestrada (revelações escalonadas).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, this.onEnter, this.onLogin});

  /// Callback do CTA (navega para o catálogo).
  final VoidCallback? onEnter;

  /// Callback do link "Já tenho conta".
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    const stagger = Duration(milliseconds: 90);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, AppColors.creamSoft],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: BeanPatternBackground(opacity: 0.05, density: 30),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text('ESPECIALIDADE · TORRA ARTESANAL', style: AppTypography.overline)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.15, curve: Curves.easeOut),
                    const Spacer(),
                    // Hero assimétrico de discos sobrepostos.
                    const Center(child: _HeroComposition())
                        .animate()
                        .fadeIn(delay: stagger, duration: 700.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          curve: Curves.easeOutBack,
                          duration: 700.ms,
                        ),
                    const Spacer(),
                    Text('Noble Nibs', style: AppTypography.display)
                        .animate()
                        .fadeIn(delay: stagger * 2, duration: 600.ms)
                        .slideY(begin: 0.25, curve: Curves.easeOut),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Grãos selecionados, torrados em pequenos lotes. '
                      'Do produtor à sua xícara — cada origem com sua história.',
                      style: AppTypography.body.copyWith(fontSize: 16),
                    )
                        .animate()
                        .fadeIn(delay: stagger * 3, duration: 600.ms)
                        .slideY(begin: 0.25, curve: Curves.easeOut),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      'Explorar o catálogo',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: onEnter ?? () {},
                    )
                        .animate()
                        .fadeIn(delay: stagger * 4, duration: 600.ms)
                        .slideY(begin: 0.4, curve: Curves.easeOut),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: AppButton.ghost(
                        'Já tenho conta',
                        onPressed: onLogin,
                      ),
                    ).animate().fadeIn(delay: stagger * 5, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Discos sobrepostos representando grãos/torra — composição assimétrica.
class _HeroComposition extends StatelessWidget {
  const _HeroComposition();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pacote do produto (imagem real), com flutuação sutil.
          Image.asset(
            'assets/images/pacote-noble-nibs.png',
            width: 240,
            height: 240,
            fit: BoxFit.contain,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -4, end: 6, duration: 2800.ms, curve: Curves.easeInOut),
          // Pequeno selo creme (etiqueta "100% arábica").
          Positioned(
            left: 4,
            top: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppShadows.soft,
              ),
              child: Text('100% arábica', style: AppTypography.label),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: 8, duration: 2600.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

