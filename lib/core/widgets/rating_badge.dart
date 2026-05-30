import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Pílula de avaliação ("4.7 ★"), como nas referências.
///
/// [onDark] alterna o esquema para uso sobre o cartão escuro de produto.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.onDark = false});

  final double rating;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final bg = onDark ? AppColors.cream : AppColors.creamSoft;
    final fg = AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.label.copyWith(
              color: fg,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
        ],
      ),
    );
  }
}
