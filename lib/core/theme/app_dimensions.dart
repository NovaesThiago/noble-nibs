/// Tokens de espaçamento, raio e sombra.
///
/// Centralizar estes valores garante consistência visual e permite ajustar
/// a "densidade" do app em um único lugar.
library;

import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';

/// Escala de espaçamento (múltiplos de 4 — base de grid do Material).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Raios de borda. Cartões grandes e chips em "pílula" como nas referências.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;

  /// Totalmente arredondado (chips e botões pill).
  static const double pill = 100;
}

/// Sombras suaves e quentes (tonalidade marrom, não preta) — coerente com a
/// estética das referências.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A73481E), // coffeeDark @ 10%
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Referenciamos AppColors para deixar explícita a relação de cor da sombra.
  static const Color _shadowSource = AppColors.coffeeDark;

  /// Cor-fonte das sombras (exposta para usos pontuais).
  static Color get shadowColor => _shadowSource.withValues(alpha: 0.10);
}
