import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';

/// Fundo de assinatura da marca: grãos de café desenhados à mão (contorno),
/// espalhados em baixa opacidade — reproduz a textura das referências sem
/// usar imagens, então fica nítido em qualquer densidade de tela.
///
/// Use como camada de fundo:
/// ```dart
/// Stack(children: [
///   const Positioned.fill(child: BeanPatternBackground()),
///   conteudo,
/// ]);
/// ```
class BeanPatternBackground extends StatelessWidget {
  const BeanPatternBackground({
    super.key,
    this.color,
    this.opacity = 0.06,
    this.density = 26,
    this.seed = 7,
  });

  /// Cor do traço dos grãos (default: tinta espresso da marca).
  final Color? color;

  /// Opacidade do padrão (sutil por design).
  final double opacity;

  /// Quantidade de grãos.
  final int density;

  /// Semente para distribuição determinística (sem `Random` não-semeado).
  final int seed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BeanPainter(
        color: (color ?? AppColors.coffeeDark).withValues(alpha: opacity),
        count: density,
        seed: seed,
      ),
      size: Size.infinite,
    );
  }
}

class _BeanPainter extends CustomPainter {
  _BeanPainter({required this.color, required this.count, required this.seed});

  final Color color;
  final int count;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < count; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final scale = 0.7 + rng.nextDouble() * 1.1;
      final angle = rng.nextDouble() * math.pi;

      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(angle)
        ..scale(scale);
      _drawBean(canvas, stroke);
      canvas.restore();
    }
  }

  /// Desenha um grão: oval + costura central em "S".
  void _drawBean(Canvas canvas, Paint stroke) {
    const w = 22.0;
    const h = 14.0;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      stroke,
    );
    final seam = Path()
      ..moveTo(-w / 2 + 2, -2)
      ..cubicTo(-w / 4, 4, w / 4, -4, w / 2 - 2, 2);
    canvas.drawPath(seam, stroke);
  }

  @override
  bool shouldRepaint(_BeanPainter old) =>
      old.color != color || old.count != count || old.seed != seed;
}
