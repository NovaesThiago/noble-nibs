/// Eixo de categorização do catálogo.
enum CategoryType { all, origin, roast, grind, special }

/// Categoria para a barra de filtros rápida da Home/Catálogo.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final CategoryType type;

  @override
  bool operator ==(Object o) => o is Category && o.id == id;

  @override
  int get hashCode => id.hashCode;
}
