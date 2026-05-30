import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Conjunto de ids de produtos favoritados (keepAlive, em memória).
class FavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  /// Adiciona se ausente, remove se presente — em uma expressão.
  void toggle(String productId) {
    final next = {...state};
    if (!next.add(productId)) next.remove(productId);
    state = next;
  }

  bool contains(String productId) => state.contains(productId);
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

/// Produtos favoritados, derivados do catálogo já carregado.
final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final ids = ref.watch(favoritesControllerProvider);
  return ref
      .watch(productsProvider)
      .whenData((list) => list.where((p) => ids.contains(p.id)).toList());
});
