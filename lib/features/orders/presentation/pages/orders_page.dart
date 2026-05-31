import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/utils/formatters.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/orders/presentation/providers/orders_controller.dart';
import 'package:noble_nibs/shared/domain/entities/order.dart';

/// Cor do status para o chip da lista de pedidos.
Color statusColor(OrderStatus s) => switch (s) {
      OrderStatus.placed => AppColors.warning,
      OrderStatus.preparing => AppColors.caramelDeep,
      OrderStatus.shipped => AppColors.coffeeDark,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
    };

/// Lista de pedidos do usuário.
class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key, this.onBack, this.onOpenOrder, this.onShop});

  final VoidCallback? onBack;
  final void Function(String orderId)? onOpenOrder;
  final VoidCallback? onShop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: const Text('Meus pedidos'),
      ),
      body: orders.isEmpty
          ? EmptyView(
              message: 'Você ainda não fez pedidos.',
              icon: Icons.receipt_long_outlined,
              action: AppButton.primary('Explorar o catálogo', onPressed: onShop, expanded: false),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onTap: () => onOpenOrder?.call(orders[i].id),
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pacote da marca como miniatura do pedido.
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.chipBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('assets/images/pacote-noble-nibs.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Pedido ${order.id}',
                            style: AppTypography.button.copyWith(color: context.ink)),
                      ),
                      _StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${Formatters.date(order.createdAt)} · ${order.itemCount} ${order.itemCount == 1 ? 'item' : 'itens'}',
                    style: AppTypography.label.copyWith(letterSpacing: 0),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.total.formatted,
                          style: AppTypography.titleLarge.copyWith(fontSize: 18)),
                      Icon(Icons.chevron_right_rounded, color: context.inkSoft),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        style: AppTypography.label.copyWith(color: color, letterSpacing: 0),
      ),
    );
  }
}
