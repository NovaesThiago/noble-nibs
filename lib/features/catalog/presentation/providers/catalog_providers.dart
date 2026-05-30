import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/features/catalog/data/datasources/catalog_local_datasource.dart';
import 'package:noble_nibs/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:noble_nibs/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:noble_nibs/features/catalog/domain/usecases/get_categories.dart';
import 'package:noble_nibs/features/catalog/domain/usecases/get_products.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Critérios de ordenação do catálogo.
enum CatalogSort {
  featured('Destaques'),
  priceAsc('Menor preço'),
  priceDesc('Maior preço'),
  ratingDesc('Melhor avaliação');

  const CatalogSort(this.label);
  final String label;
}

// === DI: datasource → repository → use-cases ================================
final catalogLocalDataSourceProvider = Provider<CatalogLocalDataSource>(
  (ref) => const CatalogLocalDataSource(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(catalogLocalDataSourceProvider)),
);

final getProductsProvider = Provider<GetProducts>(
  (ref) => GetProducts(ref.watch(catalogRepositoryProvider)),
);

final getCategoriesProvider = Provider<GetCategories>(
  (ref) => GetCategories(ref.watch(catalogRepositoryProvider)),
);

// === Dados assíncronos ======================================================
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final result = await ref.watch(getProductsProvider)();
  return result.fold((failure) => throw failure, (products) => products);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await ref.watch(getCategoriesProvider)();
  return result.fold((failure) => throw failure, (categories) => categories);
});

// === Estado de filtros (UI) =================================================
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final sortOrderProvider = StateProvider<CatalogSort>((ref) => CatalogSort.featured);

/// Lista final exibida: produtos filtrados por categoria + busca e ordenados.
/// Propaga loading/error do [productsProvider] via [AsyncValue].
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final async = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sort = ref.watch(sortOrderProvider);

  return async.whenData((products) {
    final filtered = products.where((p) {
      final matchesCategory = _matchesCategory(p, category);
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.origin.region.toLowerCase().contains(query) ||
          p.origin.country.toLowerCase().contains(query) ||
          p.notes.descriptors.any((d) => d.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();

    return _sortProducts(filtered, sort);
  });
});

/// Casa um produto com a categoria selecionada (null = "todos").
bool _matchesCategory(Product p, Category? category) {
  if (category == null || category.type == CategoryType.all) return true;
  return switch (category.type) {
    CategoryType.all => true,
    CategoryType.roast => category.id.split('-').last == p.roast.name,
    CategoryType.origin =>
      p.origin.country.toLowerCase() == category.name.toLowerCase(),
    CategoryType.special => p.isFeatured,
    CategoryType.grind => p.grinds.any((g) => category.id.endsWith(g.type.name)),
  };
}

// =============================================================================
// 🔧 PONTO DE CONTRIBUIÇÃO (modo learning)
// =============================================================================
// A ORDENAÇÃO é uma decisão de produto com várias abordagens válidas:
//  • "Destaques" deve priorizar `isFeatured` e depois quê? (rating? estoque?)
//  • Preço: ordenar pelo `fromPrice` (menor variante) é o esperado pelo usuário?
//  • "Melhor avaliação": empate por `rating` deve desempatar por `reviewCount`?
//
// Abaixo há um baseline funcional. Sinta-se à vontade para REESCREVER o
// comparador conforme as regras do negócio (≈5–10 linhas).
List<Product> _sortProducts(List<Product> items, CatalogSort sort) {
  final sorted = [...items];
  switch (sort) {
    case CatalogSort.featured:
      // TODO(voce): refinar critério de "destaque". Baseline: featured primeiro,
      // depois maior rating.
      sorted.sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    case CatalogSort.priceAsc:
      sorted.sort((a, b) => a.fromPrice.cents.compareTo(b.fromPrice.cents));
    case CatalogSort.priceDesc:
      sorted.sort((a, b) => b.fromPrice.cents.compareTo(a.fromPrice.cents));
    case CatalogSort.ratingDesc:
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return sorted;
}
