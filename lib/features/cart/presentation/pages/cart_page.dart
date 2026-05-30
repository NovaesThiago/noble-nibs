import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/coffee_image.dart';
import 'package:noble_nibs/core/widgets/quantity_stepper.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/shared/domain/entities/cart.dart';

/// Tela do carrinho: itens, edição de quantidade, remoção e resumo.
class CartPage extends ConsumerWidget {
  const CartPage({
    super.key,
    this.onBack,
    this.onContinueShopping,
    this.onCheckout,
  });

  final VoidCallback? onBack;
  final VoidCallback? onContinueShopping;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
        title: const Text('Seu carrinho'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: controller.clear,
              child: Text(
                'Limpar',
                style: AppTypography.label.copyWith(
                  color: AppColors.error,
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyView(
              message: 'Seu carrinho está vazio.\nQue tal explorar nossos grãos?',
              icon: Icons.shopping_bag_outlined,
              action: AppButton.primary(
                'Explorar o catálogo',
                onPressed: onContinueShopping,
                expanded: false,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) => _CartItemTile(
                      item: cart.items[i],
                      onQuantity: (q) => controller.setQuantity(cart.items[i].lineId, q),
                      onRemove: () => controller.remove(cart.items[i].lineId),
                    ),
                  ),
                ),
                _Summary(cart: cart, onCheckout: onCheckout),
              ],
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onQuantity,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.lineId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: CoffeeImage(path: item.product.imageUrl, decodeWidth: 120),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTypography.titleLarge.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.weight.label} · ${item.grind.label}',
                    style: AppTypography.label.copyWith(letterSpacing: 0),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.lineTotal.formatted,
                    style: AppTypography.button.copyWith(color: context.brandInk),
                  ),
                ],
              ),
            ),
            QuantityStepper(
              value: item.quantity,
              max: item.product.stock < 1 ? 1 : item.product.stock,
              onChanged: onQuantity,
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart, required this.onCheckout});

  final Cart cart;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.soft,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _row('Subtotal', cart.subtotal.formatted),
            const SizedBox(height: AppSpacing.xs),
            _row('Frete', 'calculado no checkout', muted: true),
            Divider(height: AppSpacing.lg, color: context.line),
            _row('Total', cart.total.formatted, emphasize: true),
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              'Finalizar compra',
              icon: Icons.lock_outline_rounded,
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false, bool muted = false}) {
    final style = emphasize ? AppTypography.titleLarge : AppTypography.body;
    final opacity = muted ? 0.6 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
