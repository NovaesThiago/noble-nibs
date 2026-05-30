import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/checkout/domain/payment_gateway.dart';
import 'package:noble_nibs/features/checkout/presentation/providers/checkout_controller.dart';
import 'package:noble_nibs/features/checkout/presentation/providers/checkout_providers.dart';

/// Tela de checkout: endereço → entrega → pagamento → resumo → pagar.
class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key, this.onBack, this.onSuccess});

  final VoidCallback? onBack;
  final void Function(String orderId)? onSuccess;

  IconData _methodIcon(PaymentMethod m) =>
      m == PaymentMethod.pix ? Icons.pix_rounded : Icons.credit_card_rounded;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(checkoutControllerProvider.notifier).placeOrder();
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (order) => onSuccess?.call(order.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(selectedAddressProvider);
    final delivery = ref.watch(deliveryOptionProvider);
    final method = ref.watch(paymentMethodProvider);
    final subtotal = ref.watch(cartControllerProvider).subtotal;
    final shipping = ref.watch(shippingProvider);
    final total = ref.watch(checkoutTotalProvider);
    final processing = ref.watch(checkoutControllerProvider) == CheckoutStatus.processing;

    return Scaffold(
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: onBack),
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- Endereço ---
          _SectionTitle('Endereço de entrega'),
          if (address == null)
            Text('Nenhum endereço cadastrado.', style: AppTypography.body)
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: _cardDecoration(context),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.caramelDeep),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.label, style: AppTypography.button.copyWith(color: context.ink)),
                        const SizedBox(height: 2),
                        Text(address.oneLine, style: AppTypography.label.copyWith(letterSpacing: 0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          // --- Entrega ---
          _SectionTitle('Entrega'),
          for (final option in DeliveryOption.values)
            _SelectableTile(
              selected: option == delivery,
              title: option.label,
              subtitle: option.eta,
              trailing: option.baseFeeCents == 0 ? 'Grátis' : null,
              icon: Icons.local_shipping_outlined,
              onTap: () => ref.read(deliveryOptionProvider.notifier).state = option,
            ),
          const SizedBox(height: AppSpacing.lg),

          // --- Pagamento ---
          _SectionTitle('Pagamento'),
          for (final m in PaymentMethod.values)
            _SelectableTile(
              selected: m == method,
              title: m.label,
              icon: _methodIcon(m),
              onTap: () => ref.read(paymentMethodProvider.notifier).state = m,
            ),
          const SizedBox(height: AppSpacing.lg),

          // --- Resumo ---
          _SectionTitle('Resumo'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _cardDecoration(context),
            child: Column(
              children: [
                _row('Subtotal', subtotal.formatted),
                const SizedBox(height: AppSpacing.xs),
                _row('Frete', shipping.cents == 0 ? 'Grátis' : shipping.formatted),
                Divider(color: context.line, height: AppSpacing.lg),
                _row('Total', total.formatted, emphasize: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.card,
          boxShadow: AppShadows.soft,
        ),
        child: SafeArea(
          top: false,
          child: AppButton.primary(
            'Pagar · ${total.formatted}',
            icon: Icons.lock_outline_rounded,
            isLoading: processing,
            onPressed: () => _pay(context, ref),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      );

  Widget _row(String label, String value, {bool emphasize = false}) {
    final style =
        emphasize ? AppTypography.titleLarge.copyWith(fontSize: 18) : AppTypography.body;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text.toUpperCase(), style: AppTypography.overline),
      );
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.caramel : context.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.caramelDeep : context.inkSoft),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.button.copyWith(
                    fontSize: 15,
                    color: context.ink,
                  )),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.label.copyWith(letterSpacing: 0)),
                ],
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: AppTypography.button.copyWith(color: AppColors.success, fontSize: 14)),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.caramel : context.line,
            ),
          ],
        ),
      ),
    );
  }
}
