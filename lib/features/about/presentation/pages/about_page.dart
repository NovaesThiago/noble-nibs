import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

/// Tela "Sobre o Noble Nibs".
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, this.onBack});

  final VoidCallback? onBack;

  static const _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: const Text('Sobre'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.05)),
          ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Image.asset(
                  'assets/images/NobleNibs-logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'Versão $_version',
                  style: AppTypography.label.copyWith(letterSpacing: 0),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Café em grãos, do produtor à sua xícara',
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'A Noble Nibs seleciona microlotes de origens especiais e torra em '
                'pequenos lotes, no ponto ideal para cada perfil sensorial. Nosso '
                'propósito é levar até você um café fresco, rastreável e com história.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _LinkTile(icon: Icons.description_outlined, label: 'Termos de uso', onTap: () {}),
              _LinkTile(icon: Icons.privacy_tip_outlined, label: 'Política de privacidade', onTap: () {}),
              _LinkTile(icon: Icons.star_outline_rounded, label: 'Avaliar o app', onTap: () {}),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  '© 2026 Noble Nibs · Feito com ☕ e cuidado',
                  style: AppTypography.label.copyWith(letterSpacing: 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.caramelDeep),
        title: Text(label, style: AppTypography.body.copyWith(color: context.ink)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: onTap,
      );
}
