import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';

/// Tipografia da marca — direção "Specialty Coffee, editorial & tátil".
///
/// Pareamento intencional e distintivo (anti-genérico):
///  • **Fraunces** (display): serifa moderna "soft", calorosa, com eixo ótico.
///  • **Hanken Grotesk** (corpo): grotesca humanista limpa e amigável.
///
/// IMPORTANTE: estes estilos **não fixam cor** — a cor vem do tema
/// (`onSurface`), o que faz o texto se adaptar automaticamente ao modo
/// claro/escuro. Cores específicas (acentos) são aplicadas via `.copyWith`
/// nos widgets. A exceção é o `overline`, que é um acento de marca.
abstract final class AppTypography {
  // --- Display (Fraunces) --------------------------------------------------
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -1,
      );

  static TextStyle get headline => GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.fraunces(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.15,
      );

  // --- Corpo / UI (Hanken Grotesk) ----------------------------------------
  static TextStyle get body => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get button => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get label => GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  /// Eyebrow/overline editorial — acento de marca (mantém cor caramelo, que
  /// lê bem tanto no claro quanto no escuro).
  static TextStyle get overline => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: AppColors.caramelDeep,
      );

  /// [TextTheme] para injeção no [ThemeData] (cor aplicada por brilho lá).
  static TextTheme get textTheme => TextTheme(
        displayLarge: display,
        headlineMedium: headline,
        titleLarge: titleLarge,
        bodyMedium: body,
        labelLarge: button,
        labelSmall: label,
      );
}
