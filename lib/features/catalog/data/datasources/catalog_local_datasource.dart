import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:noble_nibs/core/error/exceptions.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';
import 'package:noble_nibs/shared/domain/entities/money.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Fonte de dados local: lê os JSONs mock de `assets/mock/` e os mapeia
/// para entidades de domínio. Simula latência de rede para exercitar os
/// estados de loading na UI.
///
/// Substituir por uma `CatalogRemoteDataSource` (Dio) no futuro não exige
/// mudança nas camadas acima — só trocar o provider.
class CatalogLocalDataSource {
  const CatalogLocalDataSource();

  static const _latency = Duration(milliseconds: 700);

  Future<List<Product>> fetchProducts() async {
    await Future<void>.delayed(_latency);
    try {
      final raw = await rootBundle.loadString('assets/mock/products.json');
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => _productFromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      throw const CacheException('Falha ao carregar o catálogo.');
    }
  }

  Future<List<Category>> fetchCategories() async {
    await Future<void>.delayed(_latency);
    try {
      final raw = await rootBundle.loadString('assets/mock/categories.json');
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return Category(
          id: m['id'] as String,
          name: m['name'] as String,
          type: CategoryType.values.firstWhere(
            (t) => t.name == m['type'],
            orElse: () => CategoryType.all,
          ),
        );
      }).toList(growable: false);
    } catch (e) {
      throw const CacheException('Falha ao carregar categorias.');
    }
  }

  // --- Mapeamento JSON → entidade (vive na camada data) -------------------
  Product _productFromJson(Map<String, dynamic> m) {
    final originJson = m['origin'] as Map<String, dynamic>;
    final notesJson = m['notes'] as Map<String, dynamic>;
    final roast = RoastLevel.fromKey(m['roast'] as String);
    final region = originJson['region'] as String;

    // Foto: usa imageUrl do JSON se houver; senão deriva da torra (e o blend
    // recebe a foto "mesclada das 3 torras").
    final explicit = (m['imageUrl'] as String?) ?? '';
    final isBlend = region.toLowerCase().contains('blend');
    final imageUrl = explicit.isNotEmpty
        ? explicit
        : isBlend
            ? 'assets/images/mesclado-3torras.jpg'
            : switch (roast) {
                RoastLevel.light => 'assets/images/torra-clara.jpg',
                RoastLevel.medium => 'assets/images/torra-media.jpg',
                RoastLevel.dark => 'assets/images/torra-escura.jpg',
              };

    return Product(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      origin: Origin(
        country: originJson['country'] as String,
        region: region,
        farm: originJson['farm'] as String?,
      ),
      roast: roast,
      grinds: (m['grinds'] as List<dynamic>)
          .map((g) => GrindOption(GrindType.fromKey(g as String)))
          .toList(),
      weights: (m['weights'] as List<dynamic>).map((w) {
        final wm = w as Map<String, dynamic>;
        return WeightOption(
          grams: wm['grams'] as int,
          price: Money(wm['priceCents'] as int),
        );
      }).toList(),
      notes: TastingNotes(
        acidity: notesJson['acidity'] as int,
        body: notesJson['body'] as int,
        sweetness: notesJson['sweetness'] as int,
        descriptors: (notesJson['descriptors'] as List<dynamic>).cast<String>(),
      ),
      rating: (m['rating'] as num).toDouble(),
      reviewCount: m['reviewCount'] as int,
      imageUrl: imageUrl,
      isFeatured: m['isFeatured'] as bool,
      stock: m['stock'] as int,
    );
  }
}
