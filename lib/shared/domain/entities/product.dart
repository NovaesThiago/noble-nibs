import 'package:noble_nibs/shared/domain/entities/money.dart';

/// Nível de torra do grão.
enum RoastLevel {
  light('Torra clara'),
  medium('Torra média'),
  dark('Torra escura');

  const RoastLevel(this.label);
  final String label;

  static RoastLevel fromKey(String key) =>
      RoastLevel.values.firstWhere((r) => r.name == key, orElse: () => RoastLevel.medium);
}

/// Tipo de moagem oferecido.
enum GrindType {
  whole('Grão inteiro'),
  espresso('Espresso'),
  filter('Coado / V60'),
  frenchPress('Prensa francesa'),
  moka('Moka / Italiana');

  const GrindType(this.label);
  final String label;

  static GrindType fromKey(String key) =>
      GrindType.values.firstWhere((g) => g.name == key, orElse: () => GrindType.whole);
}

/// Origem do café (país/região/fazenda).
class Origin {
  const Origin({required this.country, required this.region, this.farm});

  final String country;
  final String region;
  final String? farm;

  String get label => region;

  @override
  bool operator ==(Object o) =>
      o is Origin && o.country == country && o.region == region && o.farm == farm;

  @override
  int get hashCode => Object.hash(country, region, farm);
}

/// Opção de peso com seu preço (variante comprável).
class WeightOption {
  const WeightOption({required this.grams, required this.price});

  final int grams;
  final Money price;

  String get label => grams >= 1000 ? '${grams ~/ 1000}kg' : '${grams}g';

  @override
  bool operator ==(Object o) => o is WeightOption && o.grams == grams && o.price == price;

  @override
  int get hashCode => Object.hash(grams, price);
}

/// Opção de moagem disponível para o produto.
class GrindOption {
  const GrindOption(this.type);

  final GrindType type;
  String get label => type.label;

  @override
  bool operator ==(Object o) => o is GrindOption && o.type == type;

  @override
  int get hashCode => type.hashCode;
}

/// Notas de degustação (perfil sensorial), escala 1–5.
class TastingNotes {
  const TastingNotes({
    required this.acidity,
    required this.body,
    required this.sweetness,
    required this.descriptors,
  });

  final int acidity;
  final int body;
  final int sweetness;
  final List<String> descriptors;
}

/// Produto = um café em grãos, com variantes de peso e moagem.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.origin,
    required this.roast,
    required this.grinds,
    required this.weights,
    required this.notes,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.isFeatured,
    required this.stock,
  });

  final String id;
  final String name;
  final String description;
  final Origin origin;
  final RoastLevel roast;
  final List<GrindOption> grinds;
  final List<WeightOption> weights;
  final TastingNotes notes;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isFeatured;
  final int stock;

  /// Menor preço entre as variantes de peso (exibido no card "a partir de").
  Money get fromPrice =>
      weights.map((w) => w.price).reduce((a, b) => a < b ? a : b);

  bool get inStock => stock > 0;

  @override
  bool operator ==(Object o) => o is Product && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
