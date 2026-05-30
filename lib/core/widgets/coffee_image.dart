import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';

/// Imagem de produto resiliente: carrega de **asset** (`assets/...`), de **URL**
/// (`http...`) ou cai num **placeholder pintado** se não houver caminho.
///
/// `decodeWidth` reduz a resolução de decodificação (memória) — importante
/// porque as fotos originais são muito grandes.
class CoffeeImage extends StatelessWidget {
  const CoffeeImage({super.key, this.path, this.decodeWidth = 320});

  final String? path;
  final int decodeWidth;

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) return const _Painted();

    if (p.startsWith('assets/')) {
      return Image.asset(
        p,
        fit: BoxFit.cover,
        cacheWidth: decodeWidth,
        errorBuilder: (_, __, ___) => const _Painted(),
      );
    }
    if (p.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: p,
        fit: BoxFit.cover,
        memCacheWidth: decodeWidth,
        placeholder: (_, __) => const _Painted(),
        errorWidget: (_, __, ___) => const _Painted(),
      );
    }
    return const _Painted();
  }
}

/// Fallback: gradiente quente + glifo (parece intencional, não um vazio).
class _Painted extends StatelessWidget {
  const _Painted();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [AppColors.caramel, AppColors.caramelDeep],
          center: Alignment(-0.3, -0.4),
        ),
      ),
      child: Center(child: Icon(Icons.coffee_rounded, size: 44, color: Colors.white)),
    );
  }
}
