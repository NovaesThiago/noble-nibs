import 'package:flutter/material.dart';

/// Paleta da marca, extraída diretamente das referências de design
/// (`COFFE.webp` / `COFFE2.webp`): tons quentes de café, creme e caramelo.
///
/// Mantemos as cores como tokens imutáveis em uma classe `abstract final`
/// para que sejam `const` e nunca instanciadas acidentalmente.
abstract final class AppColors {
  // -- Base / fundos --------------------------------------------------------
  /// Fundo claro principal (linho/creme). Ref: `#FAF0E6`.
  static const cream = Color(0xFFFAF0E6);

  /// Variação de superfície levemente mais quente para cartões/sheets.
  static const creamSoft = Color(0xFFF5EBDD);

  /// Superfície neutra (campos, cards claros).
  static const surface = Color(0xFFFFFFFF);

  // -- Marrons (marca) ------------------------------------------------------
  /// Títulos e identidade da marca. Ref: `#73481E`.
  static const coffeeDark = Color(0xFF73481E);

  /// Cartão de produto escuro (fundo do `ProductCard` de destaque).
  static const coffeeMid = Color(0xFF5A3A1A);

  /// Fundo escuro / espresso para o tema escuro e contrastes.
  static const espresso = Color(0xFF3E2A14);

  // -- Acento (caramelo / tan) ---------------------------------------------
  /// Acento principal: botões, chips ativos, CTAs. Ref: `#D19F6C`.
  static const caramel = Color(0xFFD19F6C);

  /// Variação mais escura do acento (pressionado/hover).
  static const caramelDeep = Color(0xFFC08A52);

  // -- Texto ----------------------------------------------------------------
  static const textPrimary = Color(0xFF2A1C10);
  static const textSecondary = Color(0xFF8A7763);

  // -- Neutros / feedback ---------------------------------------------------
  static const divider = Color(0xFFE7DCCB);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFE0A800);
  static const error = Color(0xFFD9534F);

  /// Estrelas de avaliação (badges de nota).
  static const star = Color(0xFFE0A800);
}

/// Cores **theme-aware**: resolvem para a variante certa conforme o
/// modo claro/escuro. Use em contêineres/ícones/texto que precisam adaptar.
///
/// Ex.: `color: context.card`, `color: context.ink`.
extension ThemeColorsX on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  /// Texto/ícone primário.
  Color get ink => _isDark ? AppColors.cream : AppColors.textPrimary;

  /// Texto/ícone secundário (menor ênfase).
  Color get inkSoft => _isDark ? const Color(0xFFC9B79F) : AppColors.textSecondary;

  /// Marca em destaque (títulos/ícones): caramelo no escuro, marrom no claro.
  Color get brandInk => _isDark ? AppColors.caramel : AppColors.coffeeDark;

  /// Fundo de cartão (sobre o scaffold).
  Color get card => _isDark ? const Color(0xFF4A3220) : AppColors.surface;

  /// Fundo de chip/pílula/stepper.
  Color get chipBg => _isDark ? const Color(0xFF3A2616) : AppColors.creamSoft;

  /// Linha/divisória.
  Color get line => _isDark ? Colors.white24 : AppColors.divider;
}
