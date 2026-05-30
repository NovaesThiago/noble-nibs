import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/checkout/domain/payment_gateway.dart';
import 'package:noble_nibs/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:noble_nibs/features/orders/presentation/providers/orders_controller.dart';
import 'package:noble_nibs/shared/domain/entities/order.dart';

enum CheckoutStatus { idle, processing }

/// Orquestra a finalização: valida → paga (gateway) → cria [Order] →
/// adiciona ao histórico → limpa o carrinho.
class CheckoutController extends Notifier<CheckoutStatus> {
  @override
  CheckoutStatus build() => CheckoutStatus.idle;

  Future<Either<Failure, Order>> placeOrder() async {
    final cart = ref.read(cartControllerProvider);
    final address = ref.read(selectedAddressProvider);
    final method = ref.read(paymentMethodProvider);
    final shipping = ref.read(shippingProvider);
    final subtotal = cart.subtotal;
    final total = ref.read(checkoutTotalProvider);

    if (cart.isEmpty) return const Left(ValidationFailure('Seu carrinho está vazio.'));
    if (address == null) return const Left(ValidationFailure('Selecione um endereço de entrega.'));

    state = CheckoutStatus.processing;
    final payment = await ref
        .read(paymentGatewayProvider)
        .pay(PaymentRequest(amount: total, method: method));

    return payment.fold<Either<Failure, Order>>(
      (failure) {
        state = CheckoutStatus.idle;
        return Left(failure);
      },
      (result) {
        final order = Order(
          id: 'NB-${DateTime.now().millisecondsSinceEpoch % 1000000}',
          items: cart.items,
          status: OrderStatus.placed,
          createdAt: DateTime.now(),
          address: address,
          paymentLabel: '${method.label} · ${result.transactionId}',
          subtotal: subtotal,
          shipping: shipping,
          total: total,
        );
        ref.read(ordersControllerProvider.notifier).add(order);
        ref.read(cartControllerProvider.notifier).clear();
        state = CheckoutStatus.idle;
        return Right(order);
      },
    );
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutStatus>(CheckoutController.new);
