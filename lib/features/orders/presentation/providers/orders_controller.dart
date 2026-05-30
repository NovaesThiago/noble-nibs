import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/shared/domain/entities/order.dart';

/// Histórico de pedidos (keepAlive, em memória).
///
/// Os pedidos criados no checkout são adicionados aqui. Persistência local
/// (Hive) é um passo seguinte — a interface não muda.
class OrdersController extends Notifier<List<Order>> {
  @override
  List<Order> build() => const [];

  /// Adiciona um pedido recém-criado no topo da lista.
  void add(Order order) => state = [order, ...state];

  Order? byId(String id) {
    for (final o in state) {
      if (o.id == id) return o;
    }
    return null;
  }
}

final ordersControllerProvider =
    NotifierProvider<OrdersController, List<Order>>(OrdersController.new);
