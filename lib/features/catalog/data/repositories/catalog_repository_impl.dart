import 'package:fpdart/fpdart.dart';
import 'package:noble_nibs/core/error/exceptions.dart';
import 'package:noble_nibs/core/error/failures.dart';
import 'package:noble_nibs/features/catalog/data/datasources/catalog_local_datasource.dart';
import 'package:noble_nibs/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:noble_nibs/shared/domain/entities/category.dart';
import 'package:noble_nibs/shared/domain/entities/product.dart';

/// Implementação do [CatalogRepository] sobre a fonte local mock.
///
/// Responsabilidade-chave: capturar exceptions da camada `data` e convertê-las
/// em [Failure] — exceptions nunca atravessam para a apresentação.
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._local);

  final CatalogLocalDataSource _local;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      return Right(await _local.fetchProducts());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      return Right(await _local.fetchCategories());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
