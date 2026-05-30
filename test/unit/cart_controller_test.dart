import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noble_nibs/features/cart/presentation/providers/cart_controller.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

Product _product({String id = 'p1', int stock = 10}) => Product(
      id: id,
      name: 'Café Teste',
      description: 'desc',
      origin: const Origin(country: 'Brasil', region: 'Minas'),
      roast: RoastLevel.medium,
      grinds: const [GrindOption(GrindType.whole)],
      weights: const [WeightOption(grams: 250, price: Money(3500))],
      notes: const TastingNotes(acidity: 3, body: 3, sweetness: 3, descriptors: ['x']),
      rating: 4.5,
      reviewCount: 10,
      imageUrl: '',
      isFeatured: true,
      stock: stock,
    );

void main() {
  group('CartController', () {
    test('adiciona e mescla a mesma variante, somando quantidade', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ctrl = container.read(cartControllerProvider.notifier);
      final p = _product();

      ctrl
        ..add(p, p.weights.first, p.grinds.first, 2)
        ..add(p, p.weights.first, p.grinds.first, 3);

      final cart = container.read(cartControllerProvider);
      expect(cart.items.length, 1, reason: 'mesma variante = 1 linha');
      expect(cart.itemCount, 5);
      expect(cart.subtotal.cents, 3500 * 5);
    });

    test('_guardStock limita a quantidade ao estoque', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final p = _product(stock: 3);

      container.read(cartControllerProvider.notifier).add(p, p.weights.first, p.grinds.first, 10);

      expect(container.read(cartControllerProvider).items.first.quantity, 3);
    });

    test('remove e limpa', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ctrl = container.read(cartControllerProvider.notifier);
      final p = _product();
      ctrl.add(p, p.weights.first, p.grinds.first, 1);
      final lineId = container.read(cartControllerProvider).items.first.lineId;

      ctrl.remove(lineId);
      expect(container.read(cartControllerProvider).isEmpty, isTrue);
    });
  });
}
