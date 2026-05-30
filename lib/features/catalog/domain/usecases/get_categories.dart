import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';

/// Use-case: obter as categorias para a barra de filtros.
class GetCategories {
  const GetCategories(this._repo);

  final CatalogRepository _repo;

  Future<Either<Failure, List<Category>>> call() => _repo.getCategories();
}
