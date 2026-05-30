import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/widgets/product_card.dart';
import 'package:noble_nibs/features/favorites/presentation/providers/favorites_controller.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Grade de produtos com entrada escalonada (stagger) por item e favoritar.
class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.products,
    this.onTapProduct,
    this.onAddProduct,
    this.controller,
  });

  final List<Product> products;
  final void Function(Product)? onTapProduct;
  final void Function(Product)? onAddProduct;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesControllerProvider);

    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl, // espaço para os discos flutuantes da 1ª linha
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.xxl,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.62,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return ProductCard(
          name: p.name,
          originLabel: p.origin.region,
          roastLabel: p.roast.label,
          price: p.fromPrice,
          rating: p.rating,
          heroTag: 'product-${p.id}',
          imageUrl: p.imageUrl.isEmpty ? null : p.imageUrl,
          width: double.infinity,
          isFavorite: favorites.contains(p.id),
          onToggleFavorite: () =>
              ref.read(favoritesControllerProvider.notifier).toggle(p.id),
          onTap: () => onTapProduct?.call(p),
          onAdd: () => onAddProduct?.call(p),
        )
            .animate()
            .fadeIn(delay: (40 * i).ms, duration: 360.ms)
            .slideY(begin: 0.12, curve: Curves.easeOut);
      },
    );
  }
}
