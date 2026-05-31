import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Botão da marca com três variantes e estado de carregamento.
///
/// Variantes:
///  • [AppButton.primary]   — preenchido caramelo (CTA principal).
///  • [AppButton.secondary] — contorno espresso (ação secundária).
///  • [AppButton.ghost]     — sem fundo (ação terciária/links).
class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    required _Variant variant,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  }) : _variant = variant;

  factory AppButton.primary(
    String label, {
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expanded = true,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expanded: expanded,
        variant: _Variant.primary,
      );

  factory AppButton.secondary(
    String label, {
    required VoidCallback? onPressed,
    IconData? icon,
    bool expanded = true,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        icon: icon,
        expanded: expanded,
        variant: _Variant.secondary,
      );

  factory AppButton.ghost(
    String label, {
    required VoidCallback? onPressed,
    IconData? icon,
  }) =>
      AppButton._(
        label: label,
        onPressed: onPressed,
        icon: icon,
        expanded: false,
        variant: _Variant.ghost,
      );

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final _Variant _variant;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final (bg, fg, border) = switch (_variant) {
      _Variant.primary => (AppColors.caramel, Colors.white, null),
      _Variant.secondary => (
          Colors.transparent,
          AppColors.coffeeDark,
          const BorderSide(color: AppColors.coffeeDark, width: 1.5),
        ),
      _Variant.ghost => (Colors.transparent, AppColors.caramelDeep, null),
    };

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Opacity(
        opacity: disabled && _variant == _Variant.primary ? 0.5 : 1,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: border ?? BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: Container(
              height: 56,
              width: expanded ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  // FittedBox(scaleDown) impede overflow: se o rótulo + ícone
                  // não couberem na largura do botão, reduz para caber.
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: fg),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            label,
                            maxLines: 1,
                            style: AppTypography.button.copyWith(color: fg),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Variant { primary, secondary, ghost }
