import 'package:noble_nibs/shared/domain/entities/address.dart';
import 'package:noble_nibs/shared/domain/entities/cart.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';

/// Status do pedido. `step` ordena a timeline (cancelado = -1, fora da linha).
enum OrderStatus {
  placed('Pedido realizado', 0),
  preparing('Em preparo', 1),
  shipped('Enviado', 2),
  delivered('Entregue', 3),
  cancelled('Cancelado', -1);

  const OrderStatus(this.label, this.step);
  final String label;
  final int step;
}

/// Pedido = snapshot imutável do carrinho no momento da compra.
class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.paymentLabel,
    required this.subtotal,
    required this.shipping,
    required this.total,
    this.trackingCode,
  });

  final String id;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final Address address;
  final String paymentLabel;
  final Money subtotal;
  final Money shipping;
  final Money total;
  final String? trackingCode;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  bool operator ==(Object o) => o is Order && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
