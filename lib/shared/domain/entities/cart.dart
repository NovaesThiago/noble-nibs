import 'package:noble_nibs/shared/domain/entities/money.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Um item do carrinho = produto + variante (peso) + moagem + quantidade.
class CartItem {
  const CartItem({
    required this.product,
    required this.weight,
    required this.grind,
    required this.quantity,
  });

  final Product product;
  final WeightOption weight;
  final GrindOption grind;
  final int quantity;

  /// Identidade da linha: mesma combinação produto+peso+moagem é a mesma linha.
  String get lineId => '${product.id}|${weight.grams}|${grind.type.name}';

  /// Total da linha = preço da variante × quantidade.
  Money get lineTotal => weight.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        weight: weight,
        grind: grind,
        quantity: quantity ?? this.quantity,
      );
}

/// Estado imutável do carrinho.
class Cart {
  const Cart(this.items);

  factory Cart.empty() => const Cart([]);

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  /// Soma das quantidades (badge do bottom nav).
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// Subtotal dos produtos (sem frete). `fold` a partir de zero evita o
  /// `reduce` em lista vazia.
  Money get subtotal =>
      items.fold(const Money(0), (sum, i) => sum + i.lineTotal);

  /// Frete é calculado no checkout (Fase 4). Aqui o total reflete só o subtotal.
  Money get total => subtotal;
}
