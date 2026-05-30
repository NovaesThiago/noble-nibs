import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';
import 'package:noble_nibs/core/widgets/coffee_image.dart';
import 'package:noble_nibs/core/widgets/pill_selector.dart';
import 'package:noble_nibs/core/widgets/quantity_stepper.dart';
import 'package:noble_nibs/core/widgets/rating_badge.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:noble_nibs/features/favorites/presentation/providers/favorites_controller.dart';
import 'package:noble_nibs/features/product_detail/presentation/providers/product_detail_providers.dart';
import 'package:noble_nibs/features/product_detail/presentation/widgets/tasting_notes_view.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Detalhe do produto: galeria, seleção de peso/moagem, notas de degustação,
/// quantidade e "adicionar ao carrinho" com preço dinâmico.
class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.id,
    this.onOpenCart,
    this.onBack,
  });

  final String id;
  final VoidCallback? onOpenCart;
  final VoidCallback? onBack;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _weightIndex = 0;
  int _grindIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productByIdProvider(widget.id));
    final favorites = ref.watch(favoritesControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: BeanPatternBackground(opacity: 0.07, density: 20),
          ),
          SafeArea(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.caramel)),
              error: (e, _) => ErrorView(
                message: e is Failure ? e.message : 'Erro ao carregar o produto.',
                onRetry: () => ref.invalidate(productByIdProvider(widget.id)),
              ),
              data: (product) => product == null
                  ? const EmptyView(message: 'Produto não encontrado.')
                  : _Content(
                      product: product,
                      weightIndex: _weightIndex.clamp(0, product.weights.length - 1),
                      grindIndex: _grindIndex.clamp(0, product.grinds.length - 1),
                      quantity: _quantity,
                      favorite: favorites.contains(product.id),
                      onBack: widget.onBack ?? () => Navigator.maybePop(context),
                      onOpenCart: widget.onOpenCart,
                      onToggleFavorite: () =>
                          ref.read(favoritesControllerProvider.notifier).toggle(product.id),
                      onWeight: (i) => setState(() => _weightIndex = i),
                      onGrind: (i) => setState(() => _grindIndex = i),
                      onQuantity: (q) => setState(() => _quantity = q),
                      onAdd: () => _add(product),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _add(Product product) {
    final weight = product.weights[_weightIndex.clamp(0, product.weights.length - 1)];
    final grind = product.grinds[_grindIndex.clamp(0, product.grinds.length - 1)];
    ref.read(cartControllerProvider.notifier).add(product, weight, grind, _quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} adicionado ao carrinho'),
          action: widget.onOpenCart == null
              ? null
              : SnackBarAction(label: 'Ver', onPressed: widget.onOpenCart!),
        ),
      );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.product,
    required this.weightIndex,
    required this.grindIndex,
    required this.quantity,
    required this.favorite,
    required this.onBack,
    required this.onOpenCart,
    required this.onToggleFavorite,
    required this.onWeight,
    required this.onGrind,
    required this.onQuantity,
    required this.onAdd,
  });

  final Product product;
  final int weightIndex;
  final int grindIndex;
  final int quantity;
  final bool favorite;
  final VoidCallback onBack;
  final VoidCallback? onOpenCart;
  final VoidCallback onToggleFavorite;
  final ValueChanged<int> onWeight;
  final ValueChanged<int> onGrind;
  final ValueChanged<int> onQuantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final weight = product.weights[weightIndex];
    final total = weight.price * quantity;

    return Column(
      children: [
        // --- Barra superior ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.ink),
                onPressed: onBack,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: favorite ? AppColors.error : context.ink,
                ),
                onPressed: onToggleFavorite,
              ),
              CartIconButton(onTap: onOpenCart ?? () {}),
            ],
          ),
        ),
        // --- Conteúdo rolável ---
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CoffeeImage(path: product.imageUrl, decodeWidth: 420),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${product.origin.region} · ${product.roast.label}'.toUpperCase(),
                        style: AppTypography.overline,
                      ),
                    ),
                    RatingBadge(rating: product.rating),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(product.name, style: AppTypography.display.copyWith(fontSize: 32)),
                const SizedBox(height: AppSpacing.xs),
                Text('${product.reviewCount} avaliações', style: AppTypography.label),
                const SizedBox(height: AppSpacing.lg),

                _SectionLabel('Peso'),
                PillSelector(
                  labels: [
                    for (final w in product.weights) '${w.label} · ${w.price.formatted}',
                  ],
                  selectedIndex: weightIndex,
                  onSelect: onWeight,
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionLabel('Moagem'),
                PillSelector(
                  labels: [for (final g in product.grinds) g.label],
                  selectedIndex: grindIndex,
                  onSelect: onGrind,
                ),
                const SizedBox(height: AppSpacing.lg),

                _SectionLabel('Perfil sensorial'),
                TastingNotesView(notes: product.notes),
                const SizedBox(height: AppSpacing.lg),

                _SectionLabel('Descrição'),
                Text(product.description, style: AppTypography.body.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ),
        // --- Barra inferior (preço dinâmico + adicionar) ---
        _BottomBar(
          total: total.formatted,
          quantity: quantity,
          maxQuantity: product.stock,
          inStock: product.inStock,
          onQuantity: onQuantity,
          onAdd: onAdd,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(text, style: AppTypography.titleLarge),
      );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.total,
    required this.quantity,
    required this.maxQuantity,
    required this.inStock,
    required this.onQuantity,
    required this.onAdd,
  });

  final String total;
  final int quantity;
  final int maxQuantity;
  final bool inStock;
  final ValueChanged<int> onQuantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.card,
        boxShadow: AppShadows.soft,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QuantityStepper(
              value: quantity,
              max: maxQuantity < 1 ? 1 : maxQuantity,
              onChanged: onQuantity,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton.primary(
                inStock ? 'Adicionar · $total' : 'Esgotado',
                icon: inStock ? Icons.add_shopping_cart_rounded : null,
                onPressed: inStock ? onAdd : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
