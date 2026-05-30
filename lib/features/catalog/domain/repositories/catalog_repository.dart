import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Contrato do repositório de catálogo (camada `domain`).
///
/// A implementação concreta vive em `data/`. O domínio depende apenas desta
/// interface — inversão de dependência que permite trocar mock por backend.
abstract interface class CatalogRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, List<Category>>> getCategories();
}
