import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/utils/formatters.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/state_views.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/orders/presentation/providers/orders_controller.dart';
import 'package:noble_nibs/shared/domain/entities/order.dart';

/// Detalhe do pedido: timeline de status, itens e "comprar de novo".
class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.id, this.onBack, this.onReorder});

  final String id;
  final VoidCallback? onBack;
  final VoidCallback? onReorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(ordersControllerProvider.select((list) {
      for (final o in list) {
        if (o.id == id) return o;
      }
      return null;
    }));

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: Text('Pedido $id'),
      ),
      body: order == null
          ? const EmptyView(message: 'Pedido não encontrado.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (order.status != OrderStatus.cancelled) _Timeline(current: order.status),
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: 'Entrega',
                  child: Text(order.address.oneLine, style: AppTypography.body.copyWith(color: context.ink)),
                ),
                _Section(
                  title: 'Pagamento',
                  child: Text(order.paymentLabel, style: AppTypography.body.copyWith(color: context.ink)),
                ),
                _Section(
                  title: 'Itens',
                  child: Column(
                    children: [
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}× ${item.product.name} (${item.weight.label} · ${item.grind.label})',
                                  style: AppTypography.body.copyWith(color: context.ink),
                                ),
                              ),
                              Text(item.lineTotal.formatted, style: AppTypography.label.copyWith(letterSpacing: 0)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Resumo',
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', order.subtotal.formatted),
                      _summaryRow('Frete', order.shipping.formatted),
                      Divider(color: context.line),
                      _summaryRow('Total', order.total.formatted, bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton.secondary(
                  'Comprar de novo',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    final cart = ref.read(cartControllerProvider.notifier);
                    for (final item in order.items) {
                      cart.add(item.product, item.weight, item.grind, item.quantity);
                    }
                    onReorder?.call();
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  Formatters.date(order.createdAt),
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(letterSpacing: 0),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style =
        bold ? AppTypography.titleLarge.copyWith(fontSize: 18) : AppTypography.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Timeline horizontal de status (placed → preparing → shipped → delivered).
class _Timeline extends StatelessWidget {
  const _Timeline({required this.current});
  final OrderStatus current;

  static const _steps = [
    OrderStatus.placed,
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _Dot(done: _steps[i].step <= current.step, label: _steps[i].label),
          if (i < _steps.length - 1)
            Expanded(
              child: Container(
                height: 3,
                color: _steps[i + 1].step <= current.step
                    ? AppColors.caramel
                    : AppColors.divider,
              ),
            ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.done, required this.label});
  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.caramel : context.chipBg,
            shape: BoxShape.circle,
            border: Border.all(color: done ? AppColors.caramel : context.line),
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle,
            size: done ? 16 : 8,
            color: done ? Colors.white : context.line,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(fontSize: 9, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}
