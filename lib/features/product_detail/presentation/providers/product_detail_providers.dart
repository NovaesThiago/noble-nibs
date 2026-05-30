import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Resolve um produto pelo id a partir da lista já carregada do catálogo.
///
/// Reaproveita [productsProvider] (mesma fonte/cache) em vez de buscar de novo
/// — propaga loading/error e devolve `null` se o id não existir.
final productByIdProvider =
    Provider.family<AsyncValue<Product?>, String>((ref, id) {
  return ref.watch(productsProvider).whenData((list) {
    final match = list.where((p) => p.id == id).toList();
    return match.isEmpty ? null : match.first;
  });
});
