import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Use-case: obter a lista de produtos do catálogo.
class GetProducts {
  const GetProducts(this._repo);

  final CatalogRepository _repo;

  Future<Either<Failure, List<Product>>> call() => _repo.getProducts();
}
