import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/features/checkout/domain/payment_gateway.dart';
import 'package:noble_nibs/shared/domain/entities/address.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

/// Opção de entrega (prazo + tarifa base).
enum DeliveryOption {
  standard('Entrega padrão', '5–7 dias úteis', 1500),
  express('Entrega expressa', '2–3 dias úteis', 2500);

  const DeliveryOption(this.label, this.eta, this.baseFeeCents);
  final String label;
  final String eta;
  final int baseFeeCents;
}

/// Gateway de pagamento injetado (mock agora; trocar aqui no futuro).
final paymentGatewayProvider = Provider<PaymentGateway>(
  (ref) => const MockPaymentGateway(),
);

/// Endereços do usuário (keepAlive, mock com 1 endereço padrão).
class AddressesController extends Notifier<List<Address>> {
  @override
  List<Address> build() => const [
        Address(
          id: 'addr-1',
          label: 'Casa',
          street: 'Rua das Laranjeiras',
          number: '120',
          complement: 'Apto 51',
          district: 'Centro',
          city: 'São Paulo',
          state: 'SP',
          cep: '01310-100',
          isDefault: true,
        ),
      ];

  void add(Address address) => state = [...state, address];
}

final addressesControllerProvider =
    NotifierProvider<AddressesController, List<Address>>(AddressesController.new);

final selectedAddressProvider = StateProvider<Address?>((ref) {
  final list = ref.watch(addressesControllerProvider);
  return list.isEmpty ? null : list.firstWhere((a) => a.isDefault, orElse: () => list.first);
});

final deliveryOptionProvider =
    StateProvider<DeliveryOption>((ref) => DeliveryOption.standard);

final paymentMethodProvider = StateProvider<PaymentMethod>((ref) => PaymentMethod.pix);

// =============================================================================
// 🔧 PONTO DE CONTRIBUIÇÃO (modo learning) — POLÍTICA DE FRETE
// =============================================================================
// Como o frete deve ser calculado? Decisão de negócio com várias abordagens:
//  • Grátis acima de um limite (qual? só na entrega padrão?).
//  • Tarifa fixa por opção de entrega (baseline abaixo).
//  • Por CEP/região (exige tabela — futuro).
//
// O baseline: usa a tarifa base da opção, com frete GRÁTIS na padrão acima de
// R$ 150. TODO(voce): ajuste a regra conforme o negócio (≈5–10 linhas).
final shippingProvider = Provider<Money>((ref) {
  final subtotal = ref.watch(cartControllerProvider).subtotal;
  final delivery = ref.watch(deliveryOptionProvider);

  const freeThreshold = 15000; // R$ 150,00 em centavos
  if (delivery == DeliveryOption.standard && subtotal.cents >= freeThreshold) {
    return const Money(0);
  }
  return Money(delivery.baseFeeCents);
});

/// Total final = subtotal + frete.
final checkoutTotalProvider = Provider<Money>((ref) {
  final subtotal = ref.watch(cartControllerProvider).subtotal;
  final shipping = ref.watch(shippingProvider);
  return subtotal + shipping;
});
