import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';

/// Temas claro e escuro do app, derivados dos tokens em [AppColors],
/// [AppTypography] e [AppRadius]/[AppSpacing].
///
/// Material 3 (`useMaterial3: true`). O `ColorScheme` é semeado pelo acento
/// caramelo e depois sobrescrito nos slots-chave para casar com as referências.
abstract final class AppTheme {
  static ColorScheme get _lightScheme => ColorScheme.fromSeed(
        seedColor: AppColors.caramel,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.caramel,
        onPrimary: Colors.white,
        secondary: AppColors.coffeeDark,
        surface: AppColors.cream,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      );

  /// Tema claro (principal).
  static ThemeData get light => _buildTheme(_lightScheme, AppColors.cream);

  /// Tema escuro.
  ///
  /// A construção do esquema é injetada por [_darkScheme] (ver TODO abaixo)
  /// para que a decisão de design de cores no escuro fique isolada e fácil
  /// de iterar.
  static ThemeData get dark => _buildTheme(_darkScheme(), AppColors.espresso);

  /// Monta um [ThemeData] consistente a partir de um [ColorScheme] e a cor
  /// de fundo do scaffold. Compartilhado entre claro e escuro para garantir
  /// que botões, chips e inputs tenham o mesmo formato nos dois temas.
  static ThemeData _buildTheme(ColorScheme scheme, Color scaffoldBg) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      // Cor do texto aplicada por brilho → texto se adapta claro/escuro.
      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: AppTypography.headline.copyWith(color: scheme.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.caramel,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF3A2616) : AppColors.creamSoft,
        selectedColor: AppColors.caramel,
        labelStyle: AppTypography.label,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF4A3220) : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide.none,
        ),
      ),
      dividerColor: isDark ? Colors.white24 : AppColors.divider,
    );
  }

  /// ColorScheme escuro: superfícies em tons de espresso, texto creme
  /// (alto contraste) e caramelo como acento — preservando a identidade quente.
  static ColorScheme _darkScheme() => ColorScheme.fromSeed(
        seedColor: AppColors.caramel,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.caramel,
        onPrimary: AppColors.espresso,
        secondary: AppColors.caramel,
        surface: AppColors.espresso,
        onSurface: AppColors.cream,
        error: AppColors.error,
      );
}
