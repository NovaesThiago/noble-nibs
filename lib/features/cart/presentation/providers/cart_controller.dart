import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/shared/domain/entities/cart.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Controlador global do carrinho (keepAlive — sobrevive à navegação).
///
/// Persistência local (Hive/prefs) fica para um passo seguinte; por ora o
/// estado vive em memória. A interface pública não muda quando adicionarmos
/// persistência — só o `build()` passará a carregar do storage.
class CartController extends Notifier<Cart> {
  @override
  Cart build() => Cart.empty();

  /// Adiciona uma variante. Se a mesma linha (produto+peso+moagem) já existe,
  /// incrementa a quantidade; caso contrário, cria uma nova linha.
  void add(Product product, WeightOption weight, GrindOption grind, int qty) {
    final items = [...state.items];
    final candidate = CartItem(
      product: product,
      weight: weight,
      grind: grind,
      quantity: qty,
    );
    final index = items.indexWhere((i) => i.lineId == candidate.lineId);

    if (index >= 0) {
      final merged = items[index].quantity + qty;
      items[index] = items[index].copyWith(quantity: _guardStock(product, merged));
    } else {
      items.add(candidate.copyWith(quantity: _guardStock(product, qty)));
    }
    state = Cart(items);
  }

  void setQuantity(String lineId, int qty) {
    if (qty <= 0) {
      remove(lineId);
      return;
    }
    state = Cart([
      for (final i in state.items)
        if (i.lineId == lineId) i.copyWith(quantity: _guardStock(i.product, qty)) else i,
    ]);
  }

  void remove(String lineId) =>
      state = Cart(state.items.where((i) => i.lineId != lineId).toList());

  void clear() => state = Cart.empty();

  // ===========================================================================
  // 🔧 PONTO DE CONTRIBUIÇÃO (modo learning)
  // ===========================================================================
  // Quando o usuário tenta adicionar mais do que há em estoque, o que deve
  // acontecer? Opções (trade-off UX × confiabilidade do pedido):
  //  (a) Travar no estoque máximo silenciosamente (baseline abaixo).
  //  (b) Travar e sinalizar ("máximo disponível: N") — melhor feedback.
  //  (c) Permitir e validar só no checkout (pior para o usuário).
  //
  // TODO(voce): defina a política. Baseline: clamp em [1, stock].
  int _guardStock(Product product, int desired) {
    final max = product.stock;
    if (desired < 1) return 1;
    if (desired > max) return max;
    return desired;
  }
}

final cartControllerProvider =
    NotifierProvider<CartController, Cart>(CartController.new);

/// Contagem total de itens — para o badge do carrinho. `select` garante que
/// só reconstrói quando a contagem muda, não a cada alteração do carrinho.
final cartCountProvider =
    Provider<int>((ref) => ref.watch(cartControllerProvider.select((c) => c.itemCount)));
