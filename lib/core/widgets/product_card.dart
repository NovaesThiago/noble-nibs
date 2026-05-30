import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/coffee_image.dart';
import 'package:noble_nibs/core/widgets/rating_badge.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

/// Cartão de produto de destaque — o componente de assinatura do catálogo.
///
/// Decisões de composição (frontend-design):
///  • Cartão escuro espresso para fazer a imagem clara "saltar".
///  • Disco da imagem **flutua** acima da borda superior (grid-breaking),
///    criando profundidade e quebrando o retângulo previsível.
///  • Hierarquia editorial: overline de origem → nome em serifa → preço+ação.
///
/// Presentacional por design: recebe dados de exibição, não a entidade de
/// domínio, para permanecer reutilizável e testável isoladamente.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.originLabel,
    required this.roastLabel,
    required this.price,
    required this.rating,
    required this.heroTag,
    this.imageUrl,
    this.onTap,
    this.onAdd,
    this.onToggleFavorite,
    this.isFavorite = false,
    this.width = 210,
  });

  final String name;
  final String originLabel;
  final String roastLabel;
  final Money price;
  final double rating;
  final String heroTag;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;
  final double width;

  @override
  Widget build(BuildContext context) {
    const discSize = 116.0;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        // Espaço extra no topo para o disco flutuante transbordar.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // --- Corpo do cartão ---
            Container(
              margin: const EdgeInsets.only(top: discSize * 0.45),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                discSize * 0.5 + AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.coffeeMid,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$originLabel · $roastLabel'.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: AppColors.caramel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      name,
                      style: AppTypography.titleLarge.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price.formatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.button.copyWith(
                            color: AppColors.cream,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _AddButton(onTap: onAdd),
                    ],
                  ),
                ],
              ),
            ),
            // --- Disco da imagem flutuante (centralizado, robusto a width=∞) ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: _ImageDisc(size: discSize, imageUrl: imageUrl),
                ),
              ),
            ),
            // --- Badge de nota no canto ---
            Positioned(
              top: discSize * 0.45 + AppSpacing.sm,
              right: AppSpacing.md,
              child: RatingBadge(rating: rating, onDark: true),
            ),
            // --- Coração de favoritar ---
            if (onToggleFavorite != null)
              Positioned(
                top: discSize * 0.45 + AppSpacing.xs,
                left: AppSpacing.sm,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.error : AppColors.cream,
                    size: 22,
                  ),
                  onPressed: onToggleFavorite,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Disco com a imagem do produto. Sem asset, renderiza um motivo de café
/// estilizado (gradiente quente + glifo) que parece intencional, não um vazio.
class _ImageDisc extends StatelessWidget {
  const _ImageDisc({required this.size, this.imageUrl});

  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.caramel, AppColors.caramelDeep],
          center: Alignment(-0.3, -0.4),
        ),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: CoffeeImage(path: imageUrl, decodeWidth: 260),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Icon(Icons.add_rounded, color: AppColors.coffeeDark, size: 22),
        ),
      ),
    );
  }
}
