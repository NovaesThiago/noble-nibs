import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Seletor de quantidade `−  n  +`, com limites de estoque.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  void _set(int next) {
    if (next < min || next > max) return;
    HapticFeedback.selectionClick();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.chipBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => _set(value - 1),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.button.copyWith(color: context.ink),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => _set(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? context.brandInk : context.inkSoft,
          ),
        ),
      ),
    );
  }
}
