import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Campo de texto da marca. Pílula arredondada (refs), com prefixo/sufixo,
/// validação e suporte a senha.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.textInputAction,
    this.dense = false,
  });

  /// Variante de busca: pílula clara com lupa, sem label.
  factory AppTextField.search({
    required ValueChanged<String> onChanged,
    String hint = 'Buscar...',
    TextEditingController? controller,
    bool dense = false,
  }) =>
      AppTextField(
        controller: controller,
        hint: hint,
        prefixIcon: Icons.search_rounded,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        dense: dense,
      );

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  /// Versão compacta (menor altura) — usada no header minimizado.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: AppTypography.body.copyWith(color: context.ink),
          decoration: InputDecoration(
            isDense: dense,
            contentPadding: dense
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  )
                : null,
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: context.inkSoft),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: context.inkSoft, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
