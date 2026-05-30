import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Perfil sensorial: barras de acidez/corpo/doçura (1–5) + descritores.
class TastingNotesView extends StatelessWidget {
  const TastingNotesView({super.key, required this.notes});

  final TastingNotes notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(label: 'Acidez', value: notes.acidity),
        const SizedBox(height: AppSpacing.sm),
        _Bar(label: 'Corpo', value: notes.body),
        const SizedBox(height: AppSpacing.sm),
        _Bar(label: 'Doçura', value: notes.sweetness),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final d in notes.descriptors)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(d, style: AppTypography.label.copyWith(letterSpacing: 0)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: AppTypography.label.copyWith(letterSpacing: 0)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Expanded(
                  child: Container(
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: i <= value ? AppColors.caramel : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
