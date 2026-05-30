import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Seletor de opção única em formato de pílulas (peso, moagem...).
///
/// Genérico e presentacional: recebe rótulos e o índice selecionado.
class PillSelector extends StatelessWidget {
  const PillSelector({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < labels.length; i++)
          _Pill(
            label: labels[i],
            selected: i == selectedIndex,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(i);
            },
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.coffeeDark : context.chipBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.coffeeDark : context.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.button.copyWith(
            fontSize: 14,
            color: selected ? AppColors.cream : context.inkSoft,
          ),
        ),
      ),
    );
  }
}
