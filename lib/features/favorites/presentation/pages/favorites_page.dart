import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/catalog/presentation/widgets/product_grid.dart';
import 'package:noble_nibs/features/favorites/presentation/providers/favorites_controller.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Aba de favoritos: grade dos grãos salvos.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key, this.onTapProduct, this.onAddProduct, this.onShop});

  final void Function(Product)? onTapProduct;
  final void Function(Product)? onAddProduct;
  final VoidCallback? onShop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SEUS SALVOS', style: AppTypography.overline),
                  const SizedBox(height: 2),
                  Text('Favoritos', style: AppTypography.headline),
                ],
              ),
            ),
            Expanded(
              child: favoritesAsync.when(
                loading: () => const ProductGridLoading(),
                error: (_, __) => const ErrorView(message: 'Erro ao carregar favoritos.'),
                data: (products) => products.isEmpty
                    ? EmptyView(
                        message: 'Você ainda não favoritou nenhum grão.\nToque no ♥ para salvar.',
                        icon: Icons.favorite_border_rounded,
                        action: AppButton.primary(
                          'Explorar o catálogo',
                          onPressed: onShop,
                          expanded: false,
                        ),
                      )
                    : ProductGrid(
                        products: products,
                        onTapProduct: onTapProduct,
                        onAddProduct: onAddProduct,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
